//
//  FeedItemCellViewModel.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import Foundation
import Combine

final class FeedItemCellViewModel: ObservableObject {
    private let item: FeedItem
    
    init(item: FeedItem) {
        self.item = item
    }
    
    var goodsPicture: URL {
        item.goodsPicture
    }
    
    var fromValue: String {
        "From: " + item.route.start
    }
    
    var toValue: String {
        "To: " + item.route.end
    }
    
    var price: String {
        "$\(item.deliveryFee + item.surcharge)"
    }
    
    var isFavorited: String {
        item.favorited ? "❤️" : ""
    }
}
