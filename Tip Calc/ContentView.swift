//
//  ContentView.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 18/08/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var tipViewModel = TipViewModel()
    @State private var isEditing = false
    @State private var roundUp: Bool = false
    @FocusState private var isFocused: Bool
    @State private var showMenu = false 
    
    @State private var isConfirming = false

    let step = 1
    let range = 1...30
    
    enum Currencies: String, CaseIterable, Identifiable {
        case PLN, EUR, USD
        var id: Self { self }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Constants.spacing) {
                    
                    Text("Tip Calc")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7))
                    
                    billValueView()
                    
                    tipSettingsView()
                    
                    amountShowView()
                    
                    buttonView()
                    
                    historyView()
                    
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            tipViewModel.getTipHistoryFromServer()
        }
    }
    
    private func billValueView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                HStack {
                    TextField("Kwota rachunku w \(tipViewModel.currencyCode.rawValue)", value: $tipViewModel.amount, format: .number)
                        .keyboardType(.numberPad)
                        .padding(7)
                        .onChange(of: tipViewModel.amount) { oldValue, newValue in
                            tipViewModel.formatedCurrency = tipViewModel.formatCurrency(currencyCode: tipViewModel.currencyCode)
                        }
                        .focused($isFocused)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(20)
                }
            }
        }
    }
    private func tipSettingsView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                HStack {
                    Slider(value: $tipViewModel.tipPercent,
                           in: 0...50,
                           step: 5)
                    {
                        Text("Procent")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("50")
                    } onEditingChanged: { editing in
                        isEditing = editing
                    }
                }
                Text("\(Int(tipViewModel.tipPercent))%")
                    .foregroundColor(isEditing ? .red : .white)
                
                HStack {
                    Text("Liczba osób: \(tipViewModel.people)")

                    Stepper(
                        value: $tipViewModel.people,
                        in: range,
                        step: step
                    ) {
                    
                    }
                    .tint(Color.blue.opacity(0.2))
                }
                VStack {
                    
                    Text("Wybierz walutę:")
                    Picker("Waluta", selection: $tipViewModel.currencyCode) {
                        Text("Polski złoty").tag(Currencies.PLN)
                        Text("Euro").tag(Currencies.EUR)
                        Text("Dolar").tag(Currencies.USD)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.blue.opacity(0.2))
                    
                    Text("Przelicz na walutę:")
                    Picker("Waluta", selection: $tipViewModel.currencyCode) {
                        Text("Polski złoty").tag(Currencies.PLN)
                        Text("Euro").tag(Currencies.EUR)
                        Text("Dolar").tag(Currencies.USD)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.blue.opacity(0.2))
                }
            }
        }
    }
    private func amountShowView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                
                HStack {
                    Text("Kwota napiwku:")
                    Spacer()
                    Text("\(tipViewModel.tip(amount: tipViewModel.amount, percent: tipViewModel.tipPercent), specifier: "%.2f") \(tipViewModel.currencyCode.rawValue)")
                        .bold()
                }
                
                HStack {
                    Text("Do zapłaty łącznie:")
                    Spacer()
                    Text("\(tipViewModel.total(amount: tipViewModel.amount, percent: tipViewModel.tipPercent), specifier: "%.2f") \(tipViewModel.currencyCode.rawValue)")
                        .bold()
                }
                
                HStack {
                    Text("Na osobę:")
                    Spacer()
                    Text("\(tipViewModel.perPerson(amount: tipViewModel.amount, percent: tipViewModel.tipPercent, people: tipViewModel.people), specifier: "%.2f") \(tipViewModel.currencyCode.rawValue)")
                        .bold()
                }
            }
            .padding()
        }
    }
    
    private func buttonView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                Button("Reset") {
                    tipViewModel.amount = 0.0
                    tipViewModel.tipPercent = 10.0
                    tipViewModel.people = 1
                    tipViewModel.currencyCode = .PLN
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(!roundUp ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .foregroundColor(!roundUp ? .black : .primary)
                .cornerRadius(Constants.cornerRadius)
                
                Button(tipViewModel.userData.isEmpty ? "Zapisz" : "Wczytaj"){
                    isConfirming = true

                }
//                .onLongPressGesture{
//                    showMenu = true
//                }
                .confirmationDialog(
                    "Are you sure you want to import this file?",
                    isPresented: $isConfirming, titleVisibility: .visible
                ) {
                    Button("Rodzina") {
                        tipViewModel.addPreset()
                    }
                    Button("Znajomi") {
                        tipViewModel.addPreset()
                    }
                    Button("Praca") {
                        tipViewModel.addPreset()
                    }
                    Button("Cancel", role: .cancel) {
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(!roundUp ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .foregroundColor(!roundUp ? .black : .primary)
                .cornerRadius(12)
                
                .sheet(isPresented: $showMenu) {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(tipViewModel.userData) { userData in
                                Button("Waluta: \(userData.currencyCode.rawValue)\nLiczba osób: \(userData.people)\nProcent: \(userData.tipPercent)") {
                                    showMenu = false
                                    tipViewModel.applyPresent(for: userData)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                }
                
                Button(action: {
                    let perPerson = tipViewModel.perPerson(amount: tipViewModel.amount, percent: tipViewModel.tipPercent, people: tipViewModel.people)
                    let historyItem: HistoryData = .init(
                        date: Date.now,
                        amount: tipViewModel.amount,
                        tipPercent: tipViewModel.tipPercent,
                        perPerson: perPerson
                    )
                    tipViewModel.sendTipToServer(tip: historyItem)
                    tipViewModel.history.append(historyItem)
                }) {
                    Text("Dodaj do historii")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(!roundUp ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                        .foregroundColor(!roundUp ? .black : .primary)
                        .cornerRadius(Constants.cornerRadius)
                }
            }
        }
    }
    
    func historyView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                VStack {
                    Text("Historia")
                }
                .bold()
                
                ScrollView {
                    ForEach(tipViewModel.history) { historyItem in
                        VStack {
                            HStack {
                                Text("Data: \(historyItem.date.formattedDate)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                
                                Text("Napiwek: \(String(format: "%.2f", historyItem.tipPercent))%")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                            HStack {
                                Text("Waluta: \(String(format: "%.2f", historyItem.amount)) \(tipViewModel.currencyCode.rawValue)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                
                                Text("Na osobę: \(String(format: "%.2f", historyItem.perPerson)) \(tipViewModel.currencyCode.rawValue)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(10)
                    }
                    
                }
            }
        }
    }
}
 
struct CardView <Content: View>: View {
        let content: Content
        
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }
        
        var body: some View {
            VStack {
                content
            }
            .padding()
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }

#Preview { ContentView()
    
}
