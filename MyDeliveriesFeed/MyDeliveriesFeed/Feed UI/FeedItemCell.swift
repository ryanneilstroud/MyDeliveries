//
//  FeedItemCell.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import SwiftUI

struct FeedItemCell: View {
    private let viewModel: FeedItemCellViewModel
    private let onTap: () -> Void
    
    init(viewModel: FeedItemCellViewModel, onTap: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            AsyncImage(url: viewModel.goodsPicture) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Rectangle())
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            VStack {
                Text(viewModel.fromValue)
                Text(viewModel.toValue)
                Spacer()
            }
            Spacer()
            VStack {
                Text(viewModel.isFavorited)
                Spacer()
                Text(viewModel.price)
            }
        }
        .padding(.vertical)
        .onTapGesture(perform: onTap)
    }
}
