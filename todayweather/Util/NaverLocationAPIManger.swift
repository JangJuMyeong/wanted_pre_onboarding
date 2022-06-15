//
//  NaverLocationAPIManger.swift
//  todayweather
//
//  Created by 장주명 on 2022/06/12.
//

import Foundation

class NaverLocationAPIManger {
    
    static let shared = NaverLocationAPIManger()
    
    private let baseURL = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc"
    private let clientId = "s5i7jnator"
    private let clientSecret = "BWtPql0l9SQxf43NjZklQbyvZHDF05uKtSHZVxIO"
    
    private init() {
        
    }
    
    // 위치 정보 가져오기
    func getLocation(longitude: Double, latitude: Double, handler: @escaping(Result<String,Error>) -> Void) {
        
        let session = URLSession(configuration: .default)
        var components = URLComponents(string: baseURL)
        //파라미터 추가
        let coords = URLQueryItem(name: "coords", value: "\(longitude),\(latitude)")
        let output = URLQueryItem(name: "output", value: "json")
        components?.queryItems = [coords, output]
        
        guard let requestURL = components?.url else { return }
        var request = URLRequest(url: requestURL)
        //해더 값 설정
        request.addValue(clientId, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
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
            
            //Json객체에서 정보 가져오기
            if let safeData = data {
                if let json = try? JSONSerialization.jsonObject(with: safeData, options: []) as? [String : Any] {
                    if let results = json["results"] as? [Any]{
                        if let data = results[0] as? [String : Any]{
                            if let region = data["region"] as? [String : Any] {
                                if let area = region["area2"] as? [String : Any] {
                                    if var location = area["name"] as? String {
                                        if location.contains("시") {
                                            location = String(location.dropLast())
                                        }
                                        handler(.success(location))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        dataTask.resume()
    }
}
