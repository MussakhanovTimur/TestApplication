//
//  NetworkService.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import Foundation
import Alamofire

class NetworkService {
    
    func fetchTracks(searchText: String, comletion: @escaping (SearchResponse?) -> Void) {
        let url = "https://itunes.apple.com/search"
        let paramsURL = ["term":"\(searchText)", "limit":"25", "media":"music"]
        
        AF.request(url, method: .get,
                   parameters: paramsURL,
                   encoding: URLEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil).responseData { (dataResponse) in
                    if let error = dataResponse.error {
                        print(error.localizedDescription)
                        comletion(nil)
                        return
                    }
                    
                    guard let data = dataResponse.data else { return }
                    let decoder = JSONDecoder()
                    do {
                        let objects = try decoder.decode(SearchResponse.self, from: data)
                        comletion(objects)
//                        print(objects)
                    } catch let jsonError {
                        print(jsonError.localizedDescription)
                        comletion(nil)
                    }
                    
                    
                    //                let someString = String(data: data, encoding: .utf8)
                    //                print(someString ?? "")
        }
    }
}
