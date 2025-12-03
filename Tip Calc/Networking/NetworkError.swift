//
//  NetworkError.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 03/12/2025.
//

import Foundation

enum NetworkError: Error {
    case unauthorized
    case notFound
    case serverError
    case missingRequiredFields
    case redirection(status: Int)
    case clientError(status: Int)
    case unexpectedStatus(Int)
    case transport(Error)
    case noData
    case decodingError(Error)
}

enum ViewError: Identifiable {
    var id: String { localizedDescription }

    case unauthorized
    case notFound
    case serverError
    case missingRequiredFields
    case generic

    var localizedDescription: String {
        switch self {
        case .unauthorized: return "You are not authorized."
        case .notFound: return "Resource not found."
        case .serverError: return "Internal server error."
        case .missingRequiredFields: return "Wrong data provided. Please try again."
        case .generic: return "Something went wrong."
        }
    }
}

extension ViewError {
    static func from(_ network: NetworkError) -> ViewError {
        switch network {
        case .unauthorized: return .unauthorized
        case .notFound: return .notFound
        case .serverError: return .serverError
        case .missingRequiredFields: return .missingRequiredFields
        default: return .generic
        }
    }
}
