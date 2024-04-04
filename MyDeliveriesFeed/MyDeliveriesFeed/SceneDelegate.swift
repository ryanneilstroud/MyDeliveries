//
//  SceneDelegate.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 23/3/2024.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
//    private lazy var store: FeedStore = {
//        try! CoreDataFeedStore(
//            storeURL: NSPersistentContainer
//                .defaultDirectoryURL()
//                .appendingPathComponent("feed-store.sqlite"))
//    }()
//    
    private let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    private lazy var store: FeedStore & FeedImageDataStore = {
       InMemoryFeedStore()
    }()
    
    private func makeRemoteFeedLoader(offset: Int = 0) -> FeedLoader {
        let baseURL = URL(string: "https://6285f87796bccbf32d6c0e6a.mockapi.io")!
        return RemoteFeedLoaderStub(
            url: FeedEndpoint.get(offset: offset)
                .url(baseURL: baseURL),
            client: client)
    }
    
    private lazy var remoteLoader: FeedLoader = {
        RemoteFeedLoadMoreLoaderDecorator(
            decoratee: makeRemoteFeedLoader(),
            makeFeedLoader: makeRemoteFeedLoader)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var localLoader: FeedLoader = {
        return LocalFeedIgnoreLoadMoreLoaderDecorator(
            decoratee: FeedLoaderCacheDecorator(
                decoratee: localFeedLoader,
                cache: localFeedLoader))
    }()
    private lazy var localFeedImageDataLoader: LocalFeedImageDataLoader = {
        LocalFeedImageDataLoader(store: store)
    }()
    private lazy var imageLoaderComposite: FeedImageDataLoader = {
        FeedImageDataLoaderWithFallbackComposite(
            primary: localFeedImageDataLoader,
            fallback: FeedImageDataLoaderCacheDecorator(
                decoratee: RemoteFeedImageDataLoader(client: client),
                cache: localFeedImageDataLoader))
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let navigation = UINavigationController()
                
        navigation.set(FeedUIComposer.feedComposedWith(
            feedLoader: FeedLoaderWithFallbackComposite(
                primary: localLoader,
                fallback: remoteLoader), 
            imageLoader: imageLoaderComposite,
            feedCache: localFeedLoader,
            navigate: { feedItem, updateItem in
                navigation.push(FeedItemUIComposer.feedItemComposedWith(
                    item: feedItem,
                    imageLoader: self.imageLoaderComposite,
                    onFavorite: updateItem))
            }))
        window?.rootViewController = navigation
    }
}

private extension UINavigationController {
    
    func set(_ viewController: UIViewController) {
        self.pushViewController(viewController, animated: false)
    }
    
    func push(_ viewController: UIViewController) {
        self.pushViewController(viewController, animated: true)
    }
    
}

final class RemoteFeedLoaderStub: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    private func makeItem0() -> FeedItem {
        FeedItem(
            id: .init(),
            remarks: "Hope you enjoy!",
            goodsPicture: URL(string: "https://loremflickr.com/320/240/cat?lock=9953")!,
            deliveryFee: 50.75,
            surcharge: 10.50,
            route: .init(
                start: "Hysan Place",
                end: "Festival Walk"),
            sender: .init(
                phone: "+852 5555-2468",
                name: "Peter Parker",
                email: "peter.parker@marvel.com"),
            favorited: false)
    }
    
    private func makeItem1() -> FeedItem {
        FeedItem(
            id: .init(),
            remarks: "Minim veniam minim nisi ullamco consequat anim reprehenderit laboris aliquip voluptate sit.",
            goodsPicture: URL(string: "https://loremflickr.com/320/240/cat?lock=28542")!,
            deliveryFee: 92.14,
            surcharge: 136.45,
            route: .init(
                start: "Noble Street",
                end: "Montauk Court"),
            sender: .init(
                phone: "+852 5555-1234",
                name: "John Appleseed",
                email: "john.appleseed@apple.com"),
            favorited: false)
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        print(url)
        let items = (0...19).map { index in
            if index % 2 == 0 {
                return makeItem0()
            } else {
                return makeItem1()
            }
        }
        completion(.success(items))
    }
}
