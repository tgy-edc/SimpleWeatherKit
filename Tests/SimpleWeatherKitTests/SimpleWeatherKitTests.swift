import XCTest
@testable import SimpleWeatherKit

final class SimpleWeatherKitTests: XCTestCase {
    
    func testCurrentWeather_EmojiLogic_AllCases() {
        XCTAssertEqual(
            createWeather(
                code: 0,
                isDay: 1
            ).weatherEmoji,
            "☀️"
        )
        XCTAssertEqual(
            createWeather(
                code: 1,
                isDay: 1
            ).weatherEmoji,
            "🌤"
        )
        XCTAssertEqual(
            createWeather(
                code: 2,
                isDay: 1
            ).weatherEmoji,
            "⛅️"
        )
        XCTAssertEqual(
            createWeather(
                code: 0,
                isDay: 0
            ).weatherEmoji,
            "🌙"
        )
        XCTAssertEqual(
            createWeather(
                code: 1,
                isDay: 0
            ).weatherEmoji,
            "☁️"
        )
        XCTAssertEqual(
            createWeather(
                code: 3,
                isDay: 1
            ).weatherEmoji,
            "☁️"
        )
        XCTAssertEqual(
            createWeather(
                code: 3,
                isDay: 0
            ).weatherEmoji,
            "☁️"
        )
        XCTAssertEqual(
            createWeather(
                code: 45,
                isDay: 1
            ).weatherEmoji,
            "🌫"
        )
        XCTAssertEqual(
            createWeather(
                code: 61,
                isDay: 0
            ).weatherEmoji,
            "🌧"
        )
        XCTAssertEqual(
            createWeather(
                code: 73,
                isDay: 1
            ).weatherEmoji,
            "❄️"
        )
        XCTAssertEqual(
            createWeather(
                code: 95,
                isDay: 0
            ).weatherEmoji,
            "⛈"
        )
        XCTAssertEqual(
            createWeather(
                code: 9999,
                isDay: 1
            ).weatherEmoji,
            "❓"
        )
    }
    
    func testFetchWeather_Integration_LiveRequest_ParsesRealData() async throws {
        
        let liveService = WeatherService()
        let berlinLatitude = 52.52
        let berlinLongitude = 13.41
        
        let weatherResponse: WeatherResponse
        
        do {
            weatherResponse = try await liveService
                .fetchWeather(
                    latitude: berlinLatitude,
                    longitude: berlinLongitude
                )
        } catch {
            XCTFail(
                "Live API request failed. Check internet connection or API status. Error: \(error)"
            )
            return
        }
        
        XCTAssertEqual(
            weatherResponse.latitude,
            berlinLatitude,
            accuracy: 0.1
        )
        XCTAssertEqual(
            weatherResponse.longitude,
            berlinLongitude,
            accuracy: 0.1
        )
        XCTAssertFalse(
            weatherResponse.timezone.isEmpty
        )
        
        let current = weatherResponse.currentWeather
        
        XCTAssertTrue(
            current.temperature > -60 && current.temperature < 60
        )
        XCTAssertTrue(
            current.windspeed >= 0
        )
        XCTAssertTrue(
            current.weathercode >= 0
        )
        XCTAssertTrue(
            current.isDay == 0 || current.isDay == 1
        )
        XCTAssertFalse(
            current.weatherEmoji.isEmpty
        )
    }
    
    private func createWeather(
        code: Int,
        isDay: Int
    ) -> CurrentWeather {
        return CurrentWeather(
            temperature: 10,
            windspeed: 5,
            weathercode: code,
            isDay: isDay
        )
    }
}
