//
//  AppDelegate.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 09/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let searchEnginge = (UserDefaults.standard.value(forKey: "SearchURL") as? String) {
            SharedManager.sharedManager.defaultSearchEngine = searchEnginge
        }
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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveHistoryDetails()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveHistoryDetails()
    }

    func saveHistoryDetails() {
        let docsBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customPlistURL = docsBaseURL.appendingPathComponent("testfile")
        print(customPlistURL.absoluteString)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: SharedManager.sharedManager.historyDictionary, requiringSecureCoding: false)
            try data.write(to: customPlistURL)
        } catch {
            print("Couldn't write file")
        }
//        do {
//            let encodedData = try NSKeyedArchiver.archivedData(withRootObject: SharedManager.sharedManager.historyDictionary, requiringSecureCoding: false)
//            
//            UserDefaults.standard.set(encodedData, forKey: "items")
//        } catch {
//            print("Couldn't write file")
//        }
    }

}

