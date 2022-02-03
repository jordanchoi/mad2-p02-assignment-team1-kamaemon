//
//  LeaderboardViewController.swift
//  Kamaemon
//
//  Created by mad2 on 3/2/22.
//

import Foundation
import UIKit
import Firebase
class CustomCellLeaderboard:UITableViewCell{
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rank: UILabel!
}

class LeaderboardViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    let appDelegate = (UIApplication.shared.delegate) as! AppDelegate
    var highestHrs:[Int] = []
    var highestScorer:[String] = []
    override func viewDidLoad() {
        highestHrs = appDelegate.highestHrs
        highestScorer = appDelegate.highestScorer
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        highestHrs = appDelegate.highestHrs
        highestScorer = appDelegate.highestScorer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomCellLeaderboard = self.tableView.dequeueReusableCell(withIdentifier: "leaderboardCell") as! CustomCellLeaderboard
        cell.hours.text = "\(highestHrs[indexPath.row]) Hours"
        cell.rank.text = "\(indexPath.row+1)"
        cell.name.text = "\(highestScorer[indexPath.row])"
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(highestScorer.count) SCORE")
        return highestHrs.count
    }
}

