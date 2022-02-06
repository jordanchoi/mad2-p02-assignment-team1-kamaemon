//
//  LeaderboardViewController.swift
//  Kamaemon
//
//  Created by mad2 on 3/2/22.
//

import Foundation
import UIKit
import Firebase

class LeaderboardViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    // UI elements
    @IBOutlet weak var tableView: UITableView!
    
    // app delegate
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    
    // initialise lists
    var highestHrs:[Int] = []
    var highestScorer:[String] = []
    
    override func viewDidLoad() {
        // get the highest scorers and the hours
        highestHrs = appDelegate.highestHrs
        highestScorer = appDelegate.highestScorer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // get the highest scorers and the hours
        highestHrs = appDelegate.highestHrs
        highestScorer = appDelegate.highestScorer
    }
    
    // set up table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomCellLeaderboard = self.tableView.dequeueReusableCell(withIdentifier: "leaderboardCell") as! CustomCellLeaderboard
        cell.hours.text = "\(highestHrs[indexPath.row]) Hours"
        cell.rank.text = "\(indexPath.row+1)"
        cell.name.text = "\(highestScorer[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highestHrs.count
    }
}

