//
//  RemoteFeedLoadMoreLoaderDecorator.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import Foundation

final class RemoteFeedLoadMoreLoaderDecorator: FeedLoader {
    private var decoratee: FeedLoader
    private let makeFeedLoader: (Int) -> FeedLoader
    private var offset = 0
    
    init(decoratee: FeedLoader, makeFeedLoader: @escaping (Int) -> FeedLoader) {
        self.decoratee = decoratee
        self.makeFeedLoader = makeFeedLoader
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(items):
                offset += 20
                decoratee = makeFeedLoader(offset)
                
                completion(.success(items))
            case let.failure(error):
                completion(.failure(error))
            }
        }
    }
}
