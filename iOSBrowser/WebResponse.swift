//
//  WebResponse.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 16/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import Foundation

class WebResponse: NSObject, NSCoding {
    
    var url: String?
    var htmlString: String?
    
    init(url: String?, htmlString: String?) {
        self.url = url
        self.htmlString = htmlString
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.url, forKey: "url")
        coder.encode(self.htmlString, forKey: "htmlString")
    }
    
    required init?(coder: NSCoder) {
        self.url = coder.decodeObject(forKey: "url") as? String
        self.htmlString = coder.decodeObject(forKey: "htmlString") as? String
    }
}
