//
//  UserEventViewCell.swift
//  Kamaemon
//
//  Created by Jordan Choi on 28/1/22.
//

import Foundation
import UIKit

class UserEventViewCell: UITableViewCell {
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var eventNameLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var additionRemarksLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusHighlightView: UIView!
    
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
