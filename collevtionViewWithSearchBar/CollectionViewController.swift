//
//  CollectionViewController.swift
//  collectionViewWithSearchBar
//
//  Created by Homam on 23/12/15.
//  Copyright © 2015 Homam. All rights reserved.
//

import UIKit

class CollectionViewController: UICollectionViewController, UISearchBarDelegate {
    var dataSource:[String]?
    var dataSourceForSearchResult:[String]?
    var searchBarActive:Bool = false
    var searchBarBoundsY:CGFloat?
    var searchBar:UISearchBar?
    var refreshControl:UIRefreshControl?
    let reuseIdentifier:String = "Cell"
    
    override func viewDidLoad() {
        
        self.dataSource = ["Modesto","Rebecka","Andria","Sergio","Robby","Jacob","Lavera", "Theola", "Adella","Garry", "Lawanda", "Christiana", "Billy", "Claretta", "Gina", "Edna", "Antoinette", "Shantae", "Jeniffer", "Fred", "Phylis", "Raymon", "Brenna", "Gulfs", "Ethan", "Kimbery", "Sunday", "Darrin", "Ruby", "Babette", "Latrisha", "Dewey", "Della", "Dylan", "Francina", "Boyd", "Willette", "Mitsuko", "Evan", "Dagmar", "Cecille", "Doug",
            "Jackeline", "Yolanda", "Patsy", "Haley", "Isaura", "Tommye", "Katherine", "Vivian"]
        
        self.dataSourceForSearchResult = [String]()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareUI()
    }
    
    deinit{
        self.removeObservers()
    }
    // MARK: actions
    func refreashControlAction(){
        self.cancelSearching()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // stop refreshing after 2 seconds
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
        }

    }
    
    
    // MARK: <UICollectionViewDataSource>
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchBarActive {
            return self.dataSourceForSearchResult!.count;
        }
        return self.dataSource!.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:CollectionViewCell = collectionView .dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        
        if (self.searchBarActive) {
            cell.laName!.text = self.dataSourceForSearchResult![indexPath.row];
        }else{
            cell.laName!.text = self.dataSource![indexPath.row];
        }
        
        return cell;
    }
    
    
    // MARK: <UICollectionViewDelegateFlowLayout>
    func collectionView( collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets{
         return UIEdgeInsetsMake(self.searchBar!.frame.size.height, 0, 0, 0);
    }
    func collectionView (collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
            let cellLeg = (collectionView.frame.size.width/2) - 5;
            return CGSizeMake(cellLeg,cellLeg);
    }
    
    
    // MARK: Search 
    func filterContentForSearchText(searchText:String){
        self.dataSourceForSearchResult = self.dataSource?.filter({ (text:String) -> Bool in
            return text.containsString(searchText)
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // user did type something, check our datasource for text that looks the same
        if searchText.characters.count > 0 {
            // search and reload data source
            self.searchBarActive    = true
            self.filterContentForSearchText(searchText)
            self.collectionView?.reloadData()
        }else{
            // if text lenght == 0
            // we will consider the searchbar is not active
            self.searchBarActive = false
            self.collectionView?.reloadData()
        }

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self .cancelSearching()
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBarActive = true
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // we used here to set self.searchBarActive = YES
        // but we'll not do that any more... it made problems
        // it's better to set self.searchBarActive = YES when user typed something
        self.searchBar!.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        // this method is being called when search btn in the keyboard tapped
        // we set searchBarActive = NO
        // but no need to reloadCollectionView
        self.searchBarActive = false
        self.searchBar!.setShowsCancelButton(false, animated: false)
    }
    func cancelSearching(){
        self.searchBarActive = false
        self.searchBar!.resignFirstResponder()
        self.searchBar!.text = ""
    }
    
    // MARK: prepareVC
    func prepareUI(){
        self.addSearchBar()
        self.addRefreshControl()
    }
    
    func addSearchBar(){
        if self.searchBar == nil{
            self.searchBarBoundsY = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.sharedApplication().statusBarFrame.size.height

            self.searchBar = UISearchBar(frame: CGRectMake(0,self.searchBarBoundsY!, UIScreen.mainScreen().bounds.size.width, 44))
            self.searchBar!.searchBarStyle       = UISearchBarStyle.Minimal
            self.searchBar!.tintColor            = UIColor.whiteColor()
            self.searchBar!.barTintColor         = UIColor.whiteColor()
            self.searchBar!.delegate             = self;
            self.searchBar!.placeholder          = "search here";

            self.addObservers()
        }
        
        if !self.searchBar!.isDescendantOfView(self.view){
            self.view .addSubview(self.searchBar!)
        }
    }
    
    func addRefreshControl(){
        if (self.refreshControl == nil) {
            self.refreshControl            = UIRefreshControl()
            self.refreshControl?.tintColor = UIColor.whiteColor()
            self.refreshControl?.addTarget(self, action: "refreashControlAction", forControlEvents: UIControlEvents.ValueChanged)
        }
        if !self.refreshControl!.isDescendantOfView(self.collectionView!) {
            self.collectionView!.addSubview(self.refreshControl!)
        }
    }
    
    func startRefreshControl(){
        if !self.refreshControl!.refreshing {
            self.refreshControl!.beginRefreshing()
        }
    }
    
    func addObservers(){
        let context = UnsafeMutablePointer<UInt8>(bitPattern: 1)
        self.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: [.New,.Old], context: context)
    }
    
    func removeObservers(){
        self.collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValueForKeyPath(keyPath: String?,
        ofObject object: AnyObject?,
         change: [String : AnyObject]?,
         context: UnsafeMutablePointer<Void>){
            if keyPath! == "contentOffset" {
                if let collectionV:UICollectionView = object as? UICollectionView {
                    self.searchBar?.frame = CGRectMake(
                        self.searchBar!.frame.origin.x,
                        self.searchBarBoundsY! + ( (-1 * collectionV.contentOffset.y) - self.searchBarBoundsY!),
                        self.searchBar!.frame.size.width,
                        self.searchBar!.frame.size.height
                    )
                }
            }
    }

}
