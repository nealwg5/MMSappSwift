    //
//  ViewController.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/5/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import UIKit
import Foundation

//The view controller for the article list page
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    //The data table which holds the article list
    @IBOutlet var dataTable : UITableView?
    
   
   
    //The page view
    @IBOutlet var theView: UIView!
    
    //The labels above and below the list
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    
    //The article type selector
    @IBOutlet weak var articleTypeSelector: UISegmentedControl!
    
    //The pull-to-refresh controller and the objects which comprise the refresh spinner display
    var refreshController: UIRefreshControl = UIRefreshControl()
    var spinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var spinContainer: UIView = UIView()
    var darkContainer: UIView = UIView()
    var spinLabel: UILabel = UILabel()
    
    //The URL selected by the user to view
    var articleURL = String()
    
    //The class which holds cached data
    var theCache = Cache()
    
    //The lists of article objects which stores all information about the articles
    var NEJMArticleList = [Article]()
    var JWatchArticleList = [Article]()
    var FWatchArticleList = [Article]()
    
    //The parsers for NEJM, Journal Watch, and First Watch
    let NEJMParser = NEJMArticles()
    let JWatchParser = JournalWatchArticles()
    let FWatchParser = FirstWatchArticles()
    
    let NEJMSearcher = NEJMsearch()
    let FWSearcher = FirstWatchSearch()
    let JWSearcher = JournalWatchSearch()
    
    //Notification controller
    var notification = UILocalNotification()
    
    @IBOutlet var mySearchBar: UISearchBar!
   
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        refreshAll()
        //Updates the article lists (if necessary) on load
        updateNEJMArticlesOnLoad()
        updateJWatchArticlesOnLoad()
        updateFWatchArticlesOnLoad()
        
        //Displays the current date on the top label
        topLabel.text = getDateHuman()
        
        //Sets the table background color
        dataTable?.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1)
        
        //Sets up and adds the pull-to-refresh controller and the refresh spinner display
        setupSpinner()
        setupRefreshController()

    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //Sets up an article object which will display an error message
    func defaultErrorArticleObject() -> Article {
        
        let theArticle = Article()
        theArticle.title = "Oops! Something went wrong. Try widening the content range in Settings and refreshing"
        theArticle.id = ""
        theArticle.pubDate = "0000-00-00"
        theArticle.extract = NSAttributedString(string: "")
        
        return theArticle
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) // called when keyboard search button pressed
    {
        mySearchBar.resignFirstResponder()
        
        let searchPredicate = mySearchBar.text!
         let escapedAddress = searchPredicate.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        print(searchPredicate)
        let preferences = NSUserDefaults.standardUserDefaults()
        preferences.setValue(escapedAddress, forKey: "searchQuery")
        
        self.darkContainer.hidden = false
        self.spinner.startAnimating()
        
        asynchronouslyUpdateFWatchSearch()
        asynchronouslyUpdateJWatchSearch()
        asynchronouslyUpdateNEJMSearch()
       
    }
    
    //Asynchronously updates the NEJM search
    func asynchronouslyUpdateNEJMSearch() {
        
        //A dispatch group, which will help with determining if asynchronous functions have finished
        let refreshArticlesAsync: dispatch_group_t = dispatch_group_create()
        
        //Asynchronously gets and caches articles
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            dispatch_group_enter(refreshArticlesAsync)
            
            //Get a refreshed list of articles
            self.NEJMArticleList = self.NEJMSearcher.getArticles(self.theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of NEJM articles is empty set the list of articles to the last cached list of articles
            if (self.NEJMArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (self.theCache.getCachedNEJMsearch() == []) {
                    
                    self.NEJMArticleList = [self.defaultErrorArticleObject()]
                    
                } else {        //If there are cached NEJM articles, set the list of NEJM articles to that list
                    
                    self.NEJMArticleList = self.theCache.getCachedNEJMsearch()
                    
                }
                
            }
            
            dispatch_group_leave(refreshArticlesAsync)
            
            //Runs when the dispatch group functions have finished
            dispatch_group_notify(refreshArticlesAsync, dispatch_get_main_queue(), {
                
                //Caches the new article data and update date and time
                self.theCache.cacheNEJMArticles(self.NEJMArticleList)
                self.theCache.cacheNEJMUpdateInfo(getDateHuman(), theTime: getTimeHuman())
                
                //Updates the bottom label
                self.bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
                
                //Reloads the table with the new data
                self.dataTable?.reloadData()
                
                //Hides the refresh spinner and stops its animation
                self.darkContainer.hidden = true
                self.spinner.stopAnimating()
                
            })
            
        })
        
    }
    
    //Asynchronously updates the Journal Watch search
    func asynchronouslyUpdateJWatchSearch() {
        
        //A dispatch group, which will help with determining if asynchronous functions have finished
        let refreshArticlesAsync: dispatch_group_t = dispatch_group_create()
        
        //Asynchronously gets and caches articles
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            dispatch_group_enter(refreshArticlesAsync)
            
            //Get a refreshed list of JWatch articles
            self.JWatchArticleList = self.JWSearcher.getArticles(self.theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of JWatch articles is empty set the list of articles to the last cached list of articles
            if (self.JWatchArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (self.theCache.getCachedJournalWatchSearch() == []) {
                    
                    self.JWatchArticleList = [self.defaultErrorArticleObject()]
                    
                } else {        //If there are cached JWatch articles, set the list of JWatch articles to that list
                    
                    self.JWatchArticleList = self.theCache.getCachedJournalWatchSearch()
                    
                }
                
                self.JWatchArticleList = self.theCache.getCachedJournalWatchSearch()

                
            }
            
            dispatch_group_leave(refreshArticlesAsync)
            
            //Runs when the dispatch group functions have finished
            dispatch_group_notify(refreshArticlesAsync, dispatch_get_main_queue(), {
                
                //Caches the new article data and update date and time
                self.theCache.cacheJournalWatchArticles(self.JWatchArticleList)
                self.theCache.cacheJournalWatchUpdateInfo(getDateHuman(), theTime: getTimeHuman())
                
                //Updates the bottom label
                self.bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
                
                //Reloads the table with the new data
                self.dataTable?.reloadData()
                
                //Hides the refresh spinner and stops its animation
                self.darkContainer.hidden = true
                self.spinner.stopAnimating()
                
            })
            
        })
        
    }
    
    //Asynchronously updates the First Watch search
    func asynchronouslyUpdateFWatchSearch() {
        
        //A dispatch group, which will help with determining if asynchronous functions have finished
        let refreshArticlesAsync: dispatch_group_t = dispatch_group_create()
        
        //Asynchronously gets and caches articles
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            dispatch_group_enter(refreshArticlesAsync)
            
            //Get a refreshed list of FWatch articles
            self.FWatchArticleList = self.FWSearcher.getArticles(self.theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of FWatch articles is empty set the list of articles to the last cached list of articles
            if (self.FWatchArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (self.theCache.getCachedFirstWatchSearch() == []) {
                    
                    self.FWatchArticleList = [self.defaultErrorArticleObject()]
                    
                } else {        //If there are cached FWatch articles, set the list of FWatch articles to that list
                    
                    self.FWatchArticleList = self.theCache.getCachedFirstWatchSearch()
                    
                }
                
            }
            
            dispatch_group_leave(refreshArticlesAsync)
            
            //Runs when the dispatch group functions have finished
            dispatch_group_notify(refreshArticlesAsync, dispatch_get_main_queue(), {
                
                //Caches the new article data and update date and time
                self.theCache.cacheFirstWatchArticles(self.FWatchArticleList)
                self.theCache.cacheFirstWatchUpdateInfo(getDateHuman(), theTime: getTimeHuman())
                
                //Updates the bottom label
                self.bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
                
                //Reloads the table with the new data
                self.dataTable?.reloadData()
                
                //Hides the refresh spinner and stops its animation
                self.darkContainer.hidden = true
                self.spinner.stopAnimating()
                
            })
            
        })
        
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) // called when cancel button pressed
    {
        mySearchBar.resignFirstResponder()
        mySearchBar.text = ""
    }
    
    @IBAction func refreshButtonClicked(sender: AnyObject)
    {
        mySearchBar.resignFirstResponder()
               mySearchBar.text = ""
               refreshAll()

    }

    
    //Sets up and adds the pull-to-refresh controller to the view
    func setupRefreshController() {
        
        self.refreshController.backgroundColor = UIColor(red: 236.0/255.0, green: 238.0/255.0, blue: 240.0/255.0, alpha: 1)
        self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh articles")
        self.refreshController.addTarget(self, action: #selector(ViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        self.dataTable!.addSubview(refreshController)
        
    }
    
    //Sets up and adds the refresh spinner display to the view
    func setupSpinner() {
        
        //Sets up the refresh spinner display
        darkContainer = makeDarkContainer(theView, theContainer: darkContainer)
        spinContainer = makeSpinContainer(theView, theContainer: spinContainer)
        spinner = makeSpinner(spinner, theContainer: spinContainer)
        spinLabel = makeSpinLabel(spinLabel, theContainer: spinContainer)
        
        //Adds the refresh spinner display (currently hidden) to the view
        spinContainer.addSubview(spinner)
        spinContainer.addSubview(spinLabel)
        darkContainer.addSubview(spinContainer)
        theView.addSubview(darkContainer)
        
    }
    
    //Gets NEJM article data and sets the text of bottom label
    func updateNEJMArticlesOnLoad() {

        //If there is no cached article data or there is no cached article data today, get current article data, date, and time, and cache them
        if ((theCache.getCachedNEJMArticles() == []) || ((getDateHuman() != theCache.getCachedNEJMUpdateInfo().updateDate) && (theCache.getCachedNEJMUpdateInfo().isData == true))) {
            
            //Get a refreshed list of articles
            NEJMArticleList = NEJMParser.getArticles(theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of articles is empty set the list of articles to the last cached list of articles
            if (NEJMArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (theCache.getCachedNEJMArticles() == []) {
                    
                    NEJMArticleList = [defaultErrorArticleObject()]
                    
                } else {        //If there are cached NEJM articles, set the list of NEJM articles to that list
                    
                    NEJMArticleList = theCache.getCachedNEJMArticles()
                    
                }
                
            }
            
            //Set the bottom label to reflect the date and time the articles were refreshed
            bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
            
            //Cache the updated article list and the update date and time
            theCache.cacheNEJMArticles(NEJMArticleList)
            theCache.cacheNEJMUpdateInfo(getDateHuman(), theTime: getTimeHuman())
            
        } else {    //Otherwise, set the article data and update date and time to the cached data
            
            NEJMArticleList = theCache.getCachedNEJMArticles()
            bottomLabel.text = "Updated on \(theCache.getCachedNEJMUpdateInfo().updateDate), \(theCache.getCachedNEJMUpdateInfo().updateTime)"
            
        }
        
    }
    
    //Gets NEJM article data and sets the text of bottom label
    func updateJWatchArticlesOnLoad() {
        
        //If there is no cached article data or there is no cached article data today, get current article data, date, and time, and cache them
        if ((theCache.getCachedJournalWatchArticles() == []) || ((getDateHuman() != theCache.getCachedJournalWatchUpdateInfo().updateDate) && (theCache.getCachedJournalWatchUpdateInfo().isData == true))) {

            //Get a refreshed list of articles
            JWatchArticleList = JWatchParser.getArticles(theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of articles is empty set the list of articles to the last cached list of articles
            if (JWatchArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (theCache.getCachedJournalWatchArticles() == []) {
                    
                    JWatchArticleList = [defaultErrorArticleObject()]
                    
                } else {        //If there are cached JWatch articles, set the list of JWatch articles to that list
                    
                    JWatchArticleList = theCache.getCachedNEJMArticles()
                    
                }
                
            }
            
            //Set the bottom label to reflect the date and time the articles were refreshed
            bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
            
            //Cache the updated article list and the update date and time
            theCache.cacheJournalWatchArticles(JWatchArticleList)
            theCache.cacheJournalWatchUpdateInfo(getDateHuman(), theTime: getTimeHuman())
            
        } else {    //Otherwise, set the article data and update date and time to the cached data

            JWatchArticleList = theCache.getCachedJournalWatchArticles()
            bottomLabel.text = "Updated on \(theCache.getCachedJournalWatchUpdateInfo().updateDate), \(theCache.getCachedJournalWatchUpdateInfo().updateTime)"
            
        }
        
    }
    //Gets NEJM article data and sets the text of bottom label
    func updateFWatchArticlesOnLoad() {
        
        //If there is no cached article data or there is no cached article data today, get current article data, date, and time, and cache them
        if ((theCache.getCachedFirstWatchArticles() == []) || ((getDateHuman() != theCache.getCachedFirstWatchUpdateInfo().updateDate) && (theCache.getCachedFirstWatchUpdateInfo().isData == true))) {
            
            //Get a refreshed list of articles
            FWatchArticleList = FWatchParser.getArticles(theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of articles is empty set the list of articles to the last cached list of articles
            if (FWatchArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (theCache.getCachedFirstWatchArticles() == []) {
                    
                    FWatchArticleList = [defaultErrorArticleObject()]
                    
                } else {        //If there are cached FWatch articles, set the list of FWatch articles to that list
                    
                    FWatchArticleList = theCache.getCachedFirstWatchArticles()
                    
                }
                
            }
            
            //Set the bottom label to reflect the date and time the articles were refreshed
            bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
            
            //Cache the updated article list and the update date and time
            theCache.cacheFirstWatchArticles(FWatchArticleList)
            theCache.cacheFirstWatchUpdateInfo(getDateHuman(), theTime: getTimeHuman())
            
        } else {    //Otherwise, set the article data and update date and time to the cached data
            
            FWatchArticleList = theCache.getCachedFirstWatchArticles()
            bottomLabel.text = "Updated on \(theCache.getCachedFirstWatchUpdateInfo().updateDate), \(theCache.getCachedFirstWatchUpdateInfo().updateTime)"
            
        }
        
    }
    
    //Refreshes the articles of the current article type
    func refresh() {
        
        //Stops the pull-to-refresh controller
        self.refreshController.endRefreshing()
        
        //Show the refresh spinner and start its animation
        self.darkContainer.hidden = false
        self.spinner.startAnimating()

        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            asynchronouslyUpdateNEJMArticles()
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            asynchronouslyUpdateJWatchArticles()
            
        } else {
            
            asynchronouslyUpdateFWatchArticles()
            
        }

    }
    
    //Refreshes all the articles
    func refreshAll() {
        NSLog("refreshing all")
        //Stops the pull-to-refresh controller
        self.refreshController.endRefreshing()
        
        //Show the refresh spinner and start its animation
        self.darkContainer.hidden = false
        self.spinner.startAnimating()
        
        //Updates the articles
        asynchronouslyUpdateNEJMArticles()
        asynchronouslyUpdateJWatchArticles()
        asynchronouslyUpdateFWatchArticles()
        
    }
    
    //Asynchronously updates the NEJM articles
    func asynchronouslyUpdateNEJMArticles() {
        
        //A dispatch group, which will help with determining if asynchronous functions have finished
        let refreshArticlesAsync: dispatch_group_t = dispatch_group_create()
        
        //Asynchronously gets and caches articles
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            dispatch_group_enter(refreshArticlesAsync)
            
            //Get a refreshed list of articles
            self.NEJMArticleList = self.NEJMParser.getArticles(self.theCache.getCachedDateRangeSetting().dateRange)
            
            //If the refreshed list of NEJM articles is empty set the list of articles to the last cached list of articles
            if (self.NEJMArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (self.theCache.getCachedNEJMArticles() == []) {
                    
                    self.NEJMArticleList = [self.defaultErrorArticleObject()]
                    
                } else {        //If there are cached NEJM articles, set the list of NEJM articles to that list
                    
                    self.NEJMArticleList = self.theCache.getCachedNEJMArticles()
                    
                }
                
            }
            
            dispatch_group_leave(refreshArticlesAsync)
            
            //Runs when the dispatch group functions have finished
            dispatch_group_notify(refreshArticlesAsync, dispatch_get_main_queue(), {
                
                //Caches the new article data and update date and time
                self.theCache.cacheNEJMArticles(self.NEJMArticleList)
                self.theCache.cacheNEJMUpdateInfo(getDateHuman(), theTime: getTimeHuman())
                
                //Updates the bottom label
                self.bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
                
                //Reloads the table with the new data
                self.dataTable?.reloadData()
                
                //Hides the refresh spinner and stops its animation
                self.darkContainer.hidden = true
                self.spinner.stopAnimating()
                
            })
            
        })
        
    }
    
    //Asynchronously updates the Journal Watch articles
    func asynchronouslyUpdateJWatchArticles() {
        
        //A dispatch group, which will help with determining if asynchronous functions have finished
        let refreshArticlesAsync: dispatch_group_t = dispatch_group_create()

        //Asynchronously gets and caches articles
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            dispatch_group_enter(refreshArticlesAsync)
            
            //Get a refreshed list of JWatch articles
            self.JWatchArticleList = self.JWatchParser.getArticles(self.theCache.getCachedDateRangeSetting().dateRange)

            //If the refreshed list of JWatch articles is empty set the list of articles to the last cached list of articles
            if (self.JWatchArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (self.theCache.getCachedJournalWatchArticles() == []) {
                    
                    self.JWatchArticleList = [self.defaultErrorArticleObject()]
                    
                } else {        //If there are cached JWatch articles, set the list of JWatch articles to that list
                    
                    self.JWatchArticleList = self.theCache.getCachedJournalWatchArticles()
                    
                }
                
            }
            
            dispatch_group_leave(refreshArticlesAsync)
            
            //Runs when the dispatch group functions have finished
            dispatch_group_notify(refreshArticlesAsync, dispatch_get_main_queue(), {
                
                //Caches the new article data and update date and time
                self.theCache.cacheJournalWatchArticles(self.JWatchArticleList)
                self.theCache.cacheJournalWatchUpdateInfo(getDateHuman(), theTime: getTimeHuman())
                
                //Updates the bottom label
                self.bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
                
                //Reloads the table with the new data
                self.dataTable?.reloadData()
                
                //Hides the refresh spinner and stops its animation
                self.darkContainer.hidden = true
                self.spinner.stopAnimating()
                
            })
            
        })
        
    }
    
    //Asynchronously updates the First Watch articles
    func asynchronouslyUpdateFWatchArticles() {
        
        //A dispatch group, which will help with determining if asynchronous functions have finished
        let refreshArticlesAsync: dispatch_group_t = dispatch_group_create()
        
        //Asynchronously gets and caches articles
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            dispatch_group_enter(refreshArticlesAsync)

            //Get a refreshed list of FWatch articles
            self.FWatchArticleList = self.FWatchParser.getArticles(self.theCache.getCachedDateRangeSetting().dateRange)

            //If the refreshed list of FWatch articles is empty set the list of articles to the last cached list of articles
            if (self.FWatchArticleList == []) {
                
                //Checks if the cached data is empty. If so, set the list to a default cell
                if (self.theCache.getCachedFirstWatchArticles() == []) {
                    
                    self.FWatchArticleList = [self.defaultErrorArticleObject()]
                    
                } else {        //If there are cached FWatch articles, set the list of FWatch articles to that list
                    
                    self.FWatchArticleList = self.theCache.getCachedFirstWatchArticles()
                    
                }
                
            }
            
            dispatch_group_leave(refreshArticlesAsync)
            
            //Runs when the dispatch group functions have finished
            dispatch_group_notify(refreshArticlesAsync, dispatch_get_main_queue(), {
                
                //Caches the new article data and update date and time
                self.theCache.cacheFirstWatchArticles(self.FWatchArticleList)
                self.theCache.cacheFirstWatchUpdateInfo(getDateHuman(), theTime: getTimeHuman())
                
                //Updates the bottom label
                self.bottomLabel.text = "Updated on \(getDateHuman()), \(getTimeHuman())"
                
                //Reloads the table with the new data
                self.dataTable?.reloadData()
                
                //Hides the refresh spinner and stops its animation
                self.darkContainer.hidden = true
                self.spinner.stopAnimating()
                
            })
            
        })
        
    }
    
    //Handles the functions to check for new articles and send a notification (if necessary) during a background fetch
    func newArticlesFetchHandler() -> String {
        
        //Default value of completion handler should be "none" (no new data)
        var theCompletionHandler = "None"
        
        NSLog("checking...")
        //Check each article type for new articles
        let newNEJM = checkForNewArticlesNEJM()
        let newJWatch = checkForNewArticlesJWatch()
        let newFWatch = checkForNewArticlesFWatch()
        
        NSLog("checked")
        
        //If new articles, update theCompletionHandler and send a notification
        if ((newNEJM != false) || (newJWatch != false) || (newFWatch != false)) {
            
            theCompletionHandler = "New"
            
            refreshAll()
            
            sendNewArticlesNotification(newNEJM, newJWatch: newJWatch, newFWatch: newFWatch)
            
        }
        NSLog("done")
        return theCompletionHandler
        
    }
    
    //Checks if there are new NEJM articles. Returns true or false
    func checkForNewArticlesNEJM() -> Bool {
        
        //The count of cached articles today
        //The cached articles
        let cachedArticles = theCache.getCachedNEJMArticles()
        
        var oldCount: Int = 0
        
        //Loops through each cached article
        for individualArticle in cachedArticles {
            
            //Checks if the article's pubdate is today
            if (individualArticle.pubDate == getDateYYYYMMDD()) {
                
                //If the article is from today, increments the count
                oldCount = oldCount + 1
                
            }
            
        }
        
        //The count of the updated articles today
        //The updated articles
        let updatedArticles = NEJMParser.getArticles(theCache.getCachedDateRangeSetting().dateRange)
        
        var newCount: Int = 0
        
        //Loops through each updated article
        for individualArticle in updatedArticles {
            
            //Checks if the article's pubdate is today
            if (individualArticle.pubDate == getDateYYYYMMDD()) {
                
                //If the article is from today, increments the count
                newCount = newCount + 1
                
            }
            
        }
        
        //Compares the two counts to determine if there are new NEJM articles
        if (newCount > oldCount) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    //Checks if there are new Journal Watch articles. Returns true or false
    func checkForNewArticlesJWatch() -> Bool {
        
        //The count of cached articles today
        //The cached articles
        let cachedArticles = theCache.getCachedJournalWatchArticles()
        
        var oldCount: Int = 0
        
        //Loops through each cached article
        for individualArticle in cachedArticles {
            
            //Checks if the article's pubdate is today
            if (individualArticle.pubDate == getDateYYYYMMDD()) {
                
                //If the article is from today, increments the count
                oldCount = oldCount + 1
                
            }
            
        }
        
        //The count of the updated articles today
        //The updated articles
        let updatedArticles = JWatchParser.getArticles(theCache.getCachedDateRangeSetting().dateRange)
        
        var newCount: Int = 0
        
        //Loops through each updated article
        for individualArticle in updatedArticles {
            
            //Checks if the article's pubdate is today
            if (individualArticle.pubDate == getDateYYYYMMDD()) {
                
                //If the article is from today, increments the count
                newCount = newCount + 1
                
            }
            
        }
        
        //Compares the two counts to determine if there are new Journal Watch articles
        if (newCount > oldCount) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    //Checks if there are new First Watch articles. Returns true or false
    func checkForNewArticlesFWatch() -> Bool {
        
        //The count of cached articles today
        //The cached articles
        let cachedArticles = theCache.getCachedFirstWatchArticles()

        var oldCount: Int = 0
        
        //Loops through each cached article
        for individualArticle in cachedArticles {
            
            //Checks if the article's pubdate is today
            if (individualArticle.pubDate == getDateYYYYMMDD()) {
                
                //If the article is from today, increments the count
                oldCount = oldCount + 1
                
            }
            
        }
        
        //The count of the updated articles today
        //The updated articles
        let updatedArticles = FWatchParser.getArticles(theCache.getCachedDateRangeSetting().dateRange)
        
        var newCount: Int = 0
        
        //Loops through each updated article
        for individualArticle in updatedArticles {
            
            //Checks if the article's pubdate is today
            if (individualArticle.pubDate == getDateYYYYMMDD()) {
                
                //If the article is from today, increments the count
                newCount = newCount + 1
                
            }
            
        }
        
        //Compares the two counts to determine if there are new First Watch articles
        if (newCount > oldCount) {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    //Sends a notification alerting the user that there are new articles
    func sendNewArticlesNotification(newNejm: Bool, newJWatch: Bool, newFWatch: Bool) {
        
        //The message to send in the notification
        var notificationMessage = ""
        
        //A count of the number of article types with new articles
        var newArticleTypeCount: Int = 0
        
        //Increments the count
        if (newNejm == true) {
            
            newArticleTypeCount = newArticleTypeCount + 1
            
        }
        
        if (newJWatch == true) {
            
            newArticleTypeCount = newArticleTypeCount + 1
            
        }
        
        if (newFWatch == true) {
            
            newArticleTypeCount = newArticleTypeCount + 1
            
        }
        
        //Formats the message
        if (newArticleTypeCount == 3) {
            
            notificationMessage = "You have new articles from NEJM, Journal Watch, and First Watch!"
            
        } else if (newArticleTypeCount == 2) {
            
            if (newNejm == false) {
                
                notificationMessage = "You have new articles from Journal Watch and First Watch!"
                
            } else if (newJWatch == false) {
                
                notificationMessage = "You have new articles from NEJM and First Watch!"
                
            } else {
                
                notificationMessage = "You have new articles from NEJM and Journal Watch!"
                
            }
            
        } else {
            
            if (newNejm == true) {
                
                notificationMessage = "You have new articles from NEJM!"
                
            } else if (newJWatch == true) {
                
                notificationMessage = "You have new articles from Journal Watch!"
                
            } else {
                
                notificationMessage = "You have new articles from First Watch!"
                
            }
            
        }
        
        //Sends the notification
        notification.alertBody = notificationMessage
        notification.alertAction = "open"
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    //Sets the bottom label's text to the appropriate value for the current article type
    func setBottomLabel() {
        
        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            bottomLabel.text = "Updated on \(theCache.getCachedNEJMUpdateInfo().updateDate), \(theCache.getCachedNEJMUpdateInfo().updateTime)"
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            bottomLabel.text = "Updated on \(theCache.getCachedJournalWatchUpdateInfo().updateDate), \(theCache.getCachedJournalWatchUpdateInfo().updateTime)"
            
        } else {
            
            bottomLabel.text = "Updated on \(theCache.getCachedFirstWatchUpdateInfo().updateDate), \(theCache.getCachedFirstWatchUpdateInfo().updateTime)"
            
        }
        
    }
    
    //Helps with dynamically formatting table cells
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    //Helps with dynamically formatting table cells
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //Returns the amount of table cells based on the article type selected
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            return NEJMArticleList.count
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            return JWatchArticleList.count
            
        } else {
            
            return FWatchArticleList.count
            
        }
        
    }
    
    //Inserts a table cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        return cellAtIndexPath(indexPath)
        
    }
    
    //Creates a table cell
    func cellAtIndexPath(indexPath: NSIndexPath) -> TableCell {
        
        let cell = dataTable?.dequeueReusableCellWithIdentifier("Cell") as! TableCell
        
        //Sets the cell's title and extract labels
        setTitleLabel(cell, indexPath: indexPath)
        setExtractLabel(cell, indexPath: indexPath)
        setpubDateLabel(cell, indexPath: indexPath)
        
        return cell
        
    }
    
    //Sets the title label of the cell based on which article type is selected
    func setTitleLabel(cell: TableCell, indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            cell.titleLabel.text = NEJMArticleList[row].title
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            cell.titleLabel.text = JWatchArticleList[row].title
            
        } else {
            
            cell.titleLabel.text = FWatchArticleList[row].title
            
        }
        
    }
    
    //Sets the title label of the cell based on which article type is selected
    func setExtractLabel(cell: TableCell, indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            cell.extractLabel.attributedText = NEJMArticleList[row].extract
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            cell.extractLabel.attributedText = JWatchArticleList[row].extract
            
        } else {
            
            cell.extractLabel.attributedText = FWatchArticleList[row].extract
            
        }
        
    }
    
    //Performs the segue to the proper full article page when that article is selected in the list
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //Stores the article object of the article to go to
        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            articleURL = "http://www.nejm.org/doi/full/\(NEJMArticleList[indexPath.row].id)"
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            articleURL = "http://www.jwatch.org/\(JWatchArticleList[indexPath.row].id)"
            
        } else {
            
            articleURL = "http://www.jwatch.org/\(FWatchArticleList[indexPath.row].id)"
            
        }
        
        //Performs the segue to the full article page
        performSegueWithIdentifier("toWebView", sender: self)
        
    }
    
    //Passes the proper data to the proper view controller in preparation for a segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "toWebView") {
            
            let newViewController = segue.destinationViewController as! WebViewController
            
            //Passes the article object to the full article page
            newViewController.articleURL = articleURL
            
        }
        
    }
    
    //Displays the data for the selected article type
    @IBAction func articleTypeChanged(sender: UISegmentedControl) {
        
        dataTable?.reloadData()
        setBottomLabel()
        
    }
    
    //Performs the segue to the settings view controller when "Settings" is selected in the top navigation bar
    @IBAction func settingsClick(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("settingsSegue", sender: self)
        
    }
    
    
    
    
    func setpubDateLabel(cell: TableCell, indexPath: NSIndexPath) {
        
        let row = indexPath.row
        
        if (articleTypeSelector.selectedSegmentIndex == 0) {
            
            cell.pubDateLabel.text = NEJMArticleList[row].pubDate
            
        } else if (articleTypeSelector.selectedSegmentIndex == 1) {
            
            cell.pubDateLabel.text = JWatchArticleList[row].pubDate
            
        } else {
            
            cell.pubDateLabel.text = FWatchArticleList[row].pubDate
            
        }
        
    }

    
}