//
//  CatAPIClient.swift
//  MyPetPlanner
//
//  Created by Lidia on 05/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import UIKit

class CatAPIClient {
    enum Endpoints {
        case getCatsList
        
        var stringValue: String {
            switch self {
            case .getCatsList:
                return "https://api.thecatapi.com/v1/breeds"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            /// JSON parsing code
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func getCatsList(completion: @escaping ([CatResponse], Error?) -> Void) {
        let catsListURL = Endpoints.getCatsList.url
        
        taskForGETRequest(url: catsListURL, responseType: [CatResponse].self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion([], error)
            }
        }
    }
    
}
