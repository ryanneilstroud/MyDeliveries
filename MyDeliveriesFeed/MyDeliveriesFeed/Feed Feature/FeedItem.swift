//
//  FeedItem.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 24/3/2024.
//

import Foundation

public struct FeedItem: Equatable {
    public let id: UUID
    public let remarks: String
    public let goodsPicture: URL
    public let deliveryFee: Decimal
    public let surcharge: Decimal
    public let route: Route
    public let sender: Sender
    var favorited: Bool
    
    public init(id: UUID, remarks: String, goodsPicture: URL, deliveryFee: Decimal, surcharge: Decimal, route: Route, sender: Sender, favorited: Bool) {
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
        public let start: String
        public let end: String
        
        public init(start: String, end: String) {
            self.start = start
            self.end = end
        }
    }
    
    public struct Sender: Equatable {
        public let phone: String
        public let name: String
        public let email: String
        
        public init(phone: String, name: String, email: String) {
            self.phone = phone
            self.name = name
            self.email = email
        }
    }
}
