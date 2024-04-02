//
//  FeedItemListViewModel+LoadMore.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

extension FeedItemListViewModel {
    
    func loadMoreIfNeeded(for item: T) {
        if isLast(item) { loadMore() }
    }
    
    private func isLast(_ item: T) -> Bool {
        item.id == feedItems.last?.id
    }
    
    private func loadMore() {
        loadFeed { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(items):
                feedItems += items
            case let .failure(error):
                print(error)
            }
        }
    }
    
}
