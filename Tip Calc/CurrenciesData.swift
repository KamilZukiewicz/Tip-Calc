//
//  CurrenciesData.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 18/08/2025.
//

import Foundation

enum Currencies: String, CaseIterable, Identifiable {
    case PLN, EUR, USD
    var id: Self { self }
}

enum CurrenciesConverted: String, CaseIterable, Identifiable {
    case PLN, EUR, USD
    var id: Self { self }
}

