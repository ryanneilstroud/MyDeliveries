//
//  FeedCache.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 24/3/2024.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedItem], completion: @escaping (Result) -> Void)
}
