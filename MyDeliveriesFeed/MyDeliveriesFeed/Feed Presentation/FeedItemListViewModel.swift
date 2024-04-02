//
//  FeedItemListViewModel.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import Combine

final class FeedItemListViewModel<T: Identifiable>: ObservableObject {
    typealias LoadFeed = (@escaping (Result<[T], Error>) -> Void) -> Void
    
    let loadFeed: LoadFeed
    @Published var feedItems = [T]()
    
    init(loadFeed: @escaping LoadFeed) {
        self.loadFeed = loadFeed
    }
    
    func load() {
        loadFeed { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(items):
                feedItems = items
            case let .failure(error):
                print(error)
            }
        }
    }
}
