//
//  SearchEngineViewController.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 20/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit

class SearchEngineViewController: UIViewController {

    var searchData = [SearchEngine(searchImage: "google.png", searchLabel: "Google", searchURL: "https://www.google.com/search?q=", selected: false), SearchEngine(searchImage: "bing.png", searchLabel: "Bing", searchURL: "https://www.bing.com/search?q=", selected: false), SearchEngine(searchImage: "duckduckgo.png", searchLabel: "DuckDuckGo", searchURL: "https://www.duckduckgo.com/search?q=", selected: false), SearchEngine(searchImage: "yahoo.png", searchLabel: "Yahoo", searchURL: "https://www.yahoo.com/search?q=", selected: false)]
    
    var searchEngineURL: String?
    var selectedIndex: Int?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barDoneButton: UIButton!
    @IBOutlet weak var doneButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isModal {
            self.barDoneButton.isHidden = false
            self.doneButtonHeightConstraint.constant = 0
        }
        else {
            self.barDoneButton.isHidden = true
            self.doneButtonHeightConstraint.constant = 71
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        self.doneButton.isEnabled = false
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        UserDefaults.standard.set(searchEngineURL, forKey: "SearchURL")
        SharedManager.sharedManager.defaultSearchEngine = (UserDefaults.standard.value(forKey: "SearchURL") as! String)
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: "BrowserViewController") as! ViewController
            self.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
}

extension SearchEngineViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"searchEngineTableViewCell") as! SeachEngineTableViewCell
        
        let indexData = searchData[indexPath.row]
        cell.searchEngine.text = indexData.searchLabel ?? ""
        cell.searchImageView.image = UIImage.init(named: indexData.searchImage ?? "")
        if let value = UserDefaults.standard.value(forKey: "SearchURL") as? String, value == indexData.searchURL ?? "" {
            cell.checkboxImage.isHidden = false
            selectedIndex = indexPath.row
            searchEngineURL = searchData[indexPath.row].searchURL
        }
        else {
            cell.checkboxImage.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexData = searchData[indexPath.row]
        searchEngineURL = indexData.searchURL
        if let index = selectedIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! SeachEngineTableViewCell
            cell.checkboxImage.isHidden = true
        }
        selectedIndex = indexPath.row
        let cell = tableView.cellForRow(at: indexPath) as! SeachEngineTableViewCell
        cell.checkboxImage.isHidden = false
        self.doneButton.isEnabled = true
    }
    
}

extension UIViewController {

    var isModal: Bool {

        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController

        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}
