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
        
        messageText.delegate = self
        
        if selectedNote != nil {
            messageText.text = selectedNote?.message
        } else {
            messageText.text = "Note down your thoughts here..."
        }
        
    }
    
    @IBAction fileprivate func saveButtonPressed(_ sender: Any) {
        saveNote(andLock: false)
    }
    
    
    @IBAction fileprivate func lockButtonPressed(_ sender: Any) {
        saveNote(andLock: true)
    }
    
    fileprivate func saveNote(andLock lock: Bool) {
        var note: Note?
        
        if selectedNote != nil {
            note = selectedNote
        } else {
            note = Note(context: CoreDataService.instance.context)
        }
        
        note?.dateCreated = NSDate() as Date
        note?.message = messageText.text
        note?.isLocked = lock
        
        CoreDataService.instance.saveContext()
        navigationController?.popViewController(animated: true)
    }

}

extension NoteDetailVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if selectedNote == nil {
            textView.text = ""
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
}
