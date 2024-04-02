//
//  FeedItemDetailViewModel.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import Foundation
import Combine

final class FeedItemDetailViewModel: ObservableObject {
    @Published private var item: FeedItem
    private let onTap: (FeedItem) -> Void
    
    init(item: FeedItem, onTap: @escaping (FeedItem) -> Void) {
        self.item = item
        self.onTap = onTap
    }
    
    var remarks: String {
        "Remarks: \(item.remarks)"
    }
    
    var goodsPicture: URL {
        item.goodsPicture
    }
    
    var fromValue: String {
        item.route.start
    }
    
    var toValue: String {
        item.route.end
    }
    
    var price: String {
        "$\(item.deliveryFee + item.surcharge)"
    }
    
    var favoriteButtonText: String {
        if item.favorited {
            return "Remove from favorites ❤️"
        } else {
            return "Add to favorites ❤️"
        }
    }
    
    func toggleFavorite() {
        item.favorited = !item.favorited
        onTap(item)
    }
}
