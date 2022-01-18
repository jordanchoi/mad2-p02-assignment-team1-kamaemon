//
//  VolunteerListViewController.swift
//  Kamaemon
//
//  Created by mad2 on 18/1/22.
//
import FirebaseAuth
import Firebase
import Foundation
import UIKit

class VolunteerListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var testList : [String] = []
    var data = [
            ["🍎 Apple",        "🍐 Pear",      "🍓 Strawberry",    "🥑 Avocado",
             "🍌 Banana",       "🍇 Grape",     "🍈 Melon",         "🍊 Orange",
             "🍑 Peach",        "🥝 Kiwi"]
        ]
    
    let refreshControl = UIRefreshControl()
    var currentTableView:Int!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func switchTableViewAction(_ sender: UISegmentedControl) {
        currentTableView = sender.selectedSegmentIndex
        tableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        print(testList.count)
       // Code to refresh table view
                var ref: DatabaseReference!
                ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
                ref.child("test").observeSingleEvent(of: .childAdded, with: { snapshot in
                    ref.child("test").child("beta").observeSingleEvent(of: .value, with: { snapshot in
                      // Get updated user value
                        let value = snapshot.value as? NSDictionary
                        let updatedArr:[String] = value!.allValues.compactMap({ String(describing: $0) })
                        
                        // If not updated, update
                        if(updatedArr != self.testList){
                            self.testList = updatedArr
                            self.data[1] = self.testList
                        }
                    }) { error in
                      print(error.localizedDescription)
                    }
                }) { error in
                  print(error.localizedDescription)
                }
        print("refreshed")
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        currentTableView = 0
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        // DB
        var ref: DatabaseReference!
        ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
        
        ref.child("test").child("beta").observeSingleEvent(of: .value, with: { snapshot in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print("----View did load----")
            print(value)
            print("----View did load----")
            print(value?.allValues)
            print("----View did load----")
                
            for i in value!.allValues{
                let string = i as? String ?? "Error"
                self.testList.append(string)
            }
            self.data.append(self.testList)
        })
        { error in
                print(error.localizedDescription)
        }
        self.tableView.reloadData();
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")
        cell?.textLabel?.text = data[currentTableView][indexPath.row]
        cell?.detailTextLabel?.text = data[currentTableView][indexPath.row]
        return cell!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[currentTableView].count
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
