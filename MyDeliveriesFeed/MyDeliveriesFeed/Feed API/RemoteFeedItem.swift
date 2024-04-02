//
//  RemoteFeedItem.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 29/3/2024.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: String
    let remarks: String
    let goodsPicture: String
    let deliveryFee: String
    let surcharge: String
    let route: Route
    let sender: Sender
    
    struct Route: Decodable {
        let start: String
        let end: String
    }
    
    struct Sender: Decodable {
        let phone: String
        let name: String
        let email: String
    }
}
