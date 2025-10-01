//
//  Date+Ext.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 08/09/2025.
//

import Foundation

enum DateFormats {
    case fullDate
    case dayMonthYear
    case hourMinuteSeconds
    
    var value: String {
        switch self {
        case .fullDate:
            return "dd-MM-yyyy HH:mm:ss"
        case .dayMonthYear:
            return "dd-MM-yy"
        case .hourMinuteSeconds:
            return "HH:mm:ss"
        }
    }
}

extension Date {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormats.dayMonthYear.value
        return formatter.string(from: self)
    }
}
