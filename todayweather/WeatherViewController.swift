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
    var weatehrInfos : WeatherInfoListViewModel?
    var userLocationInfo : WeatherInfoViewModel?
    
    @IBOutlet weak var lastGetWeahterTimeLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLocationWeatherLabel: UILabel!
    @IBOutlet weak var userLocationWeatherImage: UIImageView!
    @IBOutlet weak var userLocationTempLabel: UILabel!
    @IBOutlet weak var userLocationHumidityLabel: UILabel!
    @IBOutlet weak var loadingTextLabel: UILabel!
    @IBOutlet weak var weatehrInfosCollectionView: UICollectionView!
    @IBOutlet weak var userLocationInfoStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        
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
    
    @IBAction func refreshWeatherInfo(_ sender: Any) {
        refreshWeatherInfo()
    }
    
//MARK: - Function
    
    func initView() {
        
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        weatehrInfosCollectionView.delegate = self
        weatehrInfosCollectionView.dataSource = self
        weatehrInfosCollectionView.backgroundColor = UIColor.white
        let layout = weatehrInfosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        
        lastGetWeahterTimeLabel.text = "최근 조회 시간 - \(getCurrentTime())"
        userLocationLabel.text = ""
        userLocationWeatherLabel.text = ""
        userLocationTempLabel.text = ""
        userLocationHumidityLabel.text = ""
        
        getLocationUsagePermission()
        getMajorWeatherInfos()
        registStackViewClickedEvent()
        
    }
    
    //현재 시간 가져오기
    func getCurrentTime() -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "a hh:mm"
        let currentDateTime = formatter.string(from: Date())
       
        return currentDateTime
    }
    
    //유저 현 위치 및 날씨 정보 가져오기
    private func getUserLocationWeatherInfo() {
        
        locationManger.startUpdatingLocation()
        
        if let coor = locationManger.location?.coordinate {
            
            OnpenWeatherAPIManger.shared.getUserLoactionWeatherInfo(longitude: coor.longitude, latitude: coor.latitude) { result in
                switch result {
                case .success(var weatherInfo) :
                    NaverLocationAPIManger.shared.getLocation(longitude: coor.longitude, latitude: coor.latitude) { result in
                        switch result {
                        case.success(let location):
                            weatherInfo.cityName = location
                            self.userLocationInfo = WeatherInfoViewModel(weatherInfo: weatherInfo)
                            if let userLocationInfo = self.userLocationInfo {
                                DispatchQueue.main.async() {
                                    self.userLoactionInfoUIUpdate(weatehrInfo: userLocationInfo)
                                }
                            }
                        case.failure(let error):
                            print("Get User Location Fail",error)
                        }
                    }
                case .failure(let error) :
                    print("Get User WeatherInfo Fail", error)
                }
            }
        }
    }
    
    //주요 도시 날씨 정보 가져오기
    private func  getMajorWeatherInfos() {
        OnpenWeatherAPIManger.shared.getMajorWeatherInfos { result in
            switch result {
            case .success(let weatherInfos) :
                self.weatehrInfos = WeatherInfoListViewModel(weatehrInfoArray: weatherInfos)
                DispatchQueue.main.async {
                    self.weatehrInfosCollectionView.reloadData()
                }
            case .failure(let weatherInfos):
                print("Fail",weatherInfos)
            }
        }
    }
    
    //날씨 정보 재조회
    private func refreshWeatherInfo() {
        getUserLocationWeatherInfo()
        getMajorWeatherInfos()
        DispatchQueue.main.async {
            self.lastGetWeahterTimeLabel.text = "최근 조회 시간 - \(self.getCurrentTime())"
        }
    }
    
    //스택뷰 클릭 이벤트 등록
    private func registStackViewClickedEvent() {
        userLocationInfoStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stackviewClicked)))
    }
    
    private func userLoactionInfoUIUpdate(weatehrInfo : WeatherInfoViewModel) {
        self.loadingTextLabel.isHidden = true
        self.userLocationLabel.text = weatehrInfo.cityName
        self.userLocationWeatherLabel.text = weatehrInfo.cityWeather
        self.userLocationTempLabel.text = "현재 온도 : \(weatehrInfo.cityCurrentTemp)"
        self.userLocationHumidityLabel.text = "현재 습도 : \(weatehrInfo.cityHumidity)"
        self.userLocationWeatherImage.image = weatehrInfo.cityWeatherImage
    }
    
    //스택뷰 클릭 이벤트 처리
    @objc func stackviewClicked() {
        
        guard let vc =  storyboard?.instantiateViewController(identifier: "DetailWeatherViewController") as? DetailWeatherViewController else
               { return }
        
        if let WeatherInfo = userLocationInfo {
            vc.weatherInfo = WeatherInfo
        }
        
        //모달로 페이지 이동
        self.present(vc, animated: true)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController : CLLocationManagerDelegate {
    
    //유저 위치정보 권한 설정
    func getLocationUsagePermission() {
        
        self.locationManger.requestWhenInUseAuthorization()

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
            getUserLocationWeatherInfo()
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
    
    //위치정보 확인 불가 알림
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
        
        guard let weatehrInfosNumber = weatehrInfos?.weatherInfos.count else { return 0 }
        
        return weatehrInfosNumber
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WeatehrCollectionViewCell
        
        cell.backgroundColor = UIColor.white
        
        if let weatherInfo = weatehrInfos?.weatherInfos[indexPath.row] {
            cell.cityNameLable.text = weatherInfo.cityName
            cell.cityDetailWeatherLabel.text = "\(weatherInfo.cityCurrentTemp) / \(weatherInfo.cityHumidity)"
            cell.cityWeatherImage.image = weatherInfo.cityWeatherImage
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

//MARK: - UICollectionViewDelegate
extension WeatherViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let vc =  storyboard?.instantiateViewController(identifier: "DetailWeatherViewController") as? DetailWeatherViewController else
               { return }
        
        if let selectWeatherInfo = weatehrInfos?.weatherInfos[indexPath.row] {
            vc.weatherInfo = selectWeatherInfo
        }
        
        self.present(vc, animated: true)
    }
}

