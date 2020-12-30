//
//  ParticipantsTableViewCell.swift
//  spillb
//
//  Created by Projects on 10/11/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit

class ParticipantsTableViewCell: UITableViewCell {

    @IBOutlet weak var participantDisplayName: UILabel!
    @IBOutlet weak var indexLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
