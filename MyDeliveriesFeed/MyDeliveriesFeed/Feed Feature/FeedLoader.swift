//
//  FeedLoader.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 24/3/2024.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
