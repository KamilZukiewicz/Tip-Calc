//
//  SignUpView.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 26/10/2026.
//

import SwiftUI

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let errorMessage: String?
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            TextField("E-mail", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            SecureField("Password", text: $password)
            if let errorMessage { Text(errorMessage) }
            Button("Zarejestruj się") {
                Task { await authViewModel.signUp(email: email, password: password) }
            }
            .disabled(authViewModel.isSubmitting)
        }
    }
}
