//
//  FeedEndpoint.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

public enum FeedEndpoint {
    case get(offset: Int = 0)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(offset):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/deliveries"
            components.queryItems = [
                URLQueryItem(name: "offset", value: "\(offset)"),
            ].compactMap { $0 }
            return components.url!
        }
    }
}
