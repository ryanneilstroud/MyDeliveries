//
//  FeedImageDataCache.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 4/4/2024.
//

import Foundation

protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
