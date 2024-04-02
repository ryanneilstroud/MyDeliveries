//
//  FeedCache+Extension.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

extension FeedCache {
    func saveIgnoringResult(_ feed: [FeedItem]) {
        save(feed) { _ in }
    }
}
