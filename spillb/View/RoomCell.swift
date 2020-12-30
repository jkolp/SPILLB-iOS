//
//  RoomCell.swift
//  spillb
//
//  Created by Projects on 9/23/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {


    @IBOutlet weak var backGround: UIView!
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var numParticipantsLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var enterButton: UIButton!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        enterButton.layer.cornerRadius = 10
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //print("\(roomTitleLabel.text!) Button Pressed")
    
        // TODO : If there's still room, create session and update number of particicpants
    }
}
