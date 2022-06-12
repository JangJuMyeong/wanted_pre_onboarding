//
//  ViewController.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/11.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var locationManger : CLLocationManager!
    
    @IBOutlet weak var lastSearchTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        getLocationUsagePermission()
        
        OnpenWeatherAPIManger.shared.getMajorWeatherInfos { result in
            switch result {
            case .success(let weatherInfos) :
                for weatherinfo in weatherInfos {
                    if let cityName = weatherinfo.cityName {
                        print(cityName)
                    }
                }
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

extension ViewController : CLLocationManagerDelegate {
    
    func getLocationUsagePermission() {
        
        self.locationManger.requestWhenInUseAuthorization()

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            locationManger.startUpdatingLocation()
            
            if let coor = locationManger.location?.coordinate {
                
                NaverLocationAPIManger.shared.getLocation(longitude: coor.longitude, latitude: coor.latitude) { result in
                    switch result {
                    case.success(let loaction):
                        DispatchQueue.main.async() { [weak self] in
                            self?.lastSearchTimeLabel.text = loaction
                        }
                    case.failure(let error):
                        print("fail",error)
                    }
                }
                
                OnpenWeatherAPIManger.shared.getUserLoactionWeatherInfo(longitude: coor.longitude, latitude: coor.latitude) { result in
                    switch result {
                    case .success(let weatherInfo) :
                        DispatchQueue.main.async() { [weak self] in
                            if let description = weatherInfo.weather?[0].weatherDescription {
                                self?.lastSearchTimeLabel.text! += description
                            }
                        }
                    case .failure(let error) :
                        print("Fail", error)
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
        let sheet = UIAlertController(title: "권한 설정", message: "권한 설정하시지 않으면 현재 위치의 날씨정보를 확인할 수 없습니다. 앱 설정에서 변경해주세요", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        present(sheet, animated: true)
    }
}
