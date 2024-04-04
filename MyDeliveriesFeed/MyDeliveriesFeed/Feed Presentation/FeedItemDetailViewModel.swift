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
    @Published var imageData: Data?
    private let imageLoader: FeedImageDataLoader
    private let onTap: (FeedItem) -> Void
    
    init(item: FeedItem, imageLoader: FeedImageDataLoader, onTap: @escaping (FeedItem) -> Void) {
        self.item = item
        self.imageLoader = imageLoader
        self.onTap = onTap
    }
    
    var remarks: String {
        "Remarks: \(item.remarks)"
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
    
    func loadImage() {
        imageLoader.loadImageData(from: item.goodsPicture) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(data):
                imageData = data
            case .failure:
                break
            }
        }
    }
}
