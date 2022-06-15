//
//  DetailWeatherViewController.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/13.
//

import UIKit

class DetailWeatherViewController: UIViewController {
    
    var weatherInfo : WeatherInfoViewModel?
    
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
        
        if let weatehrInfo = weatherInfo {
            cityNameLabel.text = weatehrInfo.cityName
            cityWeatherLabel.text = weatehrInfo.cityWeather
            cityCurrentTempLabel.text = "현재 기온 - " + weatehrInfo.cityCurrentTemp
            citySensibleTempLabel.text = "체감 기온 - " + weatehrInfo.citySensibleTemp
            cityMinTempLabel.text = "최고 기온 - " + weatehrInfo.cityMaxTemp
            cityMaxTempLabel.text = "최저 기온 - " + weatehrInfo.cityMinTemp
            cityHumidityLabel.text = "습도 - " + weatehrInfo.cityHumidity
            cityWindLabel.text = "풍속 - " + weatehrInfo.cityWindSpeed
            cityPressureLabel.text = "기압 - " + weatehrInfo.cityPressure
            cityWeatherImage.image = weatehrInfo.cityWeatherImage
        }
    }
}
