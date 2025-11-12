//
//  cellHomeTableViewCell.swift
//  DoAn_ios
//
//  Created by  User on 09.11.2025.
//

import UIKit

class cellHomeTableViewCell: UITableViewCell {
    @IBOutlet weak var txtDeadLine:UILabel!
    @IBOutlet weak var txtTitle:UILabel!
    @IBOutlet weak var datetimeDeadLine:UILabel!
    @IBOutlet weak var statusIcon:UIImageView!
    @IBOutlet weak var isGhimIcon:UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
