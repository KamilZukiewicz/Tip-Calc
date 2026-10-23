//
//  AuthState.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 20/10/2026.
//


enum AuthState {
    case loading
    case authenticated
    case signedOut
    case error(String)
}

extension AuthState {
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
}
