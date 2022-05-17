//
//  MasterTableViewController.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-08.
//

import UIKit
import CoreData
import EventKit


class MasterTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    //initialising the UI objects
    @IBOutlet weak var categoriesTable: UITableView!
    @IBOutlet weak var sortedButton: UIBarButtonItem!
    
    let eventStore : EKEventStore = EKEventStore()
    var detailVC: DetailViewController? = nil
    var managedOC: NSManagedObjectContext? = nil
    var sortedAlphabetically: Bool = false
    var indexSelectedCategory: IndexPath?
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    func configView(){
        if let splitView = splitViewController {
            let controllers = splitView.viewControllers
            detailVC = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            
        }
        
        // Initialising the custom cell
        let nibName = UINib(nibName: "CategoryTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "categoryTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        autoSelectTableRow()
    }
    
    
    func autoSelectTableRow(){
        let indexPath = IndexPath(row: 0, section: 0)
        if tableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath){
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)

            if let indexPath = tableView.indexPathForSelectedRow {
                    let object = fetchedResultsController.object(at: indexPath)
                    self.performSegue(withIdentifier: "showCategoryDetails", sender: object)
            }
        } else {
            let empty = {}
            self.performSegue(withIdentifier: "showCategoryDetails", sender: empty)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = tableView.indexPathForSelectedRow{
            var object: Category
            object =  fetchedResultsController.object(at: indexPath)
            var category = NSManagedObject()
            category = (object as? Category)!
            object.selCount += 1
            
            updateCategory(category: object, categoryObj: category)
            indexSelectedCategory = indexPath
            self.performSegue(withIdentifier: "showCategoryDetails", sender: category)
            
        }
    }
    
    
    func updateCategory(category: Category,categoryObj: NSManagedObject){
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        categoryObj.setValue(category.name, forKey: "name")
        categoryObj.setValue(category.note, forKey: "note")
        categoryObj.setValue(category.monthlyBudget, forKey: "monthlyBudget")
        categoryObj.setValue(category.color, forKey: "color")
        categoryObj.setValue(category.selCount, forKey: "selCount")
        
        do{
            // Save to Core data
            try managedContext.save()
            
        }catch _ as NSError{
            Utility.showInformationAlert(title: "Error", message: "Error while saving the project", caller: self)
           
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryTableViewCell", for: indexPath) as! CategoryTableViewCell
            let category =  fetchedResultsController.object(at: indexPath)
            configureCell(cell, withCategory: category)
        cell.cellDelegate = self
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var context:NSManagedObjectContext
            var object:Category
                 context = fetchedResultsController.managedObjectContext
                 object = fetchedResultsController.object(at: indexPath)
            let deleteExpenses = object.categoryExpense?.allObjects as! [Expense]
            for expense in deleteExpenses{
                if(expense.eventID! != ""){
                    let event = self.eventStore.event(withIdentifier: expense.eventID!)!
                        do{
                            try             self.eventStore.remove(event, span: .futureEvents)
                            
                        }catch let error as NSError{
                            print("Failed to REMOVE from calendar event with error: \(error)")
                        }
                }
                if(expense.reminderID! != ""){
                    let reminder = eventStore.calendarItem(withIdentifier: expense.reminderID!) as! EKReminder
                    do{
                        try             self.eventStore.remove(reminder, commit: true)
                        
                        
                    }catch let error as NSError{
                        print("Failed to REMOVE from calendar reminder with error: \(error)")
                    }
                }
            }
            
            context.delete(object)
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        autoSelectTableRow()
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategoryDetails":
            if let indexPath = tableView.indexPathForSelectedRow{
                var object: Category
                    object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailDelegate = self
                controller.selectedCategory = object as Category
            }
        case "addCategory":
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
            }
        case "editCategory":
            if let indexPath = tableView.indexPathForSelectedRow {
                let object =  fetchedResultsController.object(at:indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! AddEditCategoryTableViewController
                //print("object \(object)")
                controller.addeditCategoryTableViewDelegate = self
                controller.editingCategory = object as Category
            }
        default:
            print("Error accorded")
        }
    }
    
    @IBAction func alphabeticallyCheck(_ sender: UIBarButtonItem) {
        
        if sender.tag == 1{
            sortedAlphabetically = true
            _fetchedResultsController = nil
            tableView.reloadData()
        }
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Category>{
        if _fetchedResultsController != nil{
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Set the batch size to a suitable number
        fetchRequest.fetchBatchSize = 20
        print("sortedAlphabetically.ttt \(self.sortedAlphabetically)")
        
        if self.sortedAlphabetically {
        // Edit the sort key as appropriate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

          fetchRequest.sortDescriptors = [sortDescriptor]
        }else{
            let sortDescriptor = NSSortDescriptor(key: "selCount", ascending: false)
            
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedOC!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Category>? = nil

    //var _fetchedResultsControllerAl: NSFetchedResultsController<Category>? = nil
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)! as! CategoryTableViewCell, withCategory: anObject as! Category)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! CategoryTableViewCell, withCategory: anObject as! Category)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        
        // update UI
        //autoSelectTableRow()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func configureCell(_ cell: CategoryTableViewCell, withCategory category: Category) {
        cell.categoryCellInit(category.name ?? "", monthlyBudget: category.monthlyBudget, color: category.color, note: category.note ?? "")
    }
    
    func showNotes(cell: CategoryTableViewCell, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: categoriesTable)
        showRect = categoriesTable.convert(showRect, to: view)
        showRect.origin.y -= 5
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController
        controller?.modalPresentationStyle = .popover
        controller?.preferredContentSize = CGSize(width: 300, height: 250)
        controller?.notes = notes
        
        if let popoverPresentationController = controller?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = showRect
            
            if let popoverController = controller {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    func save(){
        print("masterr")
        if let index = indexSelectedCategory{
            let object =  fetchedResultsController.object(at: index)
            self.performSegue(withIdentifier: "showCategoryDetails", sender: object)
        }
    }
}

extension MasterTableViewController: CategoryTableViewCellDelegate{
    func customCell(cell: CategoryTableViewCell, sender button: UIButton, data data:String){
        self.showNotes(cell: cell, forButton: button, forNotes: data)
    }
}

extension MasterTableViewController: DetailViewControllerDelegate{
    func completeSaveExpense() {
        self.save()
    }
}

extension MasterTableViewController: AddEditCategoryTableViewControllerDelegate{
    func completeSaveCategory() {
        self.save()
    }
    
    
}
