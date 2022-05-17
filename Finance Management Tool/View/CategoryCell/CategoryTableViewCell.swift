//
//  CategoryTableViewCell.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-13.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabelName: UILabel!
    @IBOutlet weak var categoryBudget: UILabel!
    
    var cellDelegate: CategoryTableViewCellDelegate?
    var notes: String = "Not Available"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func noteInfoClick(_ sender: Any){
        self.cellDelegate?.customCell(cell: self, sender: sender as! UIButton, data: notes)
    }
    
    func categoryCellInit(_ categoryName: String, monthlyBudget: Double, color: Int64, note: String)  {
        categoryView.backgroundColor = UIColor.categoryColor[Int(color)]
        categoryLabelName.text = categoryName
        categoryBudget.text = String(monthlyBudget)
        self.notes = note
    }
    
}

protocol CategoryTableViewCellDelegate {
    func customCell(cell: CategoryTableViewCell, sender button: UIButton, data data: String)
}
