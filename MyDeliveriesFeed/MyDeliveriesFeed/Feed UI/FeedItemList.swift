//
//  FeedItemList.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 29/3/2024.
//

import SwiftUI

struct FeedItemList<T: Identifiable>: View {
    @ObservedObject var viewModel: FeedItemListViewModel<T>
    private let loadCell: (T) -> any View
    
    init(viewModel: FeedItemListViewModel<T>, loadCell: @escaping (T) -> any View) {
        self.viewModel = viewModel
        self.loadCell = loadCell
    }
    
    var body: some View {
        List(viewModel.feedItems, id: \.id) { item in
            AnyView(loadCell(item))
                .onAppear { viewModel.loadMoreIfNeeded(for: item) }
        }
        .listStyle(.plain)
        .viewDidLoad(viewModel.load)
    }
}
