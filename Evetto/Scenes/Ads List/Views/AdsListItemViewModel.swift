//
//  AdsListItemViewModel.swift
//  NewsReader
//
//  Created by avocoder on 24.01.2023.
//

import Foundation
import Differentiator

struct AdsListItemViewModel: Hashable, IdentifiableType {
    
    var identity: String {
        id.uuidString
    }
    
    let id: UUID
    let title: String
    let location: String?
    let price: String
    let date: String
    let imageURL: URL?
    let ad: Ad
    
    init(
        ad: Ad,
        formatDate: (Date) -> String,
        priceFormatter: NumberFormatter
    ) {
        self.ad = ad
        id = ad.id
        title = ad.title
        imageURL = ad.previewImageURL
        
        if let location = ad.location {
            var formattedLocation = location.area
            if let district = location.district {
                formattedLocation += ", " + district
            }
            self.location = formattedLocation
        } else {
            location = nil
        }
        
        self.date = formatDate(ad.createdAt)
        
        if let price = ad.price {
            priceFormatter.currencyCode = price.currency.rawValue
            priceFormatter.currencySymbol = price.currency.currencySymbol
            self.price = (priceFormatter.string(for: price.amount) ?? "\(price.amount)")
        } else {
            price = "Цена не указана"
        }
    }
}
