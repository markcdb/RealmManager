//
//  ViewController.swift
//  RealmManagerExample
//
//  Created by Mark Christian Buot on 03/09/2017.
//  Copyright © 2017 Morph. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bbtnAdd: UIBarButtonItem!
    @IBOutlet weak var bbtnEdit: UIBarButtonItem!
    @IBOutlet weak var tblMessage: UITableView!
    
    var arrMessage: [Message]? = []
    //Init
    
    //Lazy
    lazy var acMessage: UIAlertController = {
        let alertController = UIAlertController(title: "Enter Message", message: "Add content below", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            
            let message = alertController.textFields?[0].text
            self.perform(#selector(self.saveMessage(message:)), with: message)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField(configurationHandler: { (textfield: UITextField) in
            textfield.placeholder = "Enter content"
        })
        
        return alertController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        
        self.fetch()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetch() {
        if arrMessage != nil {
            arrMessage?.removeAll()
        }
        //Fetches all objects inside 'Message' model class
        RealmManager.fetch(model: "Message", condition: nil, completionHandler: { (result) in
            
            for message in result {
                if let msg = message as? Message {
                    self.arrMessage?.append(msg)
                }
            }
            
            print(self.arrMessage!)
            self.tblMessage.reloadData()
        })
    }
    
    @objc func saveMessage(message: String) {
        let msg = Message()
        msg.content = message
        /*
         Here, we create an 'object' instance and pass the value of parameter message as content
         and then we called RealmManager.addOrUpdate and passed the msg as parameter for the
         insertion of the new data to 'Message' model class
         */
        RealmManager.addOrUpdate(model: "Message", object: msg, completionHandler: { (error) in
            if let err = error {
                print("Error \(err.localizedDescription)")
            } else {
                self.fetch()
            }
        })
    }
    
    @IBAction func didTapBbtnAdd(_ sender: Any) {
        self.present(self.acMessage, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tblMessage.setEditing(editing, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Tableview Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arM = arrMessage {
            return arM.count
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default , reuseIdentifier: "MessageCell")
        }
        
        if let arM = arrMessage {
            cell?.textLabel?.text = arM[indexPath.row].value(forKey: "content") as? String
        }
        
        return cell!
    }
    
    //MARK Tableview Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let arM = arrMessage {
                /*
                 We're deleting the object that needs to be deleted inside the 'Message' class model by
                 providing a predicate and passing it to condition: parameter, if found a match,
                 it will  delete the object inside the realmdb
                 */
                RealmManager.delete(model: "Message", condition: "content == '\(arM[indexPath.row].value(forKey: "content") as! String)'", completionHandler: { (error) in
                    if let err = error {
                        
                        print(err.localizedDescription)
                    } else {
                        self.arrMessage?.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        print("Deleted. New list: \(String(describing: self.arrMessage))")
                    }
                })
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}
