//
//  NumberFormatter+.swift
//  Evetto
//
//  Created by avocoder on 28.01.2023.
//

import Foundation

extension NumberFormatter {
    
    static var priceNumberFormatter: NumberFormatter {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.formattingContext = .standalone
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }
    
}
