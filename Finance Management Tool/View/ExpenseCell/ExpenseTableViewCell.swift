//
//  TableViewCell.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-13.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var expenseNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var budgetRemainingProgressBar: LinearProgressBar!
    @IBOutlet weak var calendarButton: UIButton!
    
    var cellDelegate: ExpenseTableViewCellDelegate?
    var notes: String = "Not Available"
    let now: Date = Date()
    let formatter: Formatter = Formatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func expenseCellInit(_ expenseName: String, progressValue: Double, expenseBudget: Double, startDate:Date, dueDate: Date, notes: String, reminder: Bool) {
        print("expenseCellInit.reminder \(reminder)")
        expenseNameLabel.text = expenseName
        budgetLabel.text = String(expenseBudget)
        dueDateLabel.text = "Due: \(Formatter.formatDate(dueDate))"
    
        if !reminder {
            calendarButton.tintColor = .lightGray
        }
        
        DispatchQueue.main.async {
            self.budgetRemainingProgressBar.startGradientColor = .linearHighlight
            self.budgetRemainingProgressBar.endGradientColor = .linearHighlight
            self.budgetRemainingProgressBar.progress = CGFloat(progressValue) / 100
        }
        self.notes = notes
    }
    
    @IBAction func handleViewNotes(_ sender: UIButton) {
        self.cellDelegate?.viewNotes(cell: self, sender: sender as! UIButton, data: notes)
    }
}

protocol ExpenseTableViewCellDelegate {
    func viewNotes(cell: ExpenseTableViewCell, sender button: UIButton, data data: String)
}
