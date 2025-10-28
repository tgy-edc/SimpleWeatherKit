//
//  WeatherService.swift
//  SimpleWeatherKit
//
//  Created by Celal Can Sağnak on 22.10.2025.
//

import Foundation

public enum WeatherError: Error, Equatable {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(statusCode: Int)
    
    public static func == (lhs: WeatherError, rhs: WeatherError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (let .networkError(lhsError), let .networkError(rhsError)):
            return (lhsError as NSError).code == (rhsError as NSError).code &&
            (lhsError as NSError).domain == (rhsError as NSError).domain
        case (let .decodingError(lhsError), let .decodingError(rhsError)):
            return (lhsError as NSError).code == (rhsError as NSError).code &&
            (lhsError as NSError).domain == (rhsError as NSError).domain
        case (let .serverError(lhsCode), let .serverError(rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

public struct WeatherService {
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherResponse {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw WeatherError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "current_weather", value: "true")
        ]
        
        guard let url = urlComponents.url else {
            throw WeatherError.invalidURL
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await self.session.data(from: url)
        } catch {
            throw WeatherError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.networkError(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            return weatherResponse
        } catch {
            throw WeatherError.decodingError(error)
        }
    }
}
