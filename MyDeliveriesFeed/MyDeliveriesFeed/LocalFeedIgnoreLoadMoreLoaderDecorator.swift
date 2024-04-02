//
//  LocalFeedIgnoreLoadMoreLoaderDecorator.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

final class LocalFeedIgnoreLoadMoreLoaderDecorator: FeedLoader {
    private var decoratee: FeedLoader
    private var didExhaustCache = false
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            guard let self = self else { return }
            
            if didExhaustCache {
                completion(.success([]))
                return
            }
            
            switch result {
            case let .success(items):
                didExhaustCache = true
                
                completion(.success(items))
            case let.failure(error):
                completion(.failure(error))
            }
        }
    }
}
