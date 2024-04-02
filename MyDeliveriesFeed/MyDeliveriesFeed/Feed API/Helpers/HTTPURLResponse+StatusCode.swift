//
//  HTTPURLResponse+StatusCode.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 29/3/2024.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}
