//
//  Expense+CoreDataProperties.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-13.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var eventID: String?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var occurance: Int64
    @NSManaged public var reminder: Bool
    @NSManaged public var reminderID: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var expenseID: String?
    @NSManaged public var expenseCategory: Category?

}

extension Expense : Identifiable {

}
