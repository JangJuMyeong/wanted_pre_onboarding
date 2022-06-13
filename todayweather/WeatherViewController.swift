//
//  ViewController.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/11.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    var locationManger : CLLocationManager!
    var weatehrInfos : [WeatherInfo]?
    var userLocationInfo : UserLocationInfo?
    
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLocationWeatherLabel: UILabel!
    @IBOutlet weak var userLocationWeatherImage: UIImageView!
    @IBOutlet weak var userLocationTempLabel: UILabel!
    @IBOutlet weak var userLocationHumidityLabel: UILabel!
    @IBOutlet weak var loadingTextLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        userLocationLabel.text = ""
        userLocationWeatherLabel.text = ""
        userLocationTempLabel.text = ""
        userLocationHumidityLabel.text = ""
        
        getLocationUsagePermission()
        
        OnpenWeatherAPIManger.shared.getMajorWeatherInfos { result in
            switch result {
            case .success(let weatherInfos) :
                self.weatehrInfos = weatherInfos
            case .failure(let weatherInfos):
                print("Fail",weatherInfos)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locationManger.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if authorizationStatus == .denied {
            showPermissionAlert()
        }
        
    }
    
    
    @IBAction func clicked(_ sender: Any) {
       
    }
    
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController : CLLocationManagerDelegate {
    
    func getLocationUsagePermission() {
        
        self.locationManger.requestWhenInUseAuthorization()

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            locationManger.startUpdatingLocation()
            
            if let coor = locationManger.location?.coordinate {
                
                
                
                OnpenWeatherAPIManger.shared.getUserLoactionWeatherInfo(longitude: coor.longitude, latitude: coor.latitude) { result in
                    switch result {
                    case .success(let weatherInfo) :
                        
                            if let description = weatherInfo.weather?[0].weatherDescription,
                               let temp = weatherInfo.detailWeather?.currentTemperature,
                               let humidity = weatherInfo.detailWeather?.humidity,
                               let imageIcon = weatherInfo.weather?[0].icon {
                                
                                OnpenWeatherAPIManger.shared.downloadImage(imageIcon: imageIcon) { result in
                                    switch result {
                                    case .success(let image) :
                                        DispatchQueue.main.async {
                                            self.userLocationWeatherImage.image = image
                                        }
                                    case .failure(let error) :
                                        print("Download Image Failt", error)
                                    }
                                }
                                
                                NaverLocationAPIManger.shared.getLocation(longitude: coor.longitude, latitude: coor.latitude) { result in
                                    switch result {
                                    case.success(let location):
                                        DispatchQueue.main.async() {
                                            print(location)
                                            self.loadingTextLabel.isHidden = true
                                            self.userLocationLabel.text = location
                                        }
                                    case.failure(let error):
                                        print("Get User Location Fail",error)
                                    }
                                }
                               
                                DispatchQueue.main.async() {
                                    print(description)
                                self.userLocationWeatherLabel.text = description
                                    self.userLocationTempLabel.text = "현재 온도 : \(round(temp))°"
                                self.userLocationHumidityLabel.text = "현재 습도 : \(humidity)%"
                                }
                                
                        }else {
                            print("안됨")
                        }
                        
                    case .failure(let error) :
                        print("Get User WeatherInfo Fail", error)
                    }
                }
            }
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            getLocationUsagePermission()
        case .denied:
            print("GPS 권한 요청 거부됨")
            showPermissionAlert()
        default:
            print("GPS: Default")
        }
    }
    
    func showPermissionAlert() {
        
        self.loadingTextLabel.text = "현재 위치정보를 불러오는데 실패하였습니다."
        let sheet = UIAlertController(title: "권한 설정", message: "권한 설정하시지 않으면 현재 위치의 날씨정보를 확인할 수 없습니다. 앱 설정에서 변경해주세요", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        present(sheet, animated: true)
    }
}
