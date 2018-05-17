//
//  NoteCell.swift
//  LockNote
//
//  Created by Valentinas Mirosnicenko on 5/5/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var lockImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func configureCell(note: Note) {
        
        if note.isLocked == true {
            lockImage.isHidden = false
            messageLabel.text = "This note is locked."
        } else {
            lockImage.isHidden = true
            messageLabel.text = note.message
        }
        
    }
    
}
