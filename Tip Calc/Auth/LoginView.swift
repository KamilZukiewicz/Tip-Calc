//
//  LoginView.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 20/10/2026.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let errorMessage: String?
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        VStack {
            TextField("E-mail", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("Password", text: $password)
            if let errorMessage { Text(errorMessage) }
            Button("Login") {
                Task { await authViewModel.signIn(email: email, password: password) }
            }
            .disabled(authViewModel.isSubmitting)
            Button("Nie masz konta? Zarejestruj się") {
                showSignUp = true
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(authViewModel: authViewModel, errorMessage: errorMessage)
        }
    }
}
