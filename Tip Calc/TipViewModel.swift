//
//  TipViewModel.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 18/08/2025.
//

import SwiftUI

struct UserData: Identifiable { // preset
    var id: UUID = UUID()
    var tipPercent: Int32
    var people: Int
    var currencyCode: Currencies
}

struct HistoryData: Codable, Identifiable, Equatable { // Tip
    var id: UUID = UUID()
    var date: Date
    var amount: Double
    var tipPercent: Int32
    var perPerson: Double
}

struct CurrencyData: Codable {
    let rates: [Rates]
    
    struct Rates: Codable {
        let mid: Double
    }
}


class TipViewModel : ObservableObject {
    @Published var amount: Double = 0.0
    @Published var tipPercent: Int32 = 10
    @Published var people: Int = 1
    @Published var currencyCode: Currencies = .PLN
    @Published var currencyCodeConverted: CurrenciesConverted = .EUR
    @Published var formatedCurrency: String = ""
    @Published var history: [HistoryData] = []
    @Published var userData: [UserData] = []
    @Published var error: TipError?
    @Published var shouldDisplayError: Bool = false
    
    @Published var currencyData: CurrencyData?
    @Published var euroRate: Double?
    @Published var usdRate: Double?
    @Published var viewError: ViewError?
    private let requestManager = RequestManager.shared
    private let requestService: RequestService
    private let baseStringURL: String
 
    /*
     Aktualnie model komunikuje się tylko z localhost, i to jest ok dla DEBUG.
     TRZEBA dodać url dla serwera (bazy danych) dla PROD.
     */
    
    init(baseStringURL: String = "http://localhost:3000", requestService: RequestService = URLSession.shared) {
        self.requestService = requestService
        self.baseStringURL = baseStringURL
    }
    
    func getTipHistoryFromServer() async {
//        requestManager.send(endpoint: "tips", method: .GET, responseType: [HistoryData].self) { [weak self] result in
//            switch result {
//            case .success(let decodedHistory):
//                self?.history = decodedHistory
//            case .failure(let error):
//                self?.viewError = .from(error)
//                self?.shouldDisplayError = true
//            }
//        }
        let result = try? await requestManager.get(from: "HistoryData")
        
        guard let result else {
            return
        }
        
        print(result)
    }
    
    func sendTipToServer(tip: HistoryData) async {
        let result = try? await requestManager.send(item: tip, to: "HistoryData")
        
        guard let result else {
            return
        }
        
        print(result)
            
//        requestManager.send(
//            endpoint: "tips",
//            method: .POST,
//            body: tip) { [weak self] result in
//                switch result {
//                case .success:
//                    self?.getTipHistoryFromServer()
//                case .failure(let error):
//                    self?.viewError = .from(error)
//                    self?.shouldDisplayError = true
//                }
//            }
    }
    
    /*
     POST = HistoryData -> Codable -> JSON -> Data (BODY)
     GET = facebook.com/authentication?userId=123&privilige=admin&scope=all
     */
    
    func deleteTipFromServer(tip: HistoryData) {
        requestManager.send(
            endpoint: "tips",
            method: .DELETE,
            query: ["id": tip.id.uuidString],
            responseType: EmptyResponse.self) { [weak self] result in
                switch result {
                case .success:
                    Task {
                        await self?.getTipHistoryFromServer()
                    }
                case .failure(let error):
                    self?.viewError = .from(error)
                    self?.shouldDisplayError = true
                }
            }
    }
    
    func tipPercentRoundedValue(_ value: Double) -> Int32 {
        let numberOfPlaces = 0.0
        let multiplier = pow(10.0, numberOfPlaces)
        let rounded = round(value * multiplier) / multiplier
        return Int32(rounded)
    }
    
    func tip(amount: Double, percent: Int32) -> Double {
        return amount * Double((percent / 100))
    }
    
    func total(amount: Double, percent: Int32) -> Double {
        return amount + tip(amount: amount, percent: percent)
    }
    
    func perPerson(amount: Double, percent: Int32, people: Int) -> Double {
        return total(amount: amount, percent: percent) / Double(people)
    }
    
    func formatCurrency(currencyCode: Currencies) -> String {
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
        guard let lastUserData = userData.last else { return } 
            self.tipPercent = lastUserData.tipPercent
            self.people = lastUserData.people
            self.currencyCode = lastUserData.currencyCode
        
    }
    
    func applyPresent(for userData: UserData) {
        self.tipPercent = userData.tipPercent
        self.people = userData.people
        self.currencyCode = userData.currencyCode
    }
    
    func userDataFormattedDetailsFrom(_ userData: UserData) -> String {
        let currency = "Currency: \(userData.currencyCode.rawValue)" + "\n"
        let numberOfPeople = "Per person: \(userData.people)" + "\n"
        let percent = "Percent: \(userData.tipPercent)"
        return "\(currency)\(numberOfPeople)\(percent)"
    }
    
    func resetButton() {
        amount = 0.0
        tipPercent = 10
        people = 1
        currencyCode = .PLN
    }
    
    func downloadEUR() {
        guard let url = URL(string: "https://api.nbp.pl/api/exchangerates/rates/a/eur/?format=json") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("Network error: \(error)")
                return
            }
            guard let data else { return }
            do {
                let decoded = try JSONDecoder().decode(CurrencyData.self, from: data)
                DispatchQueue.main.async {
                    self.euroRate = decoded.rates.first?.mid
                }
            } catch {
                print("Error JSON: \(error)")
            }
        }.resume()
    }
    
    func downloadUSD() {
        guard let url = URL(string: "https://api.nbp.pl/api/exchangerates/rates/a/usd/?format=json") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("Network error: \(error)")
                return
            }
            guard let data else { return }
            do {
                let decoded = try JSONDecoder().decode(CurrencyData.self, from: data)
                DispatchQueue.main.async {
                    self.usdRate = decoded.rates.first?.mid
                }
            } catch {
                print("Error JSON: \(error)")
            }
        }.resume()
    }
    
    func convertedTip() -> Double? {
        guard let rate = exhangeRate(from: currencyCode, to: currencyCodeConverted) else {
            return nil
        }
        let tipValue = tip(amount: amount, percent: tipPercent)
        return rate * tipValue
    }
    
    func convertedTotal() -> Double? {
        guard let rate = exhangeRate(from: currencyCode, to: currencyCodeConverted) else {
            return nil
        }
        let totalValue = total(amount: amount, percent: tipPercent)
        return rate * totalValue
    }
    
    func convertedPerPerson() -> Double? {
        guard let rate = exhangeRate(from: currencyCode, to: currencyCodeConverted) else {
            return nil
        }
        let perPersonValue = perPerson(amount: amount, percent: tipPercent, people: people)
        return rate * perPersonValue
    }
    
    func exhangeRate(from: Currencies, to: CurrenciesConverted) -> Double? {
        guard let euroRate,
              let usdRate else {
            return nil
        }
        switch (from, to) {
        case (.PLN, .EUR): return 1.0 / euroRate
        case (.PLN, .USD): return 1.0 / usdRate
        case (.EUR, .PLN): return euroRate
        case (.USD, .PLN): return usdRate
        case (.EUR, .USD): return euroRate / usdRate
        case (.USD, .EUR): return usdRate / euroRate
        case (.USD, .USD): return 1.0
        case (.EUR, .EUR): return 1.0
        case (.PLN, .PLN): return 1.0
        }
    }
}
