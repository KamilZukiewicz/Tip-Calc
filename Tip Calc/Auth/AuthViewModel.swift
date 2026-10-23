//
//  AuthViewModel.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 20/10/2026.
//

import SwiftUI
import Supabase



@MainActor
final class AuthViewModel: ObservableObject {
    @Published var state: AuthState = .loading
    @Published var isSubmitting = false
    
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func signIn(email: String, password: String) async {
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await client.auth.signIn(email: email, password: password)
            state = .authenticated
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func checkSession() async {
        do {
            _ = try await client.auth.session
            state = .authenticated
        } catch {
            state = .signedOut
        }
        
    }
    
    func signUp(email: String, password: String) async {
        
    }
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            state = .signedOut
        } catch {
            // session still ongoing
        }
        
    }
}
