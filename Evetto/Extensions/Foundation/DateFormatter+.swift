//
//  DateFormatter+.swift
//  Evetto
//
//  Created by avocoder on 28.01.2023.
//

import Foundation

extension DateFormatter {
    
    static var dayAndTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("dd MMMM y, HH:mm")
        return dateFormatter
    }
    
}
