//
//  AddEditCategoryViewController.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-08.
//

import Foundation
import UIKit
import CoreData
import EventKit

protocol AddEditCategoryTableViewControllerDelegate {
    func completeSaveCategory()
}

class AddEditCategoryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {

    //initialising the UI objects
    @IBOutlet weak var addCategoryButton: UIButton!
    @IBOutlet weak var categoryNameInputField: UITextField!
    @IBOutlet weak var categoryBudgetInputField: UITextField!
    @IBOutlet weak var firstThemeButton: UIButton!
    @IBOutlet weak var secondThemeButton: UIButton!
    @IBOutlet weak var thirdThemeButton: UIButton!
    @IBOutlet weak var fourthThemeButton: UIButton!
    @IBOutlet weak var fifthThemeButton: UIButton!
    @IBOutlet weak var sixthThemeButton: UIButton!
    @IBOutlet weak var seventhThemeButton: UIButton!
    @IBOutlet weak var categoryNotesTextInputField: UITextView!
    
    var categories: [NSManagedObject] = []
    var datePickerVisible: Bool = false
    var editCategoryMode: Bool = false
    let currentDate = Date();
    var selectedTheme: UIButton? = nil
    var selectedThemeTag: Int = 0
    var selectedCount: Int64 = 1
    var addeditCategoryTableViewDelegate: AddEditCategoryTableViewControllerDelegate?
    let formatter: Formatter = Formatter()
    
    // Setting the category
    var editingCategory: Category? {
        didSet {
            // Update the view.
            editCategoryMode = true

            configureEditCategoryView()

        }
    }
    
    var colorArr: [UIButton] {
        return [firstThemeButton, secondThemeButton, thirdThemeButton, fourthThemeButton, fifthThemeButton, sixthThemeButton, seventhThemeButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predefineCategory()
        configureEditCategoryView()
        // Disable add category button
        checkAddButton()
        
    }
    
    
    @IBAction func handleColorSelector(_ sender: UIButton){
        selectedColorValidate(sender: sender)
        checkAddButton()
        
    }
    
    // Cancel the category creation
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissPopOver()
    }
    
    @IBAction func handleInputValue(_ sender: UITextField) {
        checkAddButton()
        
    }
    
    
    @IBAction func handleBudgetInputValue(_ sender: UITextField) {
        checkAddButton()
        if sender.text != nil{
            let input = Int(sender.text!)
            if input == nil {
                let alert = UIAlertController(title: "Error", message: "Please enter only numbers.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in sender.text = ""}))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    // Add the category creation
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validateInputFields(){
            
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
            var category = NSManagedObject()
            if editCategoryMode {
                category = (editingCategory as? Category)!
            }else{
                category = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            
            category.setValue(categoryNameInputField.text!, forKey: "name")
            category.setValue(categoryNotesTextInputField.text!, forKey: "note")
            category.setValue(Double(categoryBudgetInputField.text!), forKey: "monthlyBudget")
            category.setValue(Int64(self.selectedThemeTag), forKey: "color")
            category.setValue(self.selectedCount, forKey: "selCount")

            //print(category)
            do{
                // Save to Core data
                try managedContext.save()
                self.addeditCategoryTableViewDelegate?.completeSaveCategory()
                categories.append(category)
            }catch _ as NSError{
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the project.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissPopOver()
    }
    
    //MARK: - functions
    // Dismiss Popover
    func dismissPopOver() {
        dismiss(animated: true, completion: nil)
        //Change the target to 13 ios
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    func configureEditCategoryView() {
        //print("editCategoryMode \(editCategoryMode)")
        if editCategoryMode{
            self.navigationItem.title = "Edit Category"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if let category = editingCategory {
            print("category.monthlyBudget \(category.monthlyBudget)")
            if let categoryName = categoryNameInputField{
                categoryName.text = category.name
            }
            if let categoryBudget = categoryBudgetInputField{
                categoryBudget.text = String(category.monthlyBudget)
            }
            if let button = firstThemeButton {
                self.selectedThemeTag = Int(editingCategory?.color ?? 0)
                    updateButtonView(tag: Int(editingCategory?.color ?? 0))
            }
            
            if let categoryNotes = categoryNotesTextInputField{
                categoryNotes.text = editingCategory?.note
            }
            
            self.selectedCount = editingCategory?.selCount ?? 1
            
        }
    }
    
    
    // check the status and configure the necessary changes
    func predefineCategory() {
        if !editCategoryMode{
            // Settings the placeholder for notes inputField
            categoryNotesTextInputField.delegate = self
            categoryNotesTextInputField.text = "Notes"
            categoryNotesTextInputField.textColor = UIColor.lightGray
        }
    }
    
    // Handles the add category button state
    func checkAddButton() {
        if validateInputFields() {
            addCategoryButton.isEnabled = true;
        } else {
            addCategoryButton.isEnabled = false;
        }
    }
    
    // Check if the required fields are empty or not
    func validateInputFields() -> Bool {
        if !(categoryNameInputField.text?.isEmpty)! &&
            !(categoryBudgetInputField.text?.isEmpty)! &&
            !(categoryNotesTextInputField.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    //check for the color selected
    func selectedColorValidate(sender: UIButton) {
        self.selectedTheme = getColorByTag(tag: sender.tag, colorArr: colorArr)
        self.selectedThemeTag = sender.tag
        updateButtonView(tag: sender.tag)
    }
    
    func updateButtonView(tag:Int){
        for index in 0...colorArr.count-1{
            if (index == tag){
                colorArr[index].layer.borderWidth = 2
            }else{
                colorArr[index].layer.borderWidth = 0
            }
        }
    }
    
    func getColorByTag(tag: Int, colorArr: [UIButton]) -> UIButton {
        var color: UIButton = colorArr[0]
        for index in 0...colorArr.count-1{
            if (index == tag){
                color = colorArr[index]
                return color
            }
        }
        return color
    }
    
}

extension AddEditCategoryTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            categoryNameInputField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            categoryNotesTextInputField.becomeFirstResponder()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}


extension AddEditCategoryTableViewController: AddEditCategoryTableViewControllerDelegate{
    func completeSaveCategory() {}
    
}
