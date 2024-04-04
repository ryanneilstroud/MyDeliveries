//
//  FeedUIComposer.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import SwiftUI

extension FeedItem: Identifiable {}

final class FeedUIComposer {
    
    typealias UpdateItem = (FeedItem) -> Void
    typealias Navigation = (FeedItem, @escaping UpdateItem) -> Void
    
    static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader, feedCache: FeedCache, navigate: @escaping Navigation) -> UIHostingController<some View> {
        let viewModel = FeedItemListViewModel(
            loadFeed: MainQueueDispatchDecorator(
                decoratee: feedLoader).load)
        
        func update(item: FeedItem) {
            viewModel.update(item: item)
            feedCache.saveIgnoringResult(viewModel.feedItems)
        }
        
        return UIHostingController(
            rootView: FeedItemList(
                viewModel: viewModel,
                loadCell: { item in
                    cellWith(
                        item: item,
                        imageLoader: imageLoader,
                        onTap: { navigate(item, update) })
                }))
    }
    
    private static func cellWith(item: FeedItem, imageLoader: FeedImageDataLoader, onTap: @escaping () -> Void) -> some View {
        FeedItemCell(
            viewModel: FeedItemCellViewModel(
                item: item,
                imageLoader: MainQueueDispatchDecorator(
                    decoratee: imageLoader)),
            onTap: onTap)
    }
    
}
