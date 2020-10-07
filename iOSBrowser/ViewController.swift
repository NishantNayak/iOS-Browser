//
//  ViewController.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 09/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var multipleTabsTabBar: UITabBar!
    @IBOutlet weak var singlePageTabBar: UITabBar!
    
    var collectionViewAllTabsLayout: CollectionViewFlowLayout?
    var collectionViewSelectTabLayout: TabSelectFlowLayout?
    
    private var lastContentOffset: CGFloat = 0
    
    var numberofItems = 1
    var seletedIndex = 0
    
    override var prefersStatusBarHidden: Bool {
      return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionViewAllTabsLayout = CollectionViewFlowLayout()
        collectionViewSelectTabLayout = TabSelectFlowLayout()
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        self.collectionView.addGestureRecognizer(panGesture)
        self.collectionView.collectionViewLayout = collectionViewAllTabsLayout!
        
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        collectionView.collectionViewLayout = collectionViewSelectTabLayout!
        self.collectionView.isScrollEnabled = false
    }
    
    @objc func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self.collectionView)
        let indexpath = self.collectionView.indexPathForItem(at: point)
        if (recognizer.state == .began) {
            collectionViewAllTabsLayout?.pannedIndexpath = indexpath
            collectionViewAllTabsLayout?.pannedStartPoint = point
            
        } else if (recognizer.state == .changed) {
            collectionViewAllTabsLayout?.pannedUpdatePoint = point
        } else if (recognizer.state == .ended) {
            let cell = self.collectionView.cellForItem(at: indexpath!) as? BrowserCollectionViewCell
            if let colCell = cell {
                if (colCell.frame.origin.x < -150){
                    self.collectionView.performBatchUpdates({
                        self.numberofItems -= 1
                        self.collectionViewAllTabsLayout?.pannedIndexpath = nil
                        self.collectionView.deleteItems(at: [indexpath!])
                        deleteItem(index: indexpath!.row)
                    }) { (status) in
                    }
                } else {
                    self.collectionViewAllTabsLayout?.pannedIndexpath = nil
                }
            }
        } else {
            collectionViewAllTabsLayout?.pannedIndexpath = nil
        }
        collectionViewAllTabsLayout?.invalidateLayout()
    }
    
    func loadData() {
        let docsBaseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customPlistURL = docsBaseURL.appendingPathComponent("testfile")
        print(customPlistURL.absoluteString)
        var plistData = [String:WebResponse]()
        do {
            let data = try Data(contentsOf: customPlistURL)
            plistData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [String : WebResponse]
        } catch {
            print("Couldn't read file")
        }

        let sortedData = plistData.sorted{ $0.key < $1.key }
        var convertedData = [String:WebResponse]()
        for item in sortedData {
            //let model = convertFileToModel(dict: item.value as! [String : String])
            convertedData[item.key] = item.value
        }
        SharedManager.sharedManager.historyDictionary = convertedData
        numberofItems = SharedManager.sharedManager.historyDictionary.count
        self.collectionView.reloadData()
    }
    
    func deleteItem(index: Int) {
        SharedManager.sharedManager.historyDictionary.removeValue(forKey: "Item\(index)")
        for i in index ..< SharedManager.sharedManager.historyDictionary.count {
            switchKey(&SharedManager.sharedManager.historyDictionary, fromKey: "Item\(i)", toKey: "Item\(i-1)")
        }
    }
    
    func switchKey<T, U>(_ myDict: inout [T:U], fromKey: T, toKey: T) {
        if let entry = myDict.removeValue(forKey: fromKey) {
            myDict[toKey] = entry
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch numberofItems {
        case 0:
            numberofItems = 1
            return 1
        default:
            return numberofItems
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentSearchCell", for: indexPath) as! BrowserCollectionViewCell
        cell.searchBar.tag = indexPath.row
        cell.webView.scrollView.delegate = self
        cell.cellDelegate = self
        cell.searchBar.text = ""
//        cell.webView.scrollView.backgroundColor = UIColor.clear
        cell.webView.loadHTMLString("", baseURL: nil)
        if (indexPath.row < SharedManager.sharedManager.historyDictionary.count) {
            let webObject = SharedManager.sharedManager.historyDictionary["Item\(indexPath.row)"]
            cell.searchBar.text = webObject?.url
            cell.webView.loadString(cell.searchBar.text ?? "")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.multipleTabsTabBar.isHidden = true
        self.singlePageTabBar.isHidden = false
        self.singlePageTabBar.slideTabBarUp()
        collectionView.setCollectionViewLayout(collectionViewSelectTabLayout!, animated: true)
        collectionView.isScrollEnabled = false
        self.seletedIndex = indexPath.row
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !collectionView.isScrollEnabled {
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                self.singlePageTabBar.slideTabBarUp()
                self.slideSearchBarDown()
            }
            else if (self.lastContentOffset <= scrollView.contentOffset.y && scrollView.contentOffset.y > 0) {
                self.singlePageTabBar.slideTabBarDown()
                self.slideSearchBarUp()
            }
            
            if (scrollView.contentOffset.y <= 0){
                self.singlePageTabBar.slideTabBarUp()
                self.slideSearchBarDown()
            }

            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func changeToSingleScreenLayout() {
        self.multipleTabsTabBar.isHidden = true
        self.singlePageTabBar.isHidden = false
        self.singlePageTabBar.slideTabBarUp()
        self.collectionView.setCollectionViewLayout(collectionViewSelectTabLayout!, animated: true)
    }
}

extension ViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch tabBar.tag {
        case 1:
            switch item.tag {
            case 0:
                self.performSegue(withIdentifier: "presentSearchEngineSelection", sender: nil)
            case 1:
                collectionView.isScrollEnabled = true
                collectionView.setCollectionViewLayout(collectionViewAllTabsLayout!, animated: true)
                self.multipleTabsTabBar.isHidden = false
                self.singlePageTabBar.isHidden = true
            default:
                print("")
            }
        case 2:
            switch item.tag {
            case 0:
                self.collectionView.performBatchUpdates({
                    self.numberofItems += 1
                    self.collectionView.insertItems(at: [IndexPath(row: self.numberofItems-1, section: 0)])
                }) { (status) in
                    DispatchQueue.main.async {
                        let lastItemIndex = IndexPath(row: self.numberofItems-1, section: 0)
                        self.collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.changeToSingleScreenLayout()
                            self.collectionView.scrollToItem(at: lastItemIndex, at: .bottom, animated: false)
                            self.collectionView.isScrollEnabled = false
                            self.seletedIndex = lastItemIndex.row
                        }
                    }
                }
            case 1:
                collectionView.setCollectionViewLayout(collectionViewSelectTabLayout!, animated: true)
                collectionView.isScrollEnabled = false
                self.multipleTabsTabBar.isHidden = true
                self.singlePageTabBar.isHidden = false
            default:
                print("")
            }
        default:
            print("testing")
        }
        
    }
}

