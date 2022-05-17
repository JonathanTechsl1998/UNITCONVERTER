//
//  ValueFormatter.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-08.
//

import Foundation
import UIKit
import CoreData

class Formatter {
    // Helper to format date
    static func formatDate(_ date: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}

class Utility {
    //Helper for common functions
    static var alert: UIAlertController!
    static let dateFormatter = DateFormatter()
    
    typealias actionHandler = ()  -> Void
    typealias saveFunctionType = (_ viewController: UIViewController) -> Void
    typealias resetToDefaultsFunctionType = () -> Void
    
    private static let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    static func getDBContext() -> NSManagedObjectContext  {
        return container.viewContext
    }
    
    static func saveDBContext()  {
        if Utility.getDBContext().hasChanges {
            do {
                try Utility.getDBContext().save()
            } catch {
                fatalError("Unresolved error while saving the context \(error)")
            }
        }
    }
    
    static func fetchFromDBContext<Entity>(entityName: String, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil) -> [Entity] where Entity: NSManagedObject {
        let request: NSFetchRequest<Entity> = NSFetchRequest<Entity>(entityName: entityName)
        
        if let selectedPredicate = predicate {
            request.predicate = selectedPredicate
        }
        
        if let selectedSortDescriptor = sortDescriptor {
            request.sortDescriptors = [selectedSortDescriptor]
        }
        
        do {
            let results = try Utility.getDBContext().fetch(request)
            return results
        } catch {
            fatalError("Unresolved error while loading the context \(error)")
        }
    }
    
    static func showConfirmationAlert (title: String, message: String, yesAction: @escaping actionHandler = {() in}, noAction: @escaping actionHandler = {() in}, caller: UIViewController) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
            noAction()
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            yesAction()
        }))
        caller.present(alert, animated: true, completion: nil)
    }
    
    static func showInformationAlert (title: String, message: String, caller: UIViewController) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        caller.present(alert, animated: true, completion: nil)
    }
    
    static func getDaysDifference(between firstDate: Date, and secondDate: Date) -> Float {
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        return Float(calendar.dateComponents([.day], from: date1, to: date2).day!) - 1
    }
    
    
    
    static func getColorFor(value: Float) -> UIColor {
        if value >= 0 && value <= 25 {
            return .systemRed
        } else if value > 25 && value <= 50 {
            return .systemOrange
        } else if value > 50 && value <= 75 {
            return .systemGreen
        } else {
            return .systemBlue
        }
    }
    
    static func getFormattedDateString(for date: Date, format: String) -> String {
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

protocol ItemActionDelegate: class {
    func itemAdded(title: String)
    func itemEdited(title: String)
}

