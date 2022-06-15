//
//  WeatherInfoViewModel.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/15.
//

import Foundation
import UIKit

class WeatherInfoListViewModel {
    private let weatehrInfoArray : [WeatherInfo]
    
    public init(weatehrInfoArray : [WeatherInfo]) {
        self.weatehrInfoArray = weatehrInfoArray
    }
    
    public var weatherInfos : [WeatherInfoViewModel] {
        
        var WeatherViewModels : [WeatherInfoViewModel] = [WeatherInfoViewModel]()
        
        for weatherInfo in weatehrInfoArray {
            let weatherViewModel = WeatherInfoViewModel(weatherInfo: weatherInfo)
            WeatherViewModels.append(weatherViewModel)
        }
        
        return WeatherViewModels
    }
}

class WeatherInfoViewModel {
    private  let weatherInfo : WeatherInfo
    
    public init (weatherInfo : WeatherInfo) {
        self.weatherInfo = weatherInfo
    }
    
    public var cityName : String {
        
        guard let cityName = weatherInfo.cityName else { return ""}
        
        return cityName
    }
    
    public var cityWeather : String {
        
        guard let weather = weatherInfo.weather?[0].weatherDescription else { return ""}
        
        return weather
    }
    
    public var cityWeatherImage : UIImage {
        
        guard let weatherImage = weatherInfo.weatherImage else { return UIImage() }
        
        return weatherImage
    }
    
    public var cityCurrentTemp : String {
        
        guard let currentTemp = weatherInfo.detailWeather?.currentTemperature else { return "" }
    
        return "\(Int(currentTemp))°"
    }
    
    public var citySensibleTemp : String {
        
        guard let sensibleTemp = weatherInfo.detailWeather?.sensibleTemperature else { return "" }
        
        return "\(Int(sensibleTemp))°"
    }
    
    public var cityMinTemp : String {
        
        guard let minTemp = weatherInfo.detailWeather?.minTemperature else { return "" }
        
        return "\(Int(minTemp))°"
    }
    
    public var cityMaxTemp : String {
        
        guard let maxTemp = weatherInfo.detailWeather?.maxTemperature else { return "" }
        
        return "\(Int(maxTemp))°"
    }
    
    public var cityHumidity : String {
        
        guard let humidity = weatherInfo.detailWeather?.humidity else { return ""}
        
        return "\(humidity)%"
    }
    
    public var cityWindSpeed : String {
        
        guard let windSpeed = weatherInfo.wind?.speed else { return ""}
        
        return "\(windSpeed)m/s"
    }
    
    public var cityPressure : String {
        
        guard let pressure = weatherInfo.detailWeather?.atmosphericPressure else { return "" }
        
        return "\(pressure)hPa"
    }
}
