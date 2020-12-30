//
//  ViewController.swift
//  spillb
//
//  Created by Projects on 9/3/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {



    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
    }
    
}

