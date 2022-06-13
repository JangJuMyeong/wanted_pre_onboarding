//
//  CodableModel.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/11.
//

import Foundation
import UIKit

struct WeatherInfo : Codable {
    
    var coord : Coord?
    var weather : [Weather]?
    var base : String?
    var detailWeather : DetailWeather?
    var visibility : Int?
    var wind : Wind?
    var clouds : Clouds?
    var unixTime : Int?
    var system : System?
    var timeZone : Int?
    var id : Int?
    var cityName : String?
    var cod : Int?
    var weatherImage : UIImage?
    
    enum CodingKeys : String, CodingKey{
        case coord
        case weather
        case base
        case detailWeather = "main"
        case visibility
        case wind
        case clouds
        case unixTime = "dt"
        case system = "sys"
        case timeZone = "timezone"
        case id
        case cityName = "name"
        case cod
    }
    
    struct Coord : Codable {
        
        var longitude : Float?
        var latitude : Float?
        
        enum CodingKeys : String, CodingKey{
            case longitude = "lon"
            case latitude = "lat"
        }
    }
    
    struct Weather : Codable {
        
        var id : Int?
        var weatherGroup : String?
        var weatherDescription : String?
        var icon : String?
        
        enum CodingKeys : String, CodingKey{
            case id
            case weatherGroup = "main"
            case weatherDescription = "description"
            case icon
        }
    }
    
    struct DetailWeather : Codable {
        
        var currentTemperature : Float?
        var sensibleTemperature : Float?
        var minTemperature : Float?
        var maxTemperature : Float?
        var atmosphericPressure : Int?
        var humidity : Int?
        var seaAtmosphericPressure : Int?
        var groundAtmosphericPressure : Int?
        
        enum CodingKeys : String, CodingKey{
            case currentTemperature = "temp"
            case sensibleTemperature = "feels_like"
            case minTemperature = "temp_min"
            case maxTemperature = "temp_max"
            case atmosphericPressure = "pressure"
            case humidity
            case seaAtmosphericPressure = "sea_level"
            case groundAtmosphericPressure = "grnd_level"
        }
    }
    
    struct Wind : Codable {
        
        var speed : Float?
        var degress : Int?
        var gust : Float?
        
    }
    
    struct Clouds : Codable {
        
        var clouds : Int?
        
        enum CodingKeys : String, CodingKey{
            case clouds = "all"
        }
    }
    
    struct System : Codable {
        
        var type : Int?
        var id : Int?
        var country : String?
        var sunrise : Int?
        var sunset : Int?
        
    }
    
}



