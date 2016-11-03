//
//  RohitViewController.swift
//  BoxCricket
//
//  Created by Fnu, Rohit on 11/3/16.
//  Copyright © 2016 Fnu, Rohit. All rights reserved.
//

import UIKit
import Firebase

class RohitViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var ref: FIRDatabaseReference!
    var Vicky: [FIRDataSnapshot]! = []
    var msglength: NSNumber = 10
    
    @IBOutlet weak var tableView: UITableView!
    fileprivate var _refHandle: FIRDatabaseHandle!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDatabase()
        configureStorage()
        configureRemoteConfig()
        fetchConfig()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    deinit {
        self.ref.child("Rohit").removeObserver(withHandle: _refHandle)
        
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        // Listen for new messages in the Firebase database
        _refHandle = self.ref.child("Rohit").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            strongSelf.Vicky.append(snapshot)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.Vicky.count-1, section: 0)], with: .automatic)
        })
    }
    
    func configureStorage() {
    }
    
    func configureRemoteConfig() {
    }
    
    func fetchConfig() {
    }
    

    
    @IBAction func closeView_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Vicky.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tableView .dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath)
        // Unpack message from Firebase DataSnapshot
        let messageSnapshot: FIRDataSnapshot! = self.Vicky[indexPath.row]
        let message = messageSnapshot.value as! Dictionary<String, String>
        let name = message[Constants.MessageFields.name] as String!
        let text = message[Constants.MessageFields.text] as String!
        cell.textLabel?.text = name! + ": " + text!
        cell.imageView?.image = UIImage(named: "ic_account_circle")
        if let photoURL = message[Constants.MessageFields.photoURL], let URL = URL(string: photoURL), let data = try? Data(contentsOf: URL) {
            cell.imageView?.image = UIImage(data: data)
        }
        return cell
    }


}
