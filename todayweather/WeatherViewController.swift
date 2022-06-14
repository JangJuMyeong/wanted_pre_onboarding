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
    
    @IBOutlet weak var lastGetWeahterTimeLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLocationWeatherLabel: UILabel!
    @IBOutlet weak var userLocationWeatherImage: UIImageView!
    @IBOutlet weak var userLocationTempLabel: UILabel!
    @IBOutlet weak var userLocationHumidityLabel: UILabel!
    @IBOutlet weak var loadingTextLabel: UILabel!
    @IBOutlet weak var weatehrInfosCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        weatehrInfosCollectionView.delegate = self
        weatehrInfosCollectionView.dataSource = self
        weatehrInfosCollectionView.backgroundColor = UIColor.white
        
        lastGetWeahterTimeLabel.text = "최근 조회 시간 - \(getCurrentTime())"
        userLocationLabel.text = ""
        userLocationWeatherLabel.text = ""
        userLocationTempLabel.text = ""
        userLocationHumidityLabel.text = ""
        
        getLocationUsagePermission()
        
        //주요도시 날씨 정보 가져오기
        OnpenWeatherAPIManger.shared.getMajorWeatherInfos { result in
            switch result {
            case .success(let weatherInfos) :
                self.weatehrInfos = weatherInfos
                DispatchQueue.main.async {
                    self.weatehrInfosCollectionView.reloadData()
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
    
    func getCurrentTime() -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "a hh:mm"
        let currentDateTime = formatter.string(from: Date())
       
        return currentDateTime
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
                                //이미지 다운로드
                                OnpenWeatherAPIManger.shared.downloadImage(imageIcon: imageIcon) { result in
                                    switch result {
                                    case .success(let image) :
                                        // 현위치 주소 정보 가져오기
                                        NaverLocationAPIManger.shared.getLocation(longitude: coor.longitude, latitude: coor.latitude) { result in
                                            switch result {
                                            case.success(let location):
                                                DispatchQueue.main.async() {
                                                    self.loadingTextLabel.isHidden = true
                                                    self.userLocationLabel.text = location
                                                    self.userLocationWeatherLabel.text = description
                                                    self.userLocationTempLabel.text = "현재 온도 : \(Int(temp))°"
                                                    self.userLocationHumidityLabel.text = "현재 습도 : \(humidity)%"
                                                    self.userLocationWeatherImage.image = image
                                                }
                                            case.failure(let error):
                                                print("Get User Location Fail",error)
                                            }
                                        }
                                    case .failure(let error) :
                                        print("Download Image Failt", error)
                                    }
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
        
        self.loadingTextLabel.text = "현재 위치정보를 불러오는데 실패 하였습니다."
        let sheet = UIAlertController(title: "위치정보 확인 실패", message: "권한 설정하시지 않으면 현재 위치의 날씨정보를 확인할 수 없습니다. 앱 설정에서 변경해주세요.", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        
        present(sheet, animated: true)
    }
}

//MARK: - UICollectionViewDataSource
extension WeatherViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let weatehrInfosNumber = weatehrInfos?.count else { return 0 }
        
        return weatehrInfosNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeatehrCollectionViewCell
        
        cell.backgroundColor = UIColor.white
        
        if let cityName = weatehrInfos?[indexPath.row].cityName,
           let cityTemp = weatehrInfos?[indexPath.row].detailWeather?.currentTemperature,
           let cityweatherIcon = weatehrInfos?[indexPath.row].weather?[0].icon,
           let cityHumidity = weatehrInfos?[indexPath.row].detailWeather?.humidity {
            cell.cityNameLable.text = cityName
            cell.cityDetailWeatherLabel.text = "\(Int(cityTemp))° / \(cityHumidity)%"
            OnpenWeatherAPIManger.shared.downloadImage(imageIcon: cityweatherIcon) { result in
                switch result {
                case .success(let image) :
                    DispatchQueue.main.async {
                        cell.cityWeatherImage.image = image
                    }
                case .failure(let error) :
                    print("Cell Image Download Fail",error)
                }
            }
        }
        
        return cell
    }
    
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension WeatherViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 120, height: 120)
        return size
    }
    
}
