//
//  RequestManager.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 03/12/2025.
//

import Foundation
import Supabase

final class RequestManager {

    let supabase = SupabaseClient(
      supabaseURL: URL(string: "https://itiaamztvjznrxonspvb.supabase.co")!,
      supabaseKey: "sb_secret_ECxS_tdi7XjikFnkK9KemA_IiMbpXT1"
    )

    static let shared = RequestManager()
    private init() {}

    private let requestService: RequestService = URLSession.shared
    #if DEBUG
    private let baseStringURL = "http://localhost:3000"
    #else
    private let baseStringURL = "https://serwivs:3000" // znalazl serwis gdzie wrzucimy nasz serwer
    #endif
}


private extension RequestManager {
    func perform<T: Decodable>(
        request: URLRequest,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        requestService.dataTask(with: request) { [weak self] data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.transport(error)))
                }
                return
            }
            
            guard let http = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.unexpectedStatus(-2)))
                }
                return
            }
            
            if let statusError = self?.mapHTTPStatus(http.statusCode) {
                DispatchQueue.main.async {
                    completion(.failure(statusError))
                }
                return
            }
            
            guard let data, data.count > 0 else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
            
        }.resume()
    }
    
    private func mapHTTPStatus(_ status: Int) -> NetworkError? {
        switch status {
        case 200..<300:
            return nil
        case 300..<400:
            return .redirection(status: status)
        case 400:
            return .missingRequiredFields // badRequest
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 400..<500:
            return .clientError(status: status)
        case 500..<600:
            return .serverError
        default:
            return .unexpectedStatus(status)
        }
    }
}

extension RequestManager {
    func send<T: Codable>(
        item: T,
        to path: String
    ) async throws -> PostgrestResponse<Void> {
        do {
            return try await supabase
            .from(path)
            .insert(item)
            .execute()
        } catch {
            throw error
        }
    }
    
    func get(
        from path: String
    ) async throws -> PostgrestResponse<Void> {
        do {
            return try await supabase
                .from(path)
                .select()
                .execute()
        } catch {
            throw error
        }
    }
    
    func send<T: Decodable, Body: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        query: [String: String]? = nil,
        body: Body,
        responseType: T.Type = EmptyResponse.self,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard var components = URLComponents(string: baseStringURL) else {
            completion(.failure(.unexpectedStatus(-1)))
            return
        }
        components.path += "/\(endpoint)"
        
        if let query = query {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            completion(.failure(.unexpectedStatus(-1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.transport(error)))
            return
        }
        
       

        perform(request: request, responseType: T.self, completion: completion)
    }
}

extension RequestManager {
    func send<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        query: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard var components = URLComponents(string: baseStringURL) else {
            completion(.failure(.unexpectedStatus(-1)))
            return
        }
        components.path += "/\(endpoint)"
        
        if let query = query {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            completion(.failure(.unexpectedStatus(-1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        perform(request: request, responseType: responseType, completion: completion)
    }
}

struct EmptyResponse: Codable {}
