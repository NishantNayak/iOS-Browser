//
//  SharedManager.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 21/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import Foundation

class SharedManager {
    
    static let sharedManager = SharedManager()
    
    var historyDictionary: [String:WebResponse] = [:]
    var defaultSearchEngine: String?
    
    private init() {
        
    }
}
