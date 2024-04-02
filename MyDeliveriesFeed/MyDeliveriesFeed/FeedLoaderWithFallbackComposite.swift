//
//  FeedLoaderWithFallbackComposite.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case let .success(items) where items.isEmpty == false:
                completion(result)
            case .success:
                self?.fallback.load(completion: completion)
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
