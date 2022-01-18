//
//  VolunteerListViewController.swift
//  Kamaemon
//
//  Created by mad2 on 18/1/22.
//

import Foundation
import UIKit

class VolunteerListViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    
    var data = [
            ["⚽️ Soccer",       "⛳️ Golf",      "🏀 Basketball",    "🏈 American Football",
             "⚾️ Baseball",     "🎾 Tennis",    "🏐 Valleyball",    "🏸 Badminton"],
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
       // Code to refresh table view
        
        print("refreshed")
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        currentTableView = 0
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
