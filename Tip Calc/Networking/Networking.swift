//
//  Untitled.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 25/11/2025.
//

import SwiftUI

enum HTTPMethod: String { 
    case GET
    case POST
    case PUT
    case DELETE
}

enum TipError: Error {
    case badRequest
    case notFound
    
    var description: String {
        switch self {
        case .badRequest:
            return "Upps! Coś poszło źle!"
        case .notFound:
            return "Nie znaleziono"
        }
    }
}

protocol RequestServiceTask {
    func resume()
}

protocol RequestService {
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> RequestServiceTask
}

extension URLSessionDataTask: RequestServiceTask {}

extension URLSession: RequestService {
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> RequestServiceTask {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask)
    }
}

class MockDataTask: RequestServiceTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    func resume() {
        closure()
    }
}

class MockURLSession<T: Codable>: RequestService {
    let responseData: T?
    let httpURLResponse: HTTPURLResponse?
    
    init(responseData: T? = nil, httpURLResponse: HTTPURLResponse? = nil) {
        self.responseData = responseData
        self.httpURLResponse = httpURLResponse
    }
    
    func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> RequestServiceTask {
        return MockDataTask { [responseData] in
            if let httpURLResponse = self.httpURLResponse {
                completionHandler(nil, httpURLResponse, nil)
            } else {
                let data = try? JSONEncoder().encode(responseData)
                DispatchQueue.main.async {
                    completionHandler(data, nil, nil)
                }
            }
        }
    }
}

