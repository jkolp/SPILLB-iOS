//
//  AppDelegate.swift
//  spillb
//
//  Created by Projects on 9/3/20.
//  Copyright © 2020 Jen. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import IQKeyboardManagerSwift
import VoxeetSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Database Initialization
        let db = Firestore.firestore()
        
        // IQKeyboard
        IQKeyboardManager.shared.enable = true  // To set view above keyboard
        IQKeyboardManager.shared.enableAutoToolbar = false // To remove extra layer above keyboard
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // Initialization of the Voxeet SDK.
        let consumerKey = "mS84fhn41HUFUWmXuc-zjg=="
        let consumerSecret = "Tl_5uCNmw9_zvqL7RUGOtQIl8xoZwliqfnqDIOUVpbk="
        VoxeetSDK.shared.initialize(consumerKey: consumerKey, consumerSecret: consumerSecret)
        
        // Public variables to change conference behavior
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = false
        VoxeetSDK.shared.conference.audio3D = false

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        
        
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let db = Firestore.firestore()

        if let currentUser = Auth.auth().currentUser {
    
            let displayName = currentUser.displayName!
            
            print(displayName)    // This prints
            
            
            // Remove users from all participating rooms when app is terminating
            
            db.collection("rooms").whereField("participants", arrayContains: displayName)
                .getDocuments { (querySnapshot, error) in
    
                    print("Hello World!") // This does not print, and the code below doesn't seem to respond
                    
                    if let e = error {
                        print (e.localizedDescription)
                    } else {
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                let participantsArray = data["participants"] as? [String]
                                print(participantsArray![0])
                            }
                        }
                    }
                } // db.collection("rooms")
                do {    // log out current user when terminating app
                    try Auth.auth().signOut()
                    print("Successfully logged out during termination")
                } catch let e as NSError {
                    print(e.localizedDescription)
                }
            } else {
                print("No Current User Signed In")
            }
        print ("End of applicationWillTerminate")   // This prints
    }
}


    /*
           db.collection("rooms").whereField("participants", arrayContains: displayName).getDocuments(){ (querySnapshot, error) in
                   print("AFter")
                   if let e = error {
                       print (e.localizedDescription)
                   } else {
                       if let snapshotDocuments = querySnapshot?.documents {
                           for doc in snapshotDocuments {
                               let data = doc.data()
                               print(data)
                           }
                       }
                   }
           } // db.collection("rooms")
*/
