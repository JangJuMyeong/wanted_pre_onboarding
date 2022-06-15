//
//  OpenWeatherAPIManger.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/12.
//

import Foundation
import UIKit

class OnpenWeatherAPIManger {
    
    static let shared = OnpenWeatherAPIManger()
    
    private let baseURL : String = "https://api.openweathermap.org/data/2.5/weather"
    private let imageDownloadURL : String = "https://openweathermap.org/img/wn/"
    private let clientSecret : String = "b663f0f76d1e95b7ab5bb0cfafeddc03"
    private let cityIds = [ 1842616,1841808,1842225,1842025,1835327,1835235,1841066,1838519,1835895,1835847,1836553,1835553,1835648,1833742,1843491,1845457,1846266,1845759,1845604,1845136 ]
    
    private init() {
        
    }
    
    //주요 도시 날씨정보 가져오기
    func getMajorWeatherInfos(handler: @escaping (Result<[WeatherInfo] , Error>) -> ()) {
        
        let session = URLSession(configuration: .default)
        var WeatherInfos = [WeatherInfo]()
        var components = URLComponents(string: baseURL)
        
        for cityId in cityIds {
            
            //파마리터 설정
            let cityId = URLQueryItem(name: "id", value: "\(cityId)")
            let language = URLQueryItem(name: "lang", value: "kr")
            let units = URLQueryItem(name: "units", value: "metric")
            let clientSecret = URLQueryItem(name: "appid", value: "\(clientSecret)")
            
            components?.queryItems = [cityId, language, units, clientSecret]
            
            guard let requestURL = components?.url else { return }
            let request = URLRequest(url: requestURL)
            
            //데이터 호출
            let dataTask = session.dataTask(with: request) { data, response, error in
                
                //에러 확인
                if error != nil {
                    print(error!)
                    return
                }
                
                //결과값 200 확인
                if let httpURLResponse = response as? HTTPURLResponse {
                    if httpURLResponse.statusCode != 200 {
                        print("Fail to get data")
                        return
                    }
                }
                
                if let safeData = data {
                    do {
                        //Json 데이터 Decode
                        var weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: safeData)
                        
                        if let cityName = weatherInfo.cityName {
                            //도시 이름 변경
                            weatherInfo.cityName = self.ChangeCityName(cityName: cityName)
                        }
                        WeatherInfos.append(weatherInfo)
                        // 도시 정보 수신 완료시
                        if(WeatherInfos.count == self.cityIds.count) {
                            //올름차순으로 정렬
                            WeatherInfos.sort { info1, info2 in
                                //nil값일때 뒤로 이동
                                guard let name1 = info1.cityName else { return false }
                                guard let name2 = info2.cityName else { return true}
                                
                                return name1 < name2
                            }
                            var imageDownlaodCount = 0
                            //날씨 정보 아이콘 이미지 다운로드
                            for weatherInfo in WeatherInfos {
                                if let weatherIcon = weatherInfo.weather?[0].icon {
                                    self.downloadImage(imageIcon: weatherIcon) { result in
                                        switch result {
                                        case .success(let image) :
                                            WeatherInfos[imageDownlaodCount].weatherImage = image
                                            imageDownlaodCount += 1
                                            //다운로드 완료
                                            if imageDownlaodCount == self.cityIds.count {
                                                handler(.success(WeatherInfos))
                                            }
                                        case .failure(let error) :
                                            print("Fail To Download Image", error)
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            dataTask.resume()   
        }
    }
    
    //유저 위치 날씨 정보 가져오기
    func getUserLoactionWeatherInfo(longitude: Double, latitude: Double,handler: @escaping (Result<WeatherInfo , Error>) -> ()) {
        let session = URLSession(configuration: .default)
        var components = URLComponents(string: baseURL)
        
        //파라미터 추가
        let latitude = URLQueryItem(name: "lat", value: "\(latitude)")
        let longitude = URLQueryItem(name: "lon", value: "\(longitude)")
        let language = URLQueryItem(name: "lang", value: "kr")
        let units = URLQueryItem(name: "units", value: "metric")
        let clientSecret = URLQueryItem(name: "appid", value: "\(clientSecret)")
        components?.queryItems = [latitude, longitude, language, units, clientSecret]
        
        guard let requestURL = components?.url else { return }
        let request = URLRequest(url: requestURL)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            //에러 확인
            if error != nil {
                print(error!)
                return
            }
            
            //결과값 200 확인
            if let httpURLResponse = response as? HTTPURLResponse {
                if httpURLResponse.statusCode != 200 {
                    print("Fail to get data")
                    return
                }
            }
            
            if let safeData = data {
                do {
                    //Json 데이터 Decode
                    var weatherInfo = try JSONDecoder().decode(WeatherInfo.self, from: safeData)
                    
                    if let weatherIcon = weatherInfo.weather?[0].icon {
                        self.downloadImage(imageIcon: weatherIcon) { result in
                            switch result {
                            case .success(let image) :
                                weatherInfo.weatherImage = image
                                handler(.success(weatherInfo))
                            case .failure(let error) :
                                print("Fail To Download User image", error)
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        dataTask.resume()
    }

    
    //이미지 다운로드
    func downloadImage(imageIcon : String ,compltion: @escaping (Result<UIImage, Error>) -> ()) {
        
        guard let imageDownloadURL = URL(string: imageDownloadURL + "\(imageIcon)@2x.png") else { return }
        
        if let cacheImage = Cache.imageCache.object(forKey: imageDownloadURL.absoluteString as NSString){
            print("It's have cacheImage")
            compltion(.success(cacheImage))
            return
        } else {
            
            var request = URLRequest(url: imageDownloadURL)
            request.httpMethod = "Get"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let httpURLResponse = response as? HTTPURLResponse {
                    if httpURLResponse.statusCode != 200 {
                        print("Fail to get data")
                        return
                    }
                }
                
                guard let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                      let imageData = data, let image = UIImage(data: imageData) else
                {
                    print("Fail to download image")
                    return
                }
                
                Cache.imageCache.setObject(image, forKey: imageDownloadURL.absoluteString as NSString)
                compltion(.success(image))
            }.resume()
        }
    }
    
    //도시 이름 영어 -> 한국 변경
    private func ChangeCityName(cityName : String) -> String {
        switch cityName {
        case "Gongju" :
            return "공주"
        case "Gwangju" :
            return "광주"
        case "Gumi" :
            return "구미"
        case "Gunsan" :
            return "군산"
        case "Daegu" :
            return "대구"
        case "Daejeon" :
            return "대전"
        case "Mokpo" :
            return "목포"
        case "Busan" :
            return "부산"
        case "Seosan City" :
            return "서산"
        case "Seoul" :
            return "서울"
        case "Sokcho" :
            return "속초"
        case "Suwon-si" :
            return "수원"
        case "Suncheon" :
            return "순천"
        case "Ulsan":
            return "울산"
        case "Iksan":
            return "익산"
        case "Jeonju" :
            return "전주"
        case "Jeju City" :
            return "제주"
        case "Cheonan" :
            return "천안"
        case "Cheongju-si" :
            return "청주"
        case "Chuncheon" :
            return "춘천"
        default :
            return "미상"
        }
    }
    
}
