//
//  CoreDataManager.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-13.
//

import Foundation
import UIKit
import CoreData

struct CoreDataManager {
    
    private var appDelegate: AppDelegate?
    private var manageContent: NSManagedObjectContext?
    
    init() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.appDelegate = appDelegate
            self.manageContent = self.appDelegate!.persistentContainer.viewContext
        }
        
    }
    
    //MARK: - Category Functions
    func saveCategory(categoryDetail: Category, completion: @escaping (Bool) -> Void) {
        
        let categoryEntity    = NSEntityDescription.entity(forEntityName: "Category", in: self.manageContent!)!
        let category          = NSManagedObject(entity: categoryEntity, insertInto: manageContent)
        
        category.setValue(categoryDetail.name, forKey: "name")
        category.setValue(categoryDetail.monthlyBudget, forKey: "monthlyBudget")
        category.setValue(categoryDetail.note, forKey: "note")
        category.setValue(categoryDetail.selCount, forKey: "selCount")
        category.setValue(categoryDetail.color, forKey: "color")

        
        do {
            try self.manageContent!.save()
            completion(true)
        } catch _ as NSError {
            
            completion(true)
        }
    }
    
    
    func updateCategory(categoryDetail: Category, categoryObj: NSManagedObject, completion: @escaping (Bool) -> Void) {
        
        let category  = categoryObj
        
        category.setValue(categoryDetail.name, forKey: "name")
        category.setValue(categoryDetail.monthlyBudget, forKey: "monthlyBudget")
        category.setValue(categoryDetail.note, forKey: "note")
        category.setValue(categoryDetail.selCount, forKey: "selCount")
        category.setValue(categoryDetail.color, forKey: "color")
        
        do {
            try self.manageContent!.save()
            completion(true)
            
        } catch _ as NSError {
            completion(false)
        }
    }
    
    func deleteCategory(categoryObj: NSManagedObject, completion: @escaping (Bool) -> Void) {
        
        do {
            self.manageContent!.delete(categoryObj)
            try self.manageContent!.save()
            completion(true)
            
        } catch _ as NSError {
            completion(false)
        }
        
    }
 
    func getCategory(name: String) -> [Category]? {
        
        let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let result = try self.manageContent!.fetch(fetchRequest)
            
            return (result as [Category])
            
            
        } catch (let error){
            
            print("Error on category get: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - Expenses Functions
    func saveExpense(amount: Double, note: String, endDate: Date, reminder:Bool, startDate:Date, name: String, occurance:Int64,  category: Category, completion: @escaping (Bool) -> Void) {
        
        let expenseEntity = NSEntityDescription.entity(forEntityName: "Expense", in: self.manageContent!)!
        let expense       = NSManagedObject(entity: expenseEntity, insertInto: manageContent)
        
        expense.setValue(note, forKey: "note")
        expense.setValue(amount, forKey: "amount")
        expense.setValue(category.name, forKey: "category")
        expense.setValue(name, forKey: "name")
        expense.setValue(endDate, forKey: "endDate")
        expense.setValue(startDate, forKey: "startDate")
        expense.setValue(reminder, forKey: "reminder")
        expense.setValue(occurance, forKey: "occurance")
        
        category.addToCategoryExpense(expense as! Expense)
        
        do {
            try self.manageContent!.save()
            
            completion(true)
            
        }  catch (let error){
            
            print("Error on expense save: \(error.localizedDescription)")
            completion(false)
            
        }
    }
    
    func deleteExpense(name: String, completion: @escaping (Bool) -> Void) {
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "note == %@", name)
        
        
        do {
            let result = try self.manageContent!.fetch(fetchRequest)
            
            if let expense = result.first {
                
            
                if let category = getCategory(name: expense.category!)?.first{
                    
                    category.removeFromCategoryExpense(expense)
                    self.manageContent!.delete(expense)
                    try self.manageContent!.save()
                    completion(true)
                } else {
                    completion(false)
                }
            }
            
            
        } catch (let error){
            
            print("Error on expense deletion: \(error.localizedDescription)")
            completion(false)
            
        }
    }
    
    func updateExpense(amount: Double, note: String, endDate: Date, reminder:Bool, startDate:Date, oldExpenseName: String, occurance:Int64,  category: Category, completion: @escaping (Bool) -> Void) {
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", oldExpenseName)
                
        do {
            
            let result = try self.manageContent!.fetch(fetchRequest)
            
            if let expenseOld = result.first {
                
                category.removeFromCategoryExpense(expenseOld)
                
                expenseOld.note       = note
                expenseOld.amount     = amount
                expenseOld.category   = category.name
                expenseOld.reminder   = reminder
                expenseOld.occurance = occurance
                expenseOld.startDate = startDate
                expenseOld.endDate = endDate
                expenseOld.name = oldExpenseName
                
                
                category.addToCategoryExpense(expenseOld)
            }
            
            try self.manageContent!.save()
            completion(true)
            
        } catch _ as NSError {
            completion(false)
        }
       
    }
    
    func getExpenseList(name:String) -> [Expense]? {
        
        let fetchRequest : NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category == %@", name)
        
        do {
            let result = try self.manageContent!.fetch(fetchRequest)
            
            return (result as [Expense])
            
            
        } catch (let error){
            
            print("Error on category get: \(error.localizedDescription)")
            return nil
        }
    }
    
}

