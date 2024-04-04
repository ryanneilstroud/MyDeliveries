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
    private let imageLoader: FeedImageDataLoader
    @Published var imageData: Data?
    
    init(item: FeedItem, imageLoader: FeedImageDataLoader) {
        self.item = item
        self.imageLoader = imageLoader
        
        loadImage()
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
    
    private func loadImage() {
        _ = imageLoader.loadImageData(from: item.goodsPicture) { [weak self] result in
            guard let self = self else { return }
                        
            switch result {
            case let .success(data):
                imageData = data
            case .failure:
                print("failed")
                break
            }
        }
    }
}
