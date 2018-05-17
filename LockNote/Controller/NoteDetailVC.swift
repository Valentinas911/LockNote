//
//  NoteDetailVC.swift
//  LockNote
//
//  Created by Valentinas Mirosnicenko on 5/5/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit

class NoteDetailVC: UIViewController {

    @IBOutlet private weak var messageText: UITextView!
    
    var selectedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configureNote(note: Note?) {
        if note != nil {
            selectedNote = note
            messageText.text = selectedNote?.message
        }
    }
    
    @IBAction func lockButtonPressed(_ sender: Any) {
        
        guard let note = selectedNote else { return }
        
        if note.isLocked {
            note.isLocked = false
        } else {
            note.isLocked = true
        }
        
        CoreDataService.instance.saveContext()
        
        navigationController?.popViewController(animated: true)
    }
    
}
