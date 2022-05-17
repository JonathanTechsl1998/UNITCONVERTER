//
//  Category+CoreDataProperties.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-13.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var color: Int64
    @NSManaged public var categoryID: String?
    @NSManaged public var monthlyBudget: Double
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var selCount: Int64
    @NSManaged public var remaining: Double
    @NSManaged public var spent: Double
    @NSManaged public var date: Date?
    @NSManaged public var categoryExpense: NSSet?

}

// MARK: Generated accessors for categoryExpense
extension Category {

    @objc(addCategoryExpenseObject:)
    @NSManaged public func addToCategoryExpense(_ value: Expense)

    @objc(removeCategoryExpenseObject:)
    @NSManaged public func removeFromCategoryExpense(_ value: Expense)

    @objc(addCategoryExpense:)
    @NSManaged public func addToCategoryExpense(_ values: NSSet)

    @objc(removeCategoryExpense:)
    @NSManaged public func removeFromCategoryExpense(_ values: NSSet)

}

extension Category : Identifiable {

}
