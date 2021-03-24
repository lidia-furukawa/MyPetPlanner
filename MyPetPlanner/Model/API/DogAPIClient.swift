//
//  DogAPIClient.swift
//  MyPetPlanner
//
//  Created by Lidia on 03/03/21.
//  Copyright © 2021 LidiaF. All rights reserved.
//

import Foundation
import UIKit

class DogAPIClient {
    enum Endpoints {
        case getBreedsList
        case getRandomImageForBreed(String)

        var stringValue: String {
            switch self {
            case .getBreedsList:
                return "https://dog.ceo/api/breeds/list/all"
            case .getRandomImageForBreed(let breed):
                return "https://dog.ceo/api/breed/\(breed)/images/random"
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
    
    class func getBreedsList(completion: @escaping ([String], Error?) -> Void) {
        let breedsListURL = Endpoints.getBreedsList.url
        
        taskForGETRequest(url: breedsListURL, responseType: BreedsListResponse.self) { response, error in
            if let response = response {
                var breeds: [String] = []
                
                for breed in response.message {
                    if breed.value != [] {
                        for subBreed in breed.value {
                            breeds.append("\(subBreed) \(breed.key)")
                        }
                    } else {
                        breeds.append(breed.key)
                    }
                }
                let capitalizedBreeds = breeds.map { $0.capitalized }
                completion(capitalizedBreeds.sorted(), nil)
            } else {
                completion([], error)
            }
        }
    }
    
}
