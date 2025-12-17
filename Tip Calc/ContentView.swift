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
    @State var currencies: Currencies = .PLN
    @State var currenciesConverted: CurrenciesConverted = .EUR
    @State private var isConfirming = false

    let step = 1
    let range = 1...30
    
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
            .alert(isPresented: $tipViewModel.shouldDisplayError) {
                let error = tipViewModel.viewError
                return Alert(title: Text("Error"), message: Text(error?.localizedDescription ?? ""),
                             dismissButton: Alert.Button.default(Text(L10n.Alert.Button.Close.title), action: {
                    tipViewModel.shouldDisplayError = false
                }))
            }
        }
        .onAppear {
            tipViewModel.getTipHistoryFromServer()
            tipViewModel.downloadEUR()
            tipViewModel.downloadUSD()
        }
    }
    
    private func billValueView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                HStack {
                    TextField(L10n.CardView.BillValueView.Textfield.title(tipViewModel.currencyCode.rawValue), value: $tipViewModel.amount, format: .number)
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
                    Slider(value: Binding(
                        get: { Double(tipViewModel.tipPercent) },
                        set: {
                            tipViewModel.tipPercent = tipViewModel.tipPercentRoundedValue($0)
                        }),
                           in: 0...50,
                           step: 5)
                    {
                        Text("Percent")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("50")
                    } onEditingChanged: { editing in
                        isEditing = editing
                    }
                }
                Text("\(tipViewModel.tipPercent)%")
                    .foregroundColor(isEditing ? .red : .white)
                
                HStack {
                    Text(L10n.Form.Number.Of.People.title(tipViewModel.people))

                    Stepper(
                        value: $tipViewModel.people,
                        in: range,
                        step: step
                    ) {
                    
                    }
                    .tint(Color.blue.opacity(0.2))
                }
                VStack {
                    
                    Text(L10n.Picker.Choose.Currency.title)
                    Picker("Currency", selection: $tipViewModel.currencyCode) {
                        Text("PLN").tag(Currencies.PLN)
                        Text("EURO").tag(Currencies.EUR)
                        Text("USD").tag(Currencies.USD)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.blue.opacity(0.2))
                    
                    Text(L10n.Picker.Choose.CurrencyCnverted.title)
                    
                    Picker("Converted Currency", selection: $tipViewModel.currencyCodeConverted) {
                        Text("PLN").tag(CurrenciesConverted.PLN)
                        Text("EURO").tag(CurrenciesConverted.EUR)
                        Text("USD").tag(CurrenciesConverted.USD)
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
                    Text(L10n.CardView.AmountShowView.Text1.title)
                    Spacer()
                    VStack {
                        Text("\(tipViewModel.tip(amount: tipViewModel.amount, percent: tipViewModel.tipPercent), specifier: "%.2f") \(tipViewModel.currencyCode.rawValue)")
                            .bold()
                        Text("\(tipViewModel.convertedTip() ?? 0.0, specifier: "%.2f"), \(tipViewModel.currencyCodeConverted.rawValue)")
                            .opacity(0.6)
                    }
                }
                
                HStack {
                    Text(L10n.CardView.AmountShowView.Text2.title)
                    Spacer()
                    VStack {
                        Text("\(tipViewModel.total(amount: tipViewModel.amount, percent: tipViewModel.tipPercent), specifier: "%.2f") \(tipViewModel.currencyCode.rawValue)")
                            .bold()
                        Text("\(tipViewModel.convertedTotal() ?? 0.0, specifier: "%.2f"), \(tipViewModel.currencyCodeConverted.rawValue)")
                            .opacity(0.6)
                    }
                }
                
                HStack {
                    Text(L10n.CardView.AmountShowView.Text3.title)
                    Spacer()
                    VStack {
                        Text("\(tipViewModel.perPerson(amount: tipViewModel.amount, percent: tipViewModel.tipPercent, people: tipViewModel.people), specifier: "%.2f") \(tipViewModel.currencyCode.rawValue)")
                            .bold()
                        Text("\(tipViewModel.convertedPerPerson() ?? 0.0, specifier: "%.2f"), \(tipViewModel.currencyCodeConverted.rawValue)")
                            .opacity(0.6)
                    }
                }
            }
            .padding()
        }
    }
    
    private func buttonView() -> some View {
        CardView {
            VStack(spacing: Constants.spacing) {
                Button("Reset") {
                    tipViewModel.resetButton()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(!roundUp ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                .foregroundColor(!roundUp ? .black : .primary)
                .cornerRadius(Constants.cornerRadius)
                
                Button(tipViewModel.userData.isEmpty ? L10n.CardView.ButtonView.Button.Save.title : L10n.CardView.ButtonView.Button.Load.title){
                    isConfirming = true
                }
                .confirmationDialog(
                    L10n.CardView.ButtonView.ConfirmationDialog.title ,
                    isPresented: $isConfirming, titleVisibility: .visible
                ) {
                    Button(L10n.CardView.ButtonView.PresetButton.Family.title) {
                        tipViewModel.addPreset()
                    }
                    Button(L10n.CardView.ButtonView.PresetButton.Friends.title) {
                        tipViewModel.addPreset()
                    }
                    Button(L10n.CardView.ButtonView.PresetButton.Work.title) {
                        tipViewModel.addPreset()
                    }
                    Button(L10n.CardView.ButtonView.PresetButton.Cancel.title, role: .cancel) {
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(roundUp ? Color.gray.opacity(0.2) : Color.blue.opacity(0.3))
                .foregroundColor(roundUp ? .primary : .black)
                .cornerRadius(12)
                
                .sheet(isPresented: $showMenu) {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(tipViewModel.userData) { userData in
                                Button(tipViewModel.userDataFormattedDetailsFrom(userData)) { 
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
                    Text(L10n.CardView.ButtonView.Button.AddToHistory.title)
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
                                Text(L10n.CardView.HistoryView.ScrollView.TextData.title(historyItem.date.formattedDate))
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                
                                Text(L10n.CardView.HistoryView.ScrollView.TextTip.title(historyItem.tipPercent))
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                            HStack {
                                Text(L10n.CardView.HistoryView.ScrollView.TextCourrency.title(historyItem.amount))
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                
                                Text(L10n.CardView.HistoryView.ScrollView.TextPerPerson.title(historyItem.perPerson))
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                            }
                            Button(L10n.CardView.HistoryView.ScrollView.Button.Delete.title) {
                                tipViewModel.deleteTipFromServer(tip: historyItem)
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