extension ViewController {
    func slideSearchBarUp() {
        let cell = self.collectionView.cellForItem(at: IndexPath(row: self.seletedIndex, section: 0)) as! BrowserCollectionViewCell
        cell.navBarHeightConstraint.constant = 60
        UIView.animate(withDuration: 0.3, animations: {
            cell.searchBar.isHidden = true
            cell.navBarLabel.isHidden = false
            cell.layoutIfNeeded()
        })
    }
    
    func slideSearchBarDown() {
        let cell = self.collectionView.cellForItem(at: IndexPath(row: self.seletedIndex, section: 0)) as! BrowserCollectionViewCell
        cell.navBarHeightConstraint.constant = 100
        UIView.animate(withDuration: 0.3, animations: {
            cell.searchBar.isHidden = false
            cell.navBarLabel.isHidden = true
            cell.layoutIfNeeded()
        })
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let panGesture = gestureRecognizer as? UIPanGestureRecognizer
        let velocity = panGesture?.velocity(in: self.collectionView)
        if (abs(velocity?.x ?? 0) > abs(velocity?.y ?? 0) ){
            return true
        } else {
            return false
        }
    }
}

extension ViewController: CollectionCellDelegate {
    func deleteCellClicked(cell: UICollectionViewCell) {
        let indexpath = self.collectionView.indexPath(for: cell)
        self.collectionView.performBatchUpdates({
            self.numberofItems -= 1
            self.collectionView.deleteItems(at: [indexpath!])
            deleteItem(index: indexpath!.row)
        }) { (status) in
        }
    }
    
    
}

extension UITabBar {
    
    func slideTabBarDown() {
        var frame = self.frame
        frame.origin.y = UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = frame
        })
    }
    
    func slideTabBarUp() {
        var frame = self.frame
        frame.origin.y = UIScreen.main.bounds.height - 90
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = frame
        })
    }
}
