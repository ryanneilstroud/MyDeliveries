//
//  InMemoryStore.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import Foundation

public class InMemoryFeedStore {
    private var feedCache: CachedFeed?
//    private var feedImageDataCache = NSCache<NSURL, NSData>()
    
    public init() {}
}

extension InMemoryFeedStore: FeedStore {
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        feedCache = nil
        completion(.success(()))
    }
    
    public func insert(_ feed: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
        feedCache = CachedFeed(feed: feed, timestamp: timestamp)
        completion(.success(()))
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(feedCache))
    }
    
}
