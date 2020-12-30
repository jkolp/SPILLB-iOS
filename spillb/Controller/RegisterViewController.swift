//
//  RegisterViewController.swift
//  spillb
//
//  Created by Projects on 9/11/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseAuth
import VoxeetSDK

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailViewBox: UIView!
    @IBOutlet weak var passwordViewBox: UIView!
    @IBOutlet weak var displayNameViewBox: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set navigation bar as transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        emailViewBox.layer.cornerRadius = emailViewBox.frame.size.height / 5
        passwordViewBox.layer.cornerRadius = passwordViewBox.frame.size.height / 5
        displayNameViewBox.layer.cornerRadius = passwordViewBox.frame.size.height / 5
        registerButton.layer.cornerRadius = 10
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
    
        if let email = emailTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text {
            // If user left either fields empty
            if (email == "" || password == "" || displayName == ""){
                let alert = UIAlertController(title: "Please enter all information to register.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
            // Create user into firebase auth
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        self.displayErrorMessage(e)
                    } else {
                        // Add displayName to currentUser then open session
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = displayName
                        changeRequest?.commitChanges(completion: { (error) in
                            if let e = error {
                                self.displayErrorMessage(e)
                            } else {
                                print("AUTH successfully added")
                                
                                // Start session using VoxeetSDK
                                let userInfo = VTParticipantInfo(externalID: nil, name: Auth.auth().currentUser?.displayName, avatarURL: nil)
                                self.openSession(userInfo: userInfo)
                                
                                self.performSegue(withIdentifier: "registerToLobby", sender: self)
                            }
                        }) // commitChanges
                        
                    } // else
                } // .createUser()
            }
        }
    }
    
    func openSession(userInfo: VTParticipantInfo){
        VoxeetSDK.shared.session.open(info: userInfo) { (error) in
            if let e = error {
                let alert = UIAlertController(title: e.localizedDescription, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                self.present(alert, animated: true)
                
                print("Failed to open session")
            } else {
                print("Open session successful")
            }
        }
    } // End of openSession
    
    func displayErrorMessage(_ error: Error){
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
        
        print(error.localizedDescription)
    } // End of displayErrorMessage
}
