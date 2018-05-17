//
//  ViewController.swift
//  LockNote
//
//  Created by Valentinas Mirosnicenko on 5/5/18.
//  Copyright © 2018 Valentinas Mirosnicenko. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class NoteVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var controller: NSFetchedResultsController<Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchNotes()
        tableView.reloadData()
    }
    
    @IBAction fileprivate func addNoteButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showNoteDetail", sender: nil)
    }
    
    fileprivate func fetchNotes() {
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: CoreDataService.instance.context!,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
        controller.delegate = self
        
        self.controller = controller 
        
        do {
            try controller.performFetch()
        } catch {
            debugPrint(error.localizedDescription)
        }
        
    }
    
    fileprivate func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Error",
                                        message: message,
                                        preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func authenticateBiometrics(completion: @escaping (Bool) -> Void) {
        
        let myContext = LAContext()
        let myLocalizedReasonString = "Our app uses TouchID/FaceID to secure your notes."
        var authError: NSError?
        
        
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { (success, error) in
                    if success {
                        completion(true)
                    } else {
                        guard let evaluateErrorString = error?.localizedDescription else { return }
                        self.showAlert(message: evaluateErrorString)
                        completion(false)
                    }
                }
            } else {
                guard let authErrorString = authError?.localizedDescription else { return }
                showAlert(message: authErrorString)
                completion(false)
            }
        } else {
            completion(false)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        guard let destination = segue.destination as? NoteDetailVC else { return }
        
        if identifier == "showNoteDetail" {
            if let note = sender as? Note {
                destination.selectedNote = note
            }
        }
    }
    
}

extension NoteVC: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
            
        case.insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case.update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! NoteCell
                let note = controller.object(at: indexPath) as! Note
                cell.configureCell(note: note)
                
            }
            break
            
        case.delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
        case.move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        }
        
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension NoteVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath) as? NoteCell else { return UITableViewCell() }
        let object = controller.object(at: indexPath)
        cell.configureCell(note: object)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = controller.object(at: indexPath)
        
        if note.isLocked {
            authenticateBiometrics { (authenticated) in
                if authenticated {
                    CoreDataService.instance.unlockNote(note: note)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showNoteDetail", sender: note)
                    }
                    
                }
            }
        } else {
            performSegue(withIdentifier: "showNoteDetail", sender: note)
        }
        
    }
}
