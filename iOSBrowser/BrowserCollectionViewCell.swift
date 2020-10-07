//
//  BrowserCollectionViewCell.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 09/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit
import WebKit

protocol CollectionCellDelegate: class {
    func deleteCellClicked(cell: UICollectionViewCell)
}

class BrowserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarLabel: UILabel!
    @IBOutlet weak var topViewLabel: UILabel!
    @IBOutlet weak var cellDeleteButton: UIButton!
    
    weak var cellDelegate: CollectionCellDelegate?
    
    override func awakeFromNib() {
        self.webView.navigationDelegate = self
        searchBar.barTintColor = UIColor(red: 73, green: 143, blue: 173)
        searchBar.searchTextField.backgroundColor = UIColor.white
        searchBar.searchTextField.textColor = UIColor.darkGray
        searchBar.searchTextField.tintColor = UIColor.darkGray
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
    }
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        cellDelegate?.deleteCellClicked(cell: self)
    }
    
}

extension BrowserCollectionViewCell: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let allowedCharacters = NSCharacterSet.urlFragmentAllowed
        guard let  encodedSearchString  = searchBar.text?.addingPercentEncoding(withAllowedCharacters: allowedCharacters)  else { return }

        let searchEngineString = SharedManager.sharedManager.defaultSearchEngine ?? "https://www.google.com/search?q="
        let searchText = searchEngineString + encodedSearchString
        self.webView.loadString(searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
         searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         searchBar.resignFirstResponder()
         searchBar.setShowsCancelButton(false, animated: true)
    }
}

extension BrowserCollectionViewCell: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if !(webView.url?.absoluteString ?? "" == "about:blank") {
            self.searchBar.text = webView.url?.absoluteString
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
            
            let webObject = WebResponse.init(url: self.searchBar.text, htmlString: html as? String)
            SharedManager.sharedManager.historyDictionary["Item\(self.searchBar.tag)"] = webObject
        })
        let title = webView.title
        self.navBarLabel.text = title
        self.topViewLabel.text = title
    }
}

extension WKWebView {
    func loadString(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
