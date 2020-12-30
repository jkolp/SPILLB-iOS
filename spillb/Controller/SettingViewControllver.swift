//
//  SettingControllverView.swift
//  spillb
//
//  Created by Projects on 9/14/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseAuth
import VoxeetSDK

class SettingViewController : UIViewController {
    
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // set navigation bar as transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        // Setting custom back button for setting page
        let backbutton = UIButton(type: .custom)
        //backbutton.setImage(UIImage(named: "backButton.png"), for: [])
        backbutton.setTitle("Back", for: .normal)
        backbutton.setTitleColor(backbutton.tintColor, for: .normal)
        backbutton.addTarget(self, action: #selector(back), for: .touchUpInside)

        
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = logOutButton
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        logout()
    }
    
    
    @objc func back(){
        navigationController?.popViewController(animated: true)
    }
    
    // Log out user from Firebase
    // Close session from Voxeet
    // Return to Root view
    @objc func logout(){
        do {
            try Auth.auth().signOut()
            VoxeetSDK.shared.session.close{ error in
                if let e = error {
                    print (e.localizedDescription)
                } else {
                    print ("Session closed sucessfully")
                }
            }
            navigationController?.popToRootViewController(animated: true)   // Back to root view
            
        } catch let signOutError as NSError {
            let alert = UIAlertController(title: signOutError.localizedDescription, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
        }
    }
}
