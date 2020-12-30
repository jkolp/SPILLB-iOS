//
//  CreateRoomViewController.swift
//  spillb
//
//  Created by Projects on 9/15/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import VoxeetSDK

class CreateRoomViewController : UIViewController {
    

    @IBOutlet weak var roomTitle: UITextField!
    @IBOutlet weak var numParticipantLabel: UILabel!
    @IBOutlet weak var stepperButton: UIStepper!
    @IBOutlet weak var roomTitleBox: UIView!
    @IBOutlet weak var numParticipantBox: UIView!
    @IBOutlet weak var createRoomButton: UIButton!
 
    
    var rapRoomInfo : RapRoom?
    var conferenceObject : VTConference?
    
    // Refernce to database
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation bar as transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        
       let backbutton = UIButton(type: .custom)
        backbutton.setImage(UIImage(named: "backButton.png"), for: [])
        backbutton.setTitle("Back", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        
        roomTitleBox.layer.cornerRadius = roomTitleBox.frame.size.height / 5
        numParticipantBox.layer.cornerRadius = numParticipantBox.frame.size.height / 5
        createRoomButton.layer.cornerRadius = 10
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        numParticipantLabel.text = String(stepperValue)
        numParticipantLabel.textColor = UIColor.black
    }
    
    @IBAction func createButtonPressed(_ sender: UIButton) {
        
        // Save newly created room info into database
        var participants : [String] = []
        participants.append((Auth.auth().currentUser?.displayName)!)
        
        let title = roomTitle.text ?? ""
        
        if title == "" {
            let alert = UIAlertController(title: "Please enter a room title", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

            self.present(alert, animated: true)
        } else {
            rapRoomInfo = RapRoom(title: title, participants: participants, numParticipantsAllowed: Int(stepperButton.value), isAvailable: true)
            
            db.collection("rooms").document(title).setData([
                "title" : title,
                "numParticipantsAllowed": stepperButton.value,
                "createdDateTime" : Date().timeIntervalSince1970,
                "participants" : participants,
                "isAvailable" : true,
                "isMusicPlaying" : false
                //"currentRapper" : participants[0]
            ]){ (error) in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    print ("Successfully saved data.")
                }
            }
            performSegue(withIdentifier: "createToRoom", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "createToRoom") {
            if let destination = segue.destination as? RoomViewController {
                destination.rapRoomInfo = self.rapRoomInfo
            }
        }
    }
    
    
    @objc func back(){
        navigationController?.popViewController(animated: true)
    }
    
}
