//
//  InMemoryStore.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import Foundation

public class InMemoryFeedStore {
    private var feedCache: CachedFeed?
    private var feedImageDataCache = NSCache<NSURL, NSData>()
    
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

extension InMemoryFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        feedImageDataCache.setObject(data as NSData, forKey: url as NSURL)
        completion(.success(()))
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        let data = feedImageDataCache.object(forKey: url as NSURL) as Data?
        completion(.success(data))
    }
}

