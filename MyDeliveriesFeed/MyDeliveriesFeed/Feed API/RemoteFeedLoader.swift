//
//  RemoteFeedLoader.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 23/3/2024.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, response)):
                completion(RemoteFeedLoader.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemsMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {
        return map {
            FeedItem(
                id: UUID(uuidString: $0.id)!,
                remarks: $0.remarks,
                goodsPicture: URL(string: $0.goodsPicture)!,
                deliveryFee: toDecimal($0.deliveryFee),
                surcharge: toDecimal($0.surcharge),
                route: .init(
                    start: $0.route.start,
                    end: $0.route.end),
                sender: .init(
                    phone: $0.sender.phone,
                    name: $0.sender.name,
                    email: $0.sender.email), 
                favorited: false)

        }
    }
    
    private func toDecimal(_ value: String) -> Decimal {
        Decimal(string: value.replacingOccurrences(
            of: "[^0-9.]",
            with: "",
            options: .regularExpression))!
    }
}
