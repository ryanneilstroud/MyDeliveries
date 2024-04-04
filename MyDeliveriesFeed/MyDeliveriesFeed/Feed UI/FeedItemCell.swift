//
//  FeedItemCell.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import SwiftUI

struct FeedItemCell: View {
    @ObservedObject private var viewModel: FeedItemCellViewModel
    private let onTap: () -> Void
    
    init(viewModel: FeedItemCellViewModel, onTap: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            if
                let imageData = viewModel.imageData,
                let uiImage = UIImage(data: imageData)
            {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Rectangle())
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
