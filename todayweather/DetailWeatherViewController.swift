//
//  DetailWeatherViewController.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/13.
//

import UIKit

class DetailWeatherViewController: UIViewController {
    
    var weatherInfo : WeatherInfo?
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityWeatherLabel: UILabel!
    @IBOutlet weak var cityWeatherImage: UIImageView!
    @IBOutlet weak var cityCurrentTempLabel: UILabel!
    @IBOutlet weak var citySensibleTempLabel: UILabel!
    @IBOutlet weak var cityMinTempLabel: UILabel!
    @IBOutlet weak var cityMaxTempLabel: UILabel!
    @IBOutlet weak var cityHumidityLabel: UILabel!
    @IBOutlet weak var cityWindLabel: UILabel!
    @IBOutlet weak var cityPressureLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let cityName = weatherInfo?.cityName,
           let cityWeather = weatherInfo?.weather?[0].weatherDescription,
           let cityWeatherIcon = weatherInfo?.weather?[0].icon,
           let cityCurrentTemp = weatherInfo?.detailWeather?.currentTemperature,
           let citySensibleTemp = weatherInfo?.detailWeather?.sensibleTemperature,
           let cityMinTemp = weatherInfo?.detailWeather?.minTemperature,
           let cityMaxTemp = weatherInfo?.detailWeather?.maxTemperature,
           let cityHumidity = weatherInfo?.detailWeather?.humidity,
           let cityWindSpeed = weatherInfo?.wind?.speed,
           let cityPressure = weatherInfo?.detailWeather?.atmosphericPressure{
            
            cityNameLabel.text = cityName
            cityWeatherLabel.text = cityWeather
            cityCurrentTempLabel.text = "현재 기온 - \(Int(cityCurrentTemp))°"
            citySensibleTempLabel.text = "체감 기온 - \(Int(citySensibleTemp))°"
            cityMinTempLabel.text = "최고 기온 - \(Int(cityMinTemp))°"
            cityMaxTempLabel.text = "최저 기온 - \(Int(cityMaxTemp))°"
            cityHumidityLabel.text = "습도 - \(cityHumidity)%"
            cityWindLabel.text = "풍속 - \(cityWindSpeed)m/s"
            cityPressureLabel.text = "기압 - \(cityPressure)hPa"
            
            OnpenWeatherAPIManger.shared.downloadImage(imageIcon: cityWeatherIcon) { result in
                switch result {
                case .success(let image) :
                    DispatchQueue.main.async {
                        self.cityWeatherImage.image = image
                    }
                case .failure(let error) :
                    print("Fail To Downalod Image DetailView", error)
                }
            }
        }
    }
}
