//
//  ContentView+Ext.swift
//  Tip Calc
//
//  Created by Kamil Żukiewicz on 27/08/2025.
//

import SwiftUI

enum CornerRadius {
    case xl
    case m
    case s
    case xs
    
    var value: CGFloat {
        switch self {
        case .xl:
            return 20.0
        case .m:
            return 12.0
        case .s:
            return 8.0
        case .xs:
            return 4.0
        }
    }
}

extension ContentView {
    struct Constants {
        static let spacing = 20.0
        static let cornerRadius = CornerRadius.m.value
    }
    
    struct Colors {
        static let button = Color.blue.opacity(0.2)
        static let blue = Color.blue.opacity(0.3)
    }
    
}

