//
//  REST.swift
//  Carangas
//
//  Created by Usuário Convidado on 14/04/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

enum RESTError {
    case url
    case noResponse
    case noData
    case invalidJSON
    case taskError(error: Error?)
    case responseStatusCode(code: Int)
}

enum RESTOperation: String {
    case get = "GET"
    case update = "PUT"
    case delete = "DELETE"
    case save = "POST"
}

class REST {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let fipePath = "https://fipeapi.appspot.com/api/1/carros/marcas.json"
    
    private static let sessionConfiguration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        config.timeoutIntervalForRequest = 40.0
        config.httpMaximumConnectionsPerHost = 4
        return config
    }()
    private static let session = URLSession(configuration: sessionConfiguration)
  
    private class func request<T: Codable>(url: URL, body: Data? = nil, operation: RESTOperation = RESTOperation.get, onComplete: @escaping (T?, RESTError?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = operation.rawValue
        if body != nil {
            request.httpBody = body
        }
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                onComplete(nil, .taskError(error: error))
                return
            } else {
                guard let response = response as? HTTPURLResponse else {
                    onComplete(nil, .noResponse)
                    return
                }
                if response.statusCode == 200 {
                    guard let data = data else {
                        onComplete(nil, .noData)
                        return
                    }
                    do {
                        let obj = try JSONDecoder().decode(T.self, from: data)
                        onComplete(obj, nil)
                    } catch {
                        onComplete(nil, .invalidJSON)
                    }
                } else {
                    onComplete(nil, .responseStatusCode(code: response.statusCode))
                }
            }
        }
        dataTask.resume()
    }
    
    class func loadCars(onComplete: @escaping ([Car]?, RESTError?) -> Void) {
        guard let url = URL(string: basePath) else {
            onComplete(nil, .url)
            return
        }
        request(url: url) { (cars: [Car]?, error) in
            onComplete(cars, error)
        }
    }
    
    class func loadBrands(onComplete: @escaping ([Brand]?, RESTError?) -> Void) {
        guard let url = URL(string: fipePath) else {
            return
        }
        request(url: url) { (brands: [Brand]?, error) in
            onComplete(brands, error)
        }
    }
    
    class func saveCar(_ car: Car, onComplete: @escaping (Bool) -> Void) {
        let urlString = "\(basePath)/\(car._id ?? "")"
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        guard let body = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request(url: url, body: body, operation: RESTOperation.save) { (any: EmptyResponse?, error) in
            onComplete(error == nil)
        }
    }
    
    class func updateCar(_ car: Car, onComplete: @escaping (Bool) -> Void) {
        let urlString = "\(basePath)/\(car._id ?? "")"
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        guard let body = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request(url: url, body: body, operation: RESTOperation.update) { (any: EmptyResponse?, error) in
            onComplete(error == nil)
        }
    }
    
    class func deleteCar(_ car: Car, onComplete: @escaping (Bool) -> Void) {
        let urlString = "\(basePath)/\(car._id ?? "")"
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        guard let body = try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        request(url: url, body: body, operation: RESTOperation.delete) { (any: EmptyResponse?, error) in
            onComplete(error == nil)
        }
    }
    
//    class func applyOperation(car: Car, operation: RESTOperation, onComplete: @escaping (Bool) -> Void) {
//        let urlString = "\(basePath)/\(car._id ?? "")"
//        let httpMethod = operation.rawValue
//        guard let url = URL(string: urlString) else {
//            onComplete(false)
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = httpMethod
//        guard let httpBody = try? JSONEncoder().encode(car) else {
//            onComplete(false)
//            return
//        }
//        request.httpBody = httpBody
//        let dataTask = session.dataTask(with: request) { (data, response, error) in
//            if error == nil {
//                if let response = response as? HTTPURLResponse {
//                    if response.statusCode == 200 {
//                        onComplete(true)
//                    }
//                }
//            }
//            onComplete(false)
//        }
//        dataTask.resume()
//    }
    struct EmptyResponse: Codable { }
}
