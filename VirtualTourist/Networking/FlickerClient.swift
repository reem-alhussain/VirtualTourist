//
//  FlickerClient.swift
//  VirtualTourist
//
//  Created by Reem on 05/07/2019.
//  Copyright © 2019 Reem. All rights reserved.
//

import Foundation

class FlickerClient {
    
    // MARK: - Variables
    private var tasks: [String: URLSessionDataTask] = [:]
    
    // MARK: Shared Instance
    class func shared() -> FlickerClient {
        struct Singleton {
            static var shared = FlickerClient()
        }
        return Singleton.shared
    }
    
    
    // MARK: - HTTP Tasks
    func taskForGETRequest( customUrl: URL? = nil, url: URL, completion: @escaping (Data?, NSError?) -> Void) -> URLSessionDataTask {
        var requestURL  = NSMutableURLRequest(url: url)
        if let customUrl = customUrl {
            requestURL = NSMutableURLRequest(url: customUrl) 
        }
        let task = URLSession.shared.dataTask(with: requestURL as URLRequest) { data, response, error in
             if let error = error {
                if (error as NSError).code == URLError.cancelled.rawValue {
                    DispatchQueue.main.async {
                        completion(nil, nil)}
                } else {
                    completion(nil, NSError(domain: "taskForGETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "There was an error with the request: \(error.localizedDescription)"]))
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, NSError(domain: "taskForGETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "The request status code is invalid!"]))
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "taskForGETRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "No data was returned!"]))
                return
            }
            
            completion(data, nil)
        }
        task.resume()
        return task
    }
    
    
    // MARK: - API Calls
    func searchBy(latitude: Double, longitude: Double, totalPages: Int?, completion: @escaping (_ result: PhotosResponse?, _ error: Error?) -> Void) {
        
        // Random page
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/ParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        
        let bbox = getBboxString(lat: latitude, lng: longitude)
        
        let parameters = [
            ParametersKeys.Method           : ParameterValues.SearchMethod
            , ParametersKeys.APIKey         : ParameterValues.APIKey
            , ParametersKeys.Format         : ParameterValues.ResponseFormat
            , ParametersKeys.Extras         : ParameterValues.MediumURL
            , ParametersKeys.NoJSONCallback : ParameterValues.DisableJSONCallback
            , ParametersKeys.SafeSearch     : ParameterValues.UseSafeSearch
            , ParametersKeys.BoundingBox    : bbox
            , ParametersKeys.PhotosPerPage  : "\(ParameterValues.PhotosPerPage)"
            , ParametersKeys.Page           : "\(page)"
        ]
        
        _ = taskForGETRequest(url: url(from: parameters)) { response, error in
            if let response = response {
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(PhotosResponse.self, from: response)
                        completion(responseObject, nil)
                } catch {
                        completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    func downloadImage(imageUrl: String, result: @escaping (_ result: Data?, _ error: NSError?) -> Void) {
        guard let url = URL(string: imageUrl) else {return}
        let task = taskForGETRequest(url: url) { (data, error) in
            result(data, error)
            self.tasks.removeValue(forKey: imageUrl)
        }
        if tasks[imageUrl] == nil {
            tasks[imageUrl] = task
        }
    }
    
    
    
}


extension FlickerClient{
    
    // Helpers
    private func url(from parameters: [String: String]) -> URL {
        
        var components = URLComponents()
        components.scheme = Base.APIScheme
        components.host = Base.APIHost
        components.path = Base.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    func getBboxString(lat: Double, lng: Double) -> String {
        let minimumLon = max(lng - Base.SearchBBoxHalfWidth, Base.SearchLonRange.0)
        let minimumLat = max(lat  - Base.SearchBBoxHalfHeight, Base.SearchLatRange.0)
        let maximumLon = min(lng + Base.SearchBBoxHalfWidth, Base.SearchLonRange.1)
        let maximumLat = min(lat  + Base.SearchBBoxHalfHeight, Base.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    func stopDownloading(_ imageUrl: String) {
        tasks[imageUrl]?.cancel()
        if tasks.removeValue(forKey: imageUrl) != nil {
            print("Task stopped: \(imageUrl)")
        }
    }

}
