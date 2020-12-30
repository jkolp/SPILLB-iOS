//
//  LobbyViewController.swift
//  spillb
//
//  Created by Projects on 9/12/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LobbyViewController : UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    var rapRooms : [RapRoom] = []
    var currentTag : Int = 0  // button tag for the index in rapRoom array
    var userDisplayName = Auth.auth().currentUser?.displayName
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation bar as transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "RoomCell", bundle: nil), forCellReuseIdentifier: "roomCell") // Register custom Cell
        tableView.backgroundView = UIImageView(image: UIImage(named: "rapper2"))
        tableView.backgroundView?.contentMode = UIView.ContentMode.scaleAspectFill
        
        // Add left bar button item in the navigation bar
        let settingButton = UIBarButtonItem(image: UIImage(named: "gearIcon"), style: .plain, target: self, action: #selector(goToSetting))
        self.navigationItem.leftBarButtonItem = settingButton
        self.navigationItem.title = "Lobby"
        
        let createRoomButton = UIBarButtonItem(title: "Create Room", style: .plain, target: self, action: #selector(goToCreateRoom))
        self.navigationItem.rightBarButtonItem = createRoomButton
        
        welcomeLabel.text = "Welcome \((Auth.auth().currentUser?.displayName)!)!"

        loadRooms()
    }
    
    @objc func goToSetting(){
        print("setting button tapped")
        performSegue(withIdentifier: "lobbyToSetting",sender: self)
    }
    
    @objc func goToCreateRoom(){
        print("go to create room buttonm tapped")
        performSegue(withIdentifier: "lobbyToCreateRoom", sender: self)
    }
    
    func loadRooms() {
        db.collection("rooms")
                  .order(by: "createdDateTime")
            .addSnapshotListener { (querySnapshot, error) in
                self.rapRooms = [] // Empty out messages
                if let e = error {
                    print ("There was an issue retrieving data from db")
                    print (e.localizedDescription)
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
        
                            if let roomTitle = data["title"] as? String,
                                let numParticipantsAllowed = data["numParticipantsAllowed"] as? Int,
                                let participants = data["participants"] as? [String],
                                let isAvailable = data["isAvailable"] as? Bool {
                                
                                let newRoom = RapRoom(title: roomTitle, participants: participants, numParticipantsAllowed: numParticipantsAllowed, isAvailable: isAvailable)
                                self.rapRooms.insert(newRoom, at: self.rapRooms.startIndex)
                                self.reorderRapRooms()
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData() // Reload tableview with data
                                    // To push the message everytime new one comes in
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                }
                            }
                        } // documents for loop
                    } // query
                } // error else
            }
    }
    
    func reorderRapRooms(){
        // pop all unavailable rooms to the very bottom(end of the array)
        for i in 0..<self.rapRooms.count {
            if (!self.rapRooms[i].isAvailable) {
                let tempRapRoom = self.rapRooms[i]
                self.rapRooms.remove(at: i)
                self.rapRooms.insert(tempRapRoom, at: self.rapRooms.endIndex)
            }
        }
    }
}


// MARK: - UITableViewDataSource : Responsible data for the table

extension LobbyViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return Number of rows
        //print("Rap room count : " + self.rapRooms.count)
        return self.rapRooms.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Custimze cell in this method
        // return customized cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath) as! RoomCell
        tableView.backgroundColor = .clear
        cell.backgroundColor = UIColor(named: "BackgroundColor")?.withAlphaComponent(0.7)
        
        cell.roomTitleLabel.text = self.rapRooms[indexPath.row].title
        
        cell.numParticipantsLabel.text = "\(self.rapRooms[indexPath.row].participants.count)/\(self.rapRooms[indexPath.row].numParticipantsAllowed)"
        
        if self.rapRooms[indexPath.row].isAvailable &&
            self.rapRooms[indexPath.row].participants.count / self.rapRooms[indexPath.row].numParticipantsAllowed != 1 {
            cell.enterButton.isEnabled = true
            cell.enterButton.tag = indexPath.row
            cell.statusImage.image = UIImage(named: "greenCircle")
            cell.statusImage.backgroundColor = UIColor.clear
            cell.enterButton.setTitle("Enter", for: .normal)
            cell.enterButton.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControl.Event.touchUpInside)
            cell.enterButton.backgroundColor = UIColor(named: "ButtonColor")
            cell.roomTitleLabel.textColor = UIColor(named: "Beige")
            cell.numParticipantsLabel.textColor = UIColor(named: "Beige")
        } else {
            self.rapRooms[indexPath.row].isAvailable = false
            cell.enterButton.isEnabled = false
            cell.statusImage.image = UIImage(named: "redCircle")
            cell.statusImage.backgroundColor = UIColor.clear
            cell.enterButton.setTitle("Unavailable", for: .disabled)
            
            cell.enterButton.backgroundColor = UIColor(named: "ButtonColor")?.withAlphaComponent(0.4)
            cell.roomTitleLabel.textColor = UIColor(ciColor: .black).withAlphaComponent(0.4)
            cell.numParticipantsLabel.textColor = UIColor(ciColor: .black).withAlphaComponent(0.4)
            
        }
        return cell
    }
    
    @objc func buttonTapped(_ sender:UIButton!){
        currentTag = sender.tag // Current Index in  rappRooms[]
        
        let currentRoom = self.rapRooms[currentTag]
        
        var participantsArray = currentRoom.participants
        participantsArray.append(userDisplayName!)
        
        if (participantsArray.count == currentRoom.numParticipantsAllowed) {
            db.collection("rooms").document(self.rapRooms[self.currentTag].title).updateData([
                "participants" : participantsArray,
                "isAvailable" : false
            ])
        } else {
            db.collection("rooms").document(self.rapRooms[self.currentTag].title).updateData([
                "participants" : participantsArray
            ])
        }
    
        self.performSegue(withIdentifier: "lobbyToRoom", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender!)
        if(segue.identifier == "lobbyToRoom") {
            if let destination = segue.destination as? RoomViewController {
                destination.rapRoomInfo = rapRooms[currentTag]
                print("Entering room : " + destination.rapRoomInfo!.title)
            }
        }
    }
}
