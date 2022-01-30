//
//  EventTableViewCell.swift
//  Kamaemon
//
//  Created by mad2 on 21/1/22.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var hours: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var category: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8))
    }
    
}
