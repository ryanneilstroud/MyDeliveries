//
//  FeedItemListViewModel+UpdateItem.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

extension FeedItemListViewModel {
    
    func update(item: T) {
        guard let itemIndex = getIndex(for: item) else { return }
        feedItems[itemIndex] = item
    }
    
    private func getIndex(for item: T) -> Int? {
        feedItems.firstIndex(where: { item.id == $0.id })
    }
    
}
