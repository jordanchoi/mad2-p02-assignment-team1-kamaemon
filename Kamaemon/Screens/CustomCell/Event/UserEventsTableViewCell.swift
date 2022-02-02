//
//  UserEventsTableViewCell.swift
//  Kamaemon
//
//  Created by Jordan Choi on 29/1/22.

import UIKit

class UserEventsTableViewCell: UITableViewCell {
    @IBOutlet weak var statusViewBar: UIView!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var eventLocationLbl: UILabel!
    @IBOutlet weak var eventDateLbl: UILabel!
    @IBOutlet weak var eventDescLbl: UILabel!
    @IBOutlet weak var eventRemarksLbl: UILabel!
    @IBOutlet weak var eventStatusLbl: UILabel!
    @IBOutlet weak var eventStatusHighlightView: UIView!
    
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

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
}
