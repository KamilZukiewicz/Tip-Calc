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
