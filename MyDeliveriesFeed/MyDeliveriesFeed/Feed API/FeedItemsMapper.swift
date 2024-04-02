//
//  FeedItemsMapper.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 29/3/2024.
//

import Foundation

final class FeedItemsMapper {
        
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let items = try? JSONDecoder().decode([RemoteFeedItem].self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return items
    }
    
}
