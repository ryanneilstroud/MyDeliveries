//
//  ManagedFeedItem.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 30/3/2024.
//

import CoreData

@objc(ManagedFeedItem)
class ManagedFeedItem: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var remarks: String
    @NSManaged var goodsPicture: URL
    @NSManaged var deliveryFee: String
    @NSManaged var surcharge: String
    @NSManaged var routeStart: String
    @NSManaged var routeEnd: String
    @NSManaged var senderPhone: String
    @NSManaged var senderName: String
    @NSManaged var senderEmail: String
    @NSManaged var favorited: Bool
    @NSManaged var data: Data?
    @NSManaged var cache: ManagedCache
}

extension ManagedFeedItem {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedFeedItem? {
        let request = NSFetchRequest<ManagedFeedItem>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedItem.goodsPicture), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
    
    static func items(from localFeed: [LocalFeedItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedItem(context: context)
            managed.id = local.id
            managed.remarks = local.remarks
            managed.goodsPicture = local.goodsPicture
            managed.deliveryFee = local.deliveryFee
            managed.surcharge = local.surcharge
            managed.routeStart = local.route.start
            managed.routeEnd = local.route.end
            managed.senderPhone = local.sender.phone
            managed.senderName = local.sender.name
            managed.senderEmail = local.sender.email
            managed.favorited = local.favorited
            return managed
        })
    }
    
    var local: LocalFeedItem {
        return LocalFeedItem(
            id: id,
            remarks: remarks,
            goodsPicture: goodsPicture,
            deliveryFee: deliveryFee,
            surcharge: surcharge,
            route: .init(
                start: routeStart,
                end: routeEnd),
            sender: .init(
                phone: senderPhone,
                name: senderName,
                email: senderEmail), 
            favorited: favorited)
    }
}
