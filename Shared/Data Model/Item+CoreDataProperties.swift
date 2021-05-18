//
//  Item+CoreDataProperties.swift
//  Inventauri
//
//  Created by Daniel Marriner on 10/05/2021.
//
//

import Foundation
import CoreData

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var name: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isContainer: Bool
    @NSManaged public var image: Data?

    @NSManaged public var parent: Item?
    @NSManaged public var children: NSSet?

    public var wrappedName: String { name ?? "" }

    public var all: [Item] {
        let set = children as? Set<Item> ?? []
        return set
            .sorted { $0.wrappedName < $1.wrappedName }
    }

    public var items: [Item] {
        let set = children as? Set<Item> ?? []
        return set
            .filter { !$0.isContainer }
            .sorted { $0.wrappedName < $1.wrappedName }
    }

    public var containers: [Item] {
        let set = children as? Set<Item> ?? []
        return set
            .filter { $0.isContainer }
            .sorted { $0.wrappedName < $1.wrappedName }
    }

    public var path: [Item] {
        var path = [Item]()
        var base = self
        while let parent = base.parent {
            path.append(parent)
            base = parent
        }
        return path.reversed()
    }
    
    public var pathString: String {
        var list = path.dropFirst(1).map(\.wrappedName)
        list.append("Loose Items")
        return list.joined(separator: " > ")
    }
}

// MARK: Generated accessors for children
extension Item {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Item)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Item)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension Item : Identifiable {}
