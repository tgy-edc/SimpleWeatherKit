//
//  CurrentWeather.swift
//  SimpleWeatherKit
//
//  Created by Celal Can Sağnak on 22.10.2025.
//

import Foundation

public struct CurrentWeather: Codable {
    public let temperature: Double
    public let windspeed: Double
    public let weathercode: Int
    public let isDay: Int

    enum CodingKeys: String, CodingKey {
        case temperature, windspeed, weathercode
        case isDay = "is_day"
    }

    public var weatherEmoji: String {
        switch weathercode {
        case 0:
            return isDay == 1 ? "☀️" : "🌙"
        case 1:
            return isDay == 1 ? "🌤" : "☁️"
        case 2:
            return isDay == 1 ? "⛅️" : "☁️"
        case 3:
            return "☁️"
        case 45, 48:
            return "🌫"
        case 51, 53, 55:
            return "🌦"
        case 56, 57:
            return "🌨"
        case 61, 63, 65:
            return "🌧"
        case 66, 67:
            return "🌨"
        case 71, 73, 75:
            return "❄️"
        case 77:
            return "❄️"
        case 80, 81, 82:
            return "🌧"
        case 85, 86:
            return "🌨"
        case 95, 96, 99:
            return "⛈"
        default:
            return "❓"
        }
    }
}
