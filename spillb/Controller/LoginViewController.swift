//
//  LoginViewController.swift
//  spillb
//
//  Created by Projects on 9/11/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseAuth
import VoxeetSDK

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailViewBox: UIView!
    @IBOutlet weak var passwordViewBox: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = "ak@ak.com"
        passwordTextField.text = "apple123"
        
        // set navigation backgroundcolor to clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        let backbutton = UIButton(type: .custom)
               backbutton.setImage(UIImage(named: "backButton.png"), for: [])
               backbutton.setTitle("Back", for: .normal)
               backbutton.setTitleColor(backbutton.tintColor, for: .normal)
               backbutton.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        
        
        emailViewBox.layer.cornerRadius = emailViewBox.frame.size.height / 5
        passwordViewBox.layer.cornerRadius = passwordViewBox.frame.size.height / 5
        loginButton.layer.cornerRadius = 10
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
    
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, Error) in
                // If there's an error, alert error to user
                if let error = Error {
                    self.displayErrorMessage(error)
                } else {
                    // Open Voxeet session
                    let userInfo = VTParticipantInfo(externalID: nil, name: Auth.auth().currentUser?.displayName, avatarURL: nil)
                    self.openSession(userInfo: userInfo)
                    
                    self.performSegue(withIdentifier: "loginToLobby", sender: self)
                }
            }
        }
    }
    
    func displayErrorMessage(_ error: Error){
        let alert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        self.present(alert, animated: true)
        
        print(error.localizedDescription)
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
    }
    
    @objc func back(){
        navigationController?.isNavigationBarHidden = true
    }
}
