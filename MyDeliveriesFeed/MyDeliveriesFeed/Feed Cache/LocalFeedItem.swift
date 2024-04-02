//
//  LocalFeedItem.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 24/3/2024.
//

import Foundation

public struct LocalFeedItem: Equatable {
    let id: UUID
    let remarks: String
    let goodsPicture: URL
    let deliveryFee: String
    let surcharge: String
    let route: Route
    let sender: Sender
    let favorited: Bool
    
    public init(id: UUID, remarks: String, goodsPicture: URL, deliveryFee: String, surcharge: String, route: Route, sender: Sender, favorited: Bool) {
        self.id = id
        self.remarks = remarks
        self.goodsPicture = goodsPicture
        self.deliveryFee = deliveryFee
        self.surcharge = surcharge
        self.route = route
        self.sender = sender
        self.favorited = favorited
    }
    
    public struct Route: Equatable {
        let start: String
        let end: String
        
        public init(start: String, end: String) {
            self.start = start
            self.end = end
        }
    }
    
    public struct Sender: Equatable {
        let phone: String
        let name: String
        let email: String
        
        public init(phone: String, name: String, email: String) {
            self.phone = phone
            self.name = name
            self.email = email
        }
    }
}
