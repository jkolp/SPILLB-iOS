//
//  RoomViewController.swift
//  spillb
//
//  Created by Projects on 9/15/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import VoxeetSDK
import FirebaseAuth
import FirebaseFirestore
import AVFoundation

class RoomViewController : UIViewController {
    
    @IBOutlet weak var roomTitle: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var participantsTableView: UITableView!
    @IBOutlet weak var currentParticipantView: UIView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var currentRapperLabel: UILabel!
    @IBOutlet weak var nextRapperLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    
    var AVAudioPlayerDelegate : AVAudioPlayerDelegate?
    var audioPlayer = AVAudioPlayer()
    var rapRoomInfo : RapRoom?
    var conferenceService : VTConferenceService?
    var participantInfo = VTParticipantInfo.init(externalID: nil, name: Auth.auth().currentUser?.displayName, avatarURL: nil)
    var stopListeningToMusicClosure : ListenerRegistration?
    var vtParticipants : [VTParticipant]!

    let shapeLayer = CAShapeLayer()
    var currentRapperListener : ListenerRegistration?
    
    
    // participant index to update current and next rapper labels
    var currentRapperIndex = 0
    
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation bar as transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        startButton.layer.cornerRadius = 10
        
        timerLabel.text = "10"
        timerLabel.textColor = UIColor(named: "Beige")
        
        participantsTableView.dataSource = self
        participantsTableView.register(UINib(nibName: "ParticipantsTableViewCell", bundle: nil), forCellReuseIdentifier: "participationsCell") // Register custom Cell
        participantsTableView.backgroundColor = .clear
        
        currentParticipantView.backgroundColor = UIColor(named: "BackgroundColor")?.withAlphaComponent(0.9)
        
        
        
