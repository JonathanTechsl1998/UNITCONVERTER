//
//  NotesViewController.swift
//  Finance Management Tool
//
//  Created by Jonathan Chanuka Gurusinghe on 2021-07-13.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var notesTextView: UITextView!
    
    var notes: String? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        if let notes = notes {
            if let notesTextView = notesTextView {
                notesTextView.text = notes
            }
        }
    }

}
