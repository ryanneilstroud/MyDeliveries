//
//  FeedItemDetail.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import SwiftUI

struct FeedItemDetail: View {
    @ObservedObject private var viewModel: FeedItemDetailViewModel
    
    init(viewModel: FeedItemDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            makeTextLabel(description: "From", value: viewModel.fromValue)
            makeTextLabel(description: "To", value: viewModel.toValue)
            VStack {
                Text(viewModel.remarks)
                if let imageData = viewModel.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(Rectangle())
                }
//                AsyncImage(url: viewModel.goodsPicture) { image in
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(height: 200)
            }
            .padding()
            makeTextLabel(description: "Delivery Fee", value: viewModel.price)
            Spacer()
            Button(action: {
                viewModel.toggleFavorite()
            }, label: {
                Text(viewModel.favoriteButtonText)
            })
        }
        .padding()
        .onAppear(perform: viewModel.loadImage)
    }
    
    private func makeTextLabel(description: String, value: String) -> some View {
        HStack {
            Text(description)
            Spacer()
            Text(value)
        }
        .padding()
        .background(Color.gray.opacity(0.5))
    }
}

//#Preview {
//    FeedItemDetail(viewModel: <#FeedItemDetailViewModel#>)
//}
