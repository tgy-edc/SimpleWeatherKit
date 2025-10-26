<div align="center">

# Simple Weather Kit

Basit, modern ve `async/await` tabanlı bir Open-Meteo API istemcisi.

</div>

<div align="center">
  
<img src="https://img.shields.io/badge/Swift-5.7%2B-orange" alt="Swift 5.7+">
<img src="https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2012%2B-blue" alt="Platform iOS 15+ | macOS 12+">
<img src="https://img.shields.io/badge/SwiftPM-Uyumlu-brightgreen" alt="Swift Package Manager">
<a href="https://github.com/tgy-edc/SimpleWeatherKit/blob/main/LICENSE">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey" alt="License MIT">
</a>

</div>

## Genel Bakış

**SimpleWeatherKit**, [Open-Meteo](https://open-meteo.com/) ücretsiz hava durumu API'si için tasarlanmış, Swift dilinin modern concurrency özelliklerini ( `async/await` ) kullanan hafif bir pakettir.

Bu paket, herhangi bir iOS veya macOS uygulamasına hızlıca anlık hava durumu verilerini entegre etmenizi sağlar. Karmaşık kurulumlar veya bağımlılıklar olmadan, temiz ve `Codable` uyumlu modellerle çalışır.

## Özellikler

* **Modern Concurrency:** `async/await` sözdizimi ile tam asenkron çalışır.
* **Sıfır Bağımlılık:** Projenize ekstra yük getirmez.
* **Kolay Kullanım:** `WeatherService` üzerinden tek satırlık bir fonksiyon çağrısıyla veri alın.
* **Akıllı Emoji Desteği:** `CurrentWeather` modeli, gelen `weathercode` verisini otomatik olarak "☀️", "🌧", "❄️" gibi ilgili emoji'lere dönüştüren `weatherEmoji` adında kullanışlı bir özelliğe sahiptir.
* **Güçlü Hata Yönetimi:** `WeatherError` enum'u sayesinde ağ, sunucu veya veri ayrıştırma hatalarını kolayca yakalayın ve yönetin.
* **Tip Güvenliği (Type-Safe):** Tüm API yanıtları, `Codable` ile uyumlu Swift `struct`'ları (`WeatherResponse`, `CurrentWeather`) olarak modellenmiştir.

## Gereksinimler

* Swift 5.7+
* iOS 15.0+
* macOS 12.0+

## Kurulum

SimpleWeatherKit, Swift Package Manager (SPM) aracılığıyla kolayca projenize eklenebilir.

### Xcode

1.  Projeniz açıkken **File > Add Packages...** menüsüne gidin.
2.  Açılan penceredeki arama çubuğuna bu repository'nin URL'ini yapıştırın:

    ```
    https://github.com/CanSagnak1/SimpleWeatherKit
    ```

3.  "Dependency Rule" olarak "Up to Next Major Version" seçin ve "Add Package" butonuna tıklayın.
4.  Paketi ilgili target'ınıza ekleyin.

### Package.swift

`Package.swift` dosyanızın `dependencies` dizisine aşağıdaki satırı ekleyin:

```swift
dependencies: [
    .package(url: "[https://github.com/tgy-edc/SimpleWeatherKit](https://github.com/tgy-edc/SimpleWeatherKit)", from: "1.0.0")
],
```

Ve ilgili `target`'ınızın `dependencies` dizisine `"SimpleWeatherKit"` ekleyin:

```swift
targets: [
    .target(
        name: "MyApp",
        dependencies: ["SimpleWeatherKit"])
]
```

## Hızlı Başlangıç

`SimpleWeatherKit` kullanımı çok basittir. `WeatherService` sınıfını başlatın ve `fetchWeather` fonksiyonunu çağırın.

Aşağıdaki örnek, Berlin'in anlık hava durumu verilerini çeker:

```swift
import SimpleWeatherKit
import Foundation

// 1. WeatherService'in bir örneğini oluşturun
let service = WeatherService()

// Berlin, Almanya koordinatları
let latitude = 52.52
let longitude = 13.41

// 2. Verileri çekmek için asenkron bir fonksiyon oluşturun
func fetchCurrentWeather() async {
    print("Berlin için hava durumu alınıyor...")
    
    do {
        // 3. API'yi çağırın
        let response = try await service.fetchWeather(
            latitude: latitude,
            longitude: longitude
        )
        
        // 4. Gelen veriyi kullanın
        let current = response.currentWeather
        
        print("--- Berlin Anlık Hava Durumu ---")
        print("Sıcaklık: \(current.temperature)°C")
        print("Durum: \(current.weatherEmoji)") // <-- Akıllı emoji!
        print("Rüzgar Hızı: \(current.windspeed) km/s")
        print("Zaman Dilimi: \(response.timezone)")
        print("Gündüz mü?: \(current.isDay == 1 ? "Evet" : "Hayır")")
        
    } catch {
        // 5. Olası hataları yakalayın
        print("Hava durumu alınamadı: \(error.localizedDescription)")
    }
}

// Asenkron fonksiyonu çalıştırın
Task {
    await fetchCurrentWeather()
}

/*
 Örnek Çıktı:

 Berlin için hava durumu alınıyor...
 --- Berlin Anlık Hava Durumu ---
 Sıcaklık: 14.2°C
 Durum: 🌤
 Rüzgar Hızı: 10.3 km/s
 Zaman Dilimi: Europe/Berlin
 Gündüz mü?: Evet
*/
```

## Hata Yönetimi (Error Handling)

`WeatherService`, `WeatherError` adında spesifik bir hata tipi döndürür. Bu sayede hataları kolayca ayırt edebilirsiniz:

```swift
import SimpleWeatherKit

let service = WeatherService()

func checkInvalidRequest() async {
    do {
        // Sunucudan hata döndürecek geçersiz koordinatlar
        _ = try await service.fetchWeather(latitude: 9999, longitude: 9999)
    } catch let error as WeatherError {
        // Hatanın tipine göre işlem yap
        switch error {
        case .invalidURL:
            print("Hata: Geçersiz URL oluşturuldu.")
        case .networkError(let internalError):
            print("Hata: Ağ sorunu. \(internalError.localizedDescription)")
        case .decodingError(let internalError):
            print("Hata: Gelen veri (JSON) ayrıştırılamadı. \(internalError.localizedDescription)")
        case .serverError(let statusCode):
            print("Hata: Sunucu hatası. Status Kodu: \(statusCode)")
        }
    } catch {
        print("Hata: Bilinmeyen bir sorun oluştu. \(error.localizedDescription)")
    }
}

Task {
    await checkInvalidRequest()
}

// Çıktı: Hata: Sunucu hatası. Status Kodu: 400
```

## API Mimarisi

### Ana Bileşenler

* `WeatherService`: API isteklerini yapan ana sınıf.
    * `init(session: URLSession = .shared)`: İsteğe bağlı olarak kendi `URLSession`'ınızı enjekte edebilirsiniz. Test için kullanışlıdır.
    * `fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse`: Belirtilen koordinatlar için anlık hava durumu verilerini getirir.

### Veri Modelleri

* `WeatherResponse`: API'den gelen en üst seviye yanıt.
    * `latitude: Double`
    * `longitude: Double`
    * `timezone: String`
    * `currentWeather: CurrentWeather` (Aşağıdaki model)

* `CurrentWeather`: Anlık hava durumu detayları.
    * `temperature: Double`
    * `windspeed: Double`
    * `weathercode: Int`
    * `isDay: Int` (Gündüz için `1`, gece için `0`)
    * `weatherEmoji: String` **(Computed Property)**: `weathercode`'u bir emoji'ye çevirir.

## Katkıda Bulunma

Katkılarınız ve geri bildirimleriniz her zaman açığız! Lütfen bir *issue* açın veya *pull request* gönderin.

## Lisans

Bu proje, MIT Lisansı altında yayınlanmıştır. Detaylar için `LICENSE` dosyasına bakın.
