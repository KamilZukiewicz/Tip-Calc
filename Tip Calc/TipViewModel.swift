//
//  TipViewModel.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 18/08/2025.
//

import SwiftUI

struct UserData: Identifiable { // preset
    var id: UUID = UUID()
    var tipPercent: Double
    var people: Int
    var currencyCode: ContentView.Currencies
}

struct HistoryData: Codable, Identifiable { // Tip
    var id: UUID = UUID()
    var date: Date
    var amount: Double
    var tipPercent: Double
    var perPerson: Double
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

class TipViewModel : ObservableObject {
    @Published var amount: Double = 0.0
    @Published var tipPercent: Double = 10.0
    @Published var people: Int = 1
    @Published var currencyCode: ContentView.Currencies = .PLN
    @Published var formatedCurrency: String = ""
    @Published var history: [HistoryData] = []
    @Published var userData: [UserData] = []
    
    private let baseStringURL = "http://localhost:3000" // + ścieżki
    
    func getTipHistoryFromServer() {
        // Stworzenie adresu
        guard let url = URL(string: baseStringURL)?.appendingPathComponent("tips") else {
            print("String URL was bad")
            return
        }
        
        // Stworzenie requestu
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Wysłanie requestu
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error {
                print(error)
                return
            }
            if let data {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let decodedHistory = try? JSONDecoder().decode([HistoryData].self, from: data) {
                        DispatchQueue.main.async {
                            self.history = decodedHistory
                        }
                    }
                }
            }
        }.resume()
    }
    
    func sendTipToServer(tip: HistoryData) {
        guard let url = URL(string: baseStringURL)?.appendingPathComponent("tips") else {
            print("String URL was bad")
            return
        }
        // url = "http://localhost:3000" + /tips
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Request - to obiekt który posiada adres do serwera oraz niezbędne metody do komunikacji
        
        guard let body = try? JSONEncoder().encode(tip) else {
            print("Encoidng tip to JSON failed")
            return
        }
        
        /* body = {
             id:  "jakis id"
             date: "2025.09.17"
             amount: "1234"
             tipPercent: "10%"
             perPerson: "300"
         }
         */
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                self.getTipHistoryFromServer()
            }
        }.resume()
    }
    
    func tip(amount: Double, percent: Double) -> Double {
        return amount * (percent / 100.0)
    }
    
    func total(amount: Double, percent: Double) -> Double {
        return amount + tip(amount: amount, percent: percent)
    }
    
    func perPerson(amount: Double, percent: Double, people: Int) -> Double {
        return total(amount: amount, percent: percent) / Double(people)
    }

    func formatCurrency(currencyCode: ContentView.Currencies) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = currencyCode.rawValue
        formatter.numberStyle = .currency
        let test = formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
        return test
    }
    
    func applyPreset() {
        if userData.isEmpty {
            addPreset()
        } else {
            applyPresent()
        }
    }
    
    func addPreset() {
        let userData = UserData(tipPercent: tipPercent, people: people, currencyCode: currencyCode)
        self.userData.append(userData)
    }
    
    func applyPresent() {
        if let lastUserData = userData.last {
            self.tipPercent = lastUserData.tipPercent
            self.people = lastUserData.people
            self.currencyCode = lastUserData.currencyCode
        }
    }
    
    func applyPresent(for userData: UserData) {
        self.tipPercent = userData.tipPercent
        self.people = userData.people
        self.currencyCode = userData.currencyCode
    }
}
