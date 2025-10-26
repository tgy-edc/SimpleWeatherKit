//
//  WeatherResponse.swift
//  SimpleWeatherKit
//
//  Created by Celal Can Sağnak on 22.10.2025.
//

import Foundation

public struct WeatherResponse: Codable {
    public let latitude: Double
    public let longitude: Double
    public let timezone: String
    public let currentWeather: CurrentWeather

    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone
        case currentWeather = "current_weather"
    }
}