        // Back button on the navigation bar
        let backbutton = UIButton(type: .custom)
        //backbutton.setImage(UIImage(named: "backButton.png"), for: [])
        backbutton.setTitle("Lobby", for: .normal)
        backbutton.setTitleColor(UIColor(named: "ButtonColor"), for: .normal)
        backbutton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)

        self.roomTitle.text = self.rapRoomInfo?.title
        
        startConference()
        createCircleTimer()
        loadRapRoomInfo()
        playMusic() // Play music when start button is pressed.
    }
    override func viewDidLayoutSubviews() {
        shapeLayer.frame = currentParticipantView.bounds
    }
    
    func createCircleTimer() {
        // Circular Timer

        let circularViewCenter = CGPoint(x: circularView.frame.size.width/2, y: circularView.frame.size.height/2)
        
        let circularPath = UIBezierPath(arcCenter: circularViewCenter, radius: 100, startAngle:  CGFloat.pi / -1/2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Track Layer
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.black.cgColor
        trackLayer.lineWidth = 10
        trackLayer.lineCap = .round
        circularView.layer.addSublayer(trackLayer)
        
        
        // circular path layer
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(named: "ButtonColor")?.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0

        circularView.layer.addSublayer(shapeLayer)
        circularView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(circleAnimation)))
        
    }
    
    //@objc
    @objc func circleAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
        basicAnimation.toValue = 1
        basicAnimation.duration = 12.5
        basicAnimation.fillMode = .forwards
        //basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "urSobasic")
    }
    
    @IBAction func startPressed(_ sender: UIButton) {

    // add all participants to VTParticipant array
    vtParticipants = VoxeetSDK.shared.conference.current!.participants
        
    self.db.collection("rooms").document(self.rapRoomInfo!.title)
            .updateData([
                "isMusicPlaying" : true,
                "isAvailable" : false,
            ])
        
        // Mute all players
        self.muteAllPlayers()
        
        // set first participant and unmute
        var i : Int = 0
        var currentParticipant : VTParticipant = self.vtParticipants[i] // [0]
        
        Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) { (timer) in
            self.conferenceService?.mute(participant: currentParticipant, isMuted: false)

            Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (Timer) in
                self.conferenceService?.mute(participant: currentParticipant, isMuted: true)
                if (self.vtParticipants.count == 1) {
                    print("vtParticipatns.count is 1")
                    Timer.invalidate()
                    self.unMuteAllPlayers()
                } else {
                    if (i < self.vtParticipants.count-1) {
                        i+=1
                        currentParticipant = self.vtParticipants[i]
                        self.conferenceService?.mute(participant: currentParticipant, isMuted: false)
                        print("i is less than vtParticipants.count")
                    } else {
                        print("i is equal or greater than vtParticipants.count")
                        Timer.invalidate()
                        self.unMuteAllPlayers()
                    }
                }
            }
        }
        
        
        
    } // startPressed
    
    func muteAllPlayers(){
    // Mute all current participants
        for participant in vtParticipants {
            conferenceService?.mute(participant: participant, isMuted: true)
        }
    }
    
    func unMuteAllPlayers(){
        for participant in vtParticipants {
            conferenceService?.mute(participant: participant, isMuted: false)
        }
    }
    
    func switchTurns(){
        var timeLeft : Int = 10
        var i = 0

        self.circleAnimation()
        self.timerLabel.text = "\(timeLeft)"
            
        // Timer for first player
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (Timer) in
            timeLeft -= 1
            if (timeLeft != 0){
                self.timerLabel.text = "\(timeLeft)"
            } else {
                self.timerLabel.text = "10"
                Timer.invalidate()
                timeLeft = 10
            }
        }

        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (timer) in
            i+=1
            self.timerLabel.text = "\(timeLeft)"
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timerr) in
                timeLeft -= 1
                if (timeLeft != 0 && i != self.rapRoomInfo?.participants.count){
                    self.timerLabel.text = "\(timeLeft)"
                } else {
                    self.timerLabel.text = "10"
                    timerr.invalidate()
                    timeLeft = 10
                }
            }
            
            
            if (i == self.rapRoomInfo?.participants.count){
                timer.invalidate()
                self.audioPlayer.currentTime = self.audioPlayer.duration - 1 // end music off
                
            } else if (i - 1 < (self.rapRoomInfo?.participants.count)! - 2) {
                self.currentRapperLabel.text = self.rapRoomInfo?.participants[i]
                self.nextRapperLabel.text = "Next Up : \((self.rapRoomInfo?.participants[i+1])!)"
                self.circleAnimation()
            } else if (i - 1 < (self.rapRoomInfo?.participants.count)!){
                self.currentRapperLabel.text = self.rapRoomInfo?.participants[i]
                self.nextRapperLabel.text = ""
                self.circleAnimation()
            }
        }
    } // End of switchTurns()

    
    func playMusic() {
    // When there is an update to "isAvailable" field, then the music will play in all participant's devices
    // Setting stopListeningToMusicClosure to ListenerRegistration type to remove listener when leaving the room.
        
        stopListeningToMusicClosure = db.collection("rooms").document(rapRoomInfo!.title).addSnapshotListener { (documentSnapshot, error) in
            
            if ((documentSnapshot?.exists) != nil){
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    if let document = documentSnapshot {
                        let data = document.data()
                        let isMusicPlaying = (data?["isMusicPlaying"] as? Bool)!
                        if isMusicPlaying {
                            self.performSegue(withIdentifier: "roomToCounter", sender: self)
                            DispatchQueue.main.async {
                                Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { (timer) in
                                    let path = Bundle.main.path(forResource: "oneMin.mp3", ofType:nil)!
                                    let url = URL(fileURLWithPath: path)
                                    do {
                                        self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                                        self.audioPlayer.delegate = self
                                        self.audioPlayer.play()
                                        self.switchTurns()
                                    } catch {
                                        print("Error playing music")
                                    }
                                }
                            } // DispatchQueue
                        } // if isMusicPlaying
                    }
                }// else
            } // if documentSnapshop?.exists
        }// snapshot
    } // Play Music
    
    func startConference(){
        // Create conference object using externalID(Title of the room)
        
        let options = VTConferenceOptions()
        options.alias = rapRoomInfo?.title
        
        conferenceService = VoxeetSDK.shared.conference
        conferenceService!.create(options: options, success: { conference in
            
            let joinOptions = VTJoinOptions()
            joinOptions.constraints.video = false

            VoxeetSDK.shared.conference.join(conference: conference, options: joinOptions, success: { conference in
                print("Conference room : " + conference.alias)
            }, fail: { error in })
        }, fail: { error in
            print(error.localizedDescription)
        })
        
        
    } // End of startConference
    
    
    // Automatically update participant list
    func loadRapRoomInfo() {
        db.collection("rooms").document(rapRoomInfo!.title).addSnapshotListener { (documentSnapshot, error) in
            print("SOMEONE JUST LEFT")
            if let e = error {
                print("Error grabbing room info in room view controll")
                print(e.localizedDescription)
            } else {
                if let document = documentSnapshot {
                    let data = document.data()
                    if let roomTitle = data?["title"] as? String,
                        let numParticipantsAllowed = data?["numParticipantsAllowed"] as? Int,
                        let participants = data?["participants"] as? [String],
                        let isAvailable = data?["isAvailable"] as? Bool {
                        
                            let newRoom = RapRoom(title: roomTitle,
                                                  participants: participants,
                                                  numParticipantsAllowed: numParticipantsAllowed,
                                                  isAvailable: isAvailable)
                            self.rapRoomInfo = newRoom
                            // add all participants to VTParticipant array
                        
                        // when room creator leaves, app crashes because this array is not being updated across all devices.
                            self.vtParticipants = VoxeetSDK.shared.conference.current!.participants
                        
                            DispatchQueue.main.async {
                                // Start Button
                                
                                if (Auth.auth().currentUser?.displayName != self.rapRoomInfo?.participants[0]) {
                                    self.startButton.isHidden = true
                                }else {
                                    self.startButton.isHidden = false
                                }
                                self.participantsTableView.reloadData()
                                self.countLabel.text =
                                    "\(self.rapRoomInfo!.participants.count)/\(self.rapRoomInfo!.numParticipantsAllowed)"
                                
                                // initial rapper name
                                self.currentRapperLabel.text = self.rapRoomInfo?.participants[self.currentRapperIndex]
                                
                                // next up rapper
                                if ((self.rapRoomInfo?.participants.count)! > 1 && self.currentRapperIndex + 1 < (self.rapRoomInfo?.participants.count)!) {
                                    self.nextRapperLabel.text = "Next Up : \(( self.rapRoomInfo?.participants[self.currentRapperIndex+1])!)"
                                } else {
                                    self.nextRapperLabel.text = ""
                                }
                            }
                    }
                }
            }
        }
    } // End of loadRapRoomInfo
    
    
    @objc func back() {
        
        let participantsArray = (self.rapRoomInfo?.participants)!
        
        let alert = UIAlertController(title: "Would you like to leave the room?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alert: UIAlertAction!) in
            self.exitRoom(participantsArray: participantsArray)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

        self.present(alert, animated: true)
    } // End of back

    func exitRoom(participantsArray: [String]){
        stopListeningToMusicClosure?.remove()   // Stop listening to snapshop for playMusic()
        
        // remove the leaving participant and update partcipants count in both UI and database
        print (participantsArray)
           for i in 0..<participantsArray.count {
               if (participantsArray[i] == Auth.auth().currentUser?.displayName) {
                   self.rapRoomInfo?.participants.remove(at: i)    // remove leaving participant
                    break
               }
           }
        
           // Deciding whether to delete the room or not based on participants number
           if (self.rapRoomInfo?.participants.count == 0) {
               print("NO MORE PEOPLE")
               db.collection("rooms").document(self.rapRoomInfo!.title).delete()   // delete if there's no more participants
           } else {
            db.collection("rooms") .document(self.rapRoomInfo!.title).updateData([
                "participants" : self.rapRoomInfo?.participants,
                "isAvailable" : true
                ]) // updating participant field in db
           }

            // Leave conference room
            leaveConference()
        
           // Navigate back to lobby view controller
           if let navController = self.navigationController {
               for controller in navController.viewControllers {
                   if controller is LobbyViewController { // Change to suit your menu view controller subclass
                       
                       navController.popToViewController(controller, animated:true)
                       break
                   }
               }
           }
    } // End of exitRoom
    
    func leaveConference(){
        // Leave conference room
            VoxeetSDK.shared.conference.leave { (NSError) in
            if let e = NSError {
                print(e.localizedDescription)
            } else {
                let alert = UIAlertController(title: "You have left the room", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                self.present(alert, animated: true)
            }
        }
    } // End of leaveConference
}


// MARK: - AVAudioPlayer Delegate
extension RoomViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // When music ends, set isMusicPlaying to false
        // If number of participant is less than the allowed number, then room is available for more participants
        
        print("Music ended************************************")
        
        let isAvailable : Bool
        if (self.rapRoomInfo?.participants.count == self.rapRoomInfo?.numParticipantsAllowed) {
            isAvailable = false
            
        } else {
            isAvailable = true
        }
        
        db.collection("rooms").document(rapRoomInfo!.title)
            .updateData([
                "isMusicPlaying" : false,
                "isAvailable" : isAvailable
            ])
    }
}

// MARK: - UITableViewDataSource

extension RoomViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return Number of rows - return 0 if no participants
        return rapRoomInfo?.participants.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "participationsCell", for: indexPath) as! ParticipantsTableViewCell
        tableView.backgroundColor = .clear
        cell.backgroundColor = UIColor(named: "BackgroundColor")?.withAlphaComponent(0.9)
        
        cell.indexLabel.text = String(indexPath.row + 1)
        cell.indexLabel.textColor = UIColor(named: "Beige")
        cell.participantDisplayName.text = self.rapRoomInfo?.participants[indexPath.row]
        cell.participantDisplayName.textColor = UIColor(named: "Beige")

        return cell
    }
}
