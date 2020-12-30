//
//  CountDownViewController.swift
//  spillb
//
//  Created by Projects on 10/5/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit

class CountDownViewController : UIViewController{
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var countingNumber = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel.text = String(countingNumber)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if(self.countingNumber > 0) {
                self.countingNumber -= 1
                if self.countingNumber == 0 {
                    self.timerLabel.text = "Go!"
                } else {
                    self.timerLabel.text = String(self.countingNumber)
                }
            } else {
                Timer.invalidate()
                self.dismiss(animated: true)
            }
        }
    }
    
}
