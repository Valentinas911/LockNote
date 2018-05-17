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
    
    @IBAction func addNoteButtonPressed(_ sender: Any) {
        
    }
    
    fileprivate func fetchNotes() {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "dateCreated", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                managedObjectContext: CoreDataService.instance.context!,
                                                sectionNameKeyPath: nil,
                                                cacheName: nil)
        controller.delegate = self
        
        self.controller = controller as! NSFetchedResultsController<Note>
        
        do {
            try controller.performFetch()
        } catch {
            debugPrint(error.localizedDescription)
        }
        
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
    
    fileprivate func showAlert(message: String) {
        let alertVC = UIAlertController(title: "Error",
                                        message: message,
                                        preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    
    fileprivate func pushNoteFor(indexPath: IndexPath) {
        guard let noteDetailVC = storyboard?.instantiateViewController(withIdentifier: "NoteDetailVC") as? NoteDetailVC else { return }
        noteDetailVC.configureNote(note: controller.object(at: indexPath))
        navigationController?.pushViewController(noteDetailVC, animated: true)
    }
    
}

extension NoteVC: NSFetchedResultsControllerDelegate {
    
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
        
        if controller.object(at: indexPath).isLocked {
            authenticateBiometrics { (authenticated) in
                if authenticated {
                    CoreDataService.instance.unlockNote(note: self.controller.object(at: indexPath))
                    DispatchQueue.main.async {
                        self.pushNoteFor(indexPath: indexPath)
                    }
                    
                }
            }
        } else {
            pushNoteFor(indexPath: indexPath)
        }
        

        
    }
    
    
    
}
