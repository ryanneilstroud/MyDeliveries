//
//  FeedItemUIComposer.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import SwiftUI

final class FeedItemUIComposer {
    
    static func feedItemComposedWith(item: FeedItem, imageLoader: FeedImageDataLoader, onFavorite: @escaping (FeedItem) -> Void) -> UIHostingController<some View> {
        UIHostingController(
            rootView: FeedItemDetail(
                viewModel: FeedItemDetailViewModel(
                    item: item, 
                    imageLoader: MainQueueDispatchDecorator(
                        decoratee: imageLoader),
                    onTap: onFavorite)))
    }
    
}
