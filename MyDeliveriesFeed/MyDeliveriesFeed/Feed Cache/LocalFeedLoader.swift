//
//  LocalFeedLoader.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 24/3/2024.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.Result
    
    public func save(_ feed: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ feed: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            
            completion(insertionResult)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cache)):
                completion(.success(cache.feed.toModels()))
            case .success:
                completion(.success([]))
            }
        }
    }
}

private extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(
            id: $0.id,
            remarks: $0.remarks,
            goodsPicture: $0.goodsPicture,
            deliveryFee: "$\($0.deliveryFee)",
            surcharge: "$\($0.surcharge)",
            route: .init(
                start: $0.route.start,
                end: $0.route.end),
            sender: .init(
                phone: $0.sender.phone,
                name: $0.sender.name,
                email: $0.sender.email), 
            favorited: $0.favorited) }
    }
}

private extension Array where Element == LocalFeedItem {
    func toModels() -> [FeedItem] {
        return map { FeedItem(
            id: $0.id,
            remarks: $0.remarks,
            goodsPicture: $0.goodsPicture,
            deliveryFee: toDecimal($0.deliveryFee),
            surcharge: toDecimal($0.surcharge),
            route: .init(
                start: $0.route.start,
                end: $0.route.end),
            sender: .init(
                phone: $0.sender.phone,
                name: $0.sender.name,
                email: $0.sender.email), 
            favorited: $0.favorited) }
    }
    
    private func toDecimal(_ value: String) -> Decimal {
        Decimal(string: value.replacingOccurrences(
            of: "[^0-9.]",
            with: "",
            options: .regularExpression))!
    }
}
