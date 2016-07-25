//
//  Data Caching.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/6/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import Foundation

//The cache of data from the phone
public class Cache {
    
    //Stores the data in an app group container
    let cachedData = NSUserDefaults(suiteName: "group.com.NEJMToday.NEJM")!
    
    
    //Cached data for First Watch
    
    //Caches the article data for First Watch
    public func cacheFirstWatchArticles(theArticles: [Article]) {
        
        NSKeyedArchiver.setClassName("Article", forClass: Article.self)
        cachedData.setObject(NSKeyedArchiver.archivedDataWithRootObject(theArticles), forKey: "firstWatchArticles")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Caches the update date and time for First Watch
    public func cacheFirstWatchUpdateInfo(theDate: String, theTime: String) {
        
        cachedData.setObject(theDate, forKey: "firstWatchUpdateDate")
        cachedData.setObject(theTime, forKey: "firstWatchUpdateTime")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Gets the cached article data for First Watch
    public func getCachedFirstWatchArticles() -> [Article] {
        
        var theArticles = [Article]()
        
        //Empty if there is no data
        if (cachedData.objectForKey("firstWatchArticles") == nil) {
            
            theArticles = []
            
        } else { //Decode the data
            
            if let articleData = cachedData.objectForKey("firstWatchArticles") as? NSData {
                
                NSKeyedUnarchiver.setClass(Article.self, forClassName: "Article")
                if let articles = NSKeyedUnarchiver.unarchiveObjectWithData(articleData) as? [Article] {
                    
                    theArticles = articles
                    
                }
                
            }
            
        }
        
        return theArticles
        
    }
    
    //Gets the cached article data for First Watch
    public func getCachedFirstWatchSearch() -> [Article] {
        
        var theArticles = [Article]()
        
        //Empty if there is no data
        if (cachedData.objectForKey("firstWatchSearch") == nil) {
            
            theArticles = []
            
        } else { //Decode the data
            
            if let articleData = cachedData.objectForKey("firstWatchSearch") as? NSData {
                
                NSKeyedUnarchiver.setClass(Article.self, forClassName: "Article")
                if let articles = NSKeyedUnarchiver.unarchiveObjectWithData(articleData) as? [Article] {
                    
                    theArticles = articles
                    
                }
                
            }
            
        }
        
        return theArticles
        
    }
    
    //Gets the cached update date and time for First Watch
    public func getCachedFirstWatchUpdateInfo() -> (updateDate: String, updateTime: String, isData: Bool) {
        
        var theUpdateDate = ""
        var theUpdateTime = ""
        
        //Is changed to false if there is no date or time data
        var isData = true
        
        if (cachedData.objectForKey("firstWatchUpdateDate") == nil) {
            
            isData = false
            
        } else {
            
            if let theDate = cachedData.objectForKey("firstWatchUpdateDate") as? String {
                
                theUpdateDate = theDate
                
            }
            
        }
        
        if (cachedData.objectForKey("firstWatchUpdateTime") == nil) {
            
            isData = false
            
        } else {
            
            if let theTime = cachedData.objectForKey("firstWatchUpdateTime") as? String {
                
                theUpdateTime = theTime
                
            }
            
        }
        
        return (theUpdateDate, theUpdateTime, isData)
        
    }
    
    
    //Cached data for Journal Watch
    
    //Caches the article data for Journal Watch
    public func cacheJournalWatchArticles(theArticles: [Article]) {
        
        NSKeyedArchiver.setClassName("Article", forClass: Article.self)
        cachedData.setObject(NSKeyedArchiver.archivedDataWithRootObject(theArticles), forKey: "journalWatchArticles")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Caches the update date and time for Journal Watch
    public func cacheJournalWatchUpdateInfo(theDate: String, theTime: String) {
        
        cachedData.setObject(theDate, forKey: "journalWatchUpdateDate")
        cachedData.setObject(theTime, forKey: "journalWatchUpdateTime")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Gets the cached article data for Journal Watch
    public func getCachedJournalWatchArticles() -> [Article] {
        
        var theArticles = [Article]()
        
        //Empty if there is no data
        if (cachedData.objectForKey("journalWatchArticles") == nil) {
            
            theArticles = []
            
        } else { //Decode the data
            
            if let articleData = cachedData.objectForKey("journalWatchArticles") as? NSData {
                
                NSKeyedUnarchiver.setClass(Article.self, forClassName: "Article")
                if let articles = NSKeyedUnarchiver.unarchiveObjectWithData(articleData) as? [Article] {
                    
                    theArticles = articles
                    
                }
                
            }
            
        }
        
        return theArticles
        
    }
    
    //Gets the cached article data for Journal Watch
    public func getCachedJournalWatchSearch() -> [Article] {
        
        var theArticles = [Article]()
        
        //Empty if there is no data
        if (cachedData.objectForKey("journalWatchSearch") == nil) {
            
            theArticles = []
            
        } else { //Decode the data
            
            if let articleData = cachedData.objectForKey("journalWatchSearch") as? NSData {
                
                NSKeyedUnarchiver.setClass(Article.self, forClassName: "Article")
                if let articles = NSKeyedUnarchiver.unarchiveObjectWithData(articleData) as? [Article] {
                    
                    theArticles = articles
                    
                }
                
            }
            
        }
        
        return theArticles
        
    }
    
    //Gets the cached update date and time for Journal Watch
    public func getCachedJournalWatchUpdateInfo() -> (updateDate: String, updateTime: String, isData: Bool) {
        
        var theUpdateDate = ""
        var theUpdateTime = ""
        
        //Is changed to false if there is no date or time data
        var isData = true
        
        if (cachedData.objectForKey("journalWatchUpdateDate") == nil) {
            
            isData = false
            
        } else {
            
            if let theDate = cachedData.objectForKey("journalWatchUpdateDate") as? String {
                
                theUpdateDate = theDate
                
            }
            
        }
        
        if (cachedData.objectForKey("journalWatchUpdateTime") == nil) {
            
            isData = false
            
        } else {
            
            if let theTime = cachedData.objectForKey("journalWatchUpdateTime") as? String {
                
                theUpdateTime = theTime
                
            }
            
        }
        
        return (theUpdateDate, theUpdateTime, isData)
        
    }
    
    
    //Cached data for NEJM
    
    //Caches the article data for NEJM
    public func cacheNEJMArticles(theArticles: [Article]) {
        
        NSKeyedArchiver.setClassName("Article", forClass: Article.self)
        cachedData.setObject(NSKeyedArchiver.archivedDataWithRootObject(theArticles), forKey: "NEJMArticles")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Caches the update date and time for NEJM
    public func cacheNEJMUpdateInfo(theDate: String, theTime: String) {
        
        cachedData.setObject(theDate, forKey: "NEJMUpdateDate")
        cachedData.setObject(theTime, forKey: "NEJMUpdateTime")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Gets the cached article data for NEJM
    public func getCachedNEJMArticles() -> [Article] {
        
        var theArticles = [Article]()
        
        //Empty if there is no data
        if (cachedData.objectForKey("NEJMArticles") == nil) {
            
            theArticles = []
            
        } else { //Decode the data
            
            if let articleData = cachedData.objectForKey("NEJMArticles") as? NSData {
                
                NSKeyedUnarchiver.setClass(Article.self, forClassName: "Article")
                if let articles = NSKeyedUnarchiver.unarchiveObjectWithData(articleData) as? [Article] {
                    
                    theArticles = articles
                    
                }
                
            }
            
        }
        
        return theArticles
        
    }
    
    //Gets the cached article data for NEJM
    public func getCachedNEJMsearch() -> [Article] {
        
        var theArticles = [Article]()
        
        //Empty if there is no data
        if (cachedData.objectForKey("NEJMsearch") == nil) {
            
            theArticles = []
            
        } else { //Decode the data
            
            if let articleData = cachedData.objectForKey("NEJMsearch") as? NSData {
                
                NSKeyedUnarchiver.setClass(Article.self, forClassName: "Article")
                if let articles = NSKeyedUnarchiver.unarchiveObjectWithData(articleData) as? [Article] {
                    
                    theArticles = articles
                    
                }
                
            }
            
        }
        
        return theArticles
        
    }
    
    

    
    //Gets the cached update date and time for NEJM
    public func getCachedNEJMUpdateInfo() -> (updateDate: String, updateTime: String, isData: Bool) {
        
        var theUpdateDate = ""
        var theUpdateTime = ""
        
        //Is changed to false if there is no date or time data
        var isData = true
        
        if (cachedData.objectForKey("NEJMUpdateDate") == nil) {
            
            isData = false
            
        } else {
            
            if let theDate = cachedData.objectForKey("NEJMUpdateDate") as? String {
                
                theUpdateDate = theDate
                
            }
            
        }
        
        if (cachedData.objectForKey("NEJMUpdateTime") == nil) {
            
            isData = false
            
        } else {
            
            if let theTime = cachedData.objectForKey("NEJMUpdateTime") as? String {
                
                theUpdateTime = theTime
                
            }
            
        }
        
        return (theUpdateDate, theUpdateTime, isData)
        
    }
    
    
    //Cached settings data
    
    //Caches the specified date range for displayed articles
    public func cacheDateRangeSetting(theRange: Int) {
        
        cachedData.setInteger(theRange, forKey: "dateRange")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Caches the specified rate of notifications for new articles
    public func cacheNotificationRateSetting(notificationRate: Int) {
        
        cachedData.setInteger(notificationRate, forKey: "notificationRate")

        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Caches the specified article topic (NEJM) and specialty (Journal Watch)
    public func cacheArticleTopicSetting(articleTopic: String, articleSpecialty: String) {
        
        cachedData.setObject(articleTopic, forKey: "articleTopic")
        cachedData.setObject(articleSpecialty, forKey: "articleSpecialty")
        
        //Ensures that the cached data was saved
        cachedData.synchronize()
        
    }
    
    //Gets the cached date range for displayed articles
    public func getCachedDateRangeSetting() -> (dateRange: Int, isData: Bool) {
        
        var theDateRange: Int = 6
        
        //Is changed to false if there is no cached date range
        var isData = true
        
        if (cachedData.objectForKey("dateRange") == nil) {
            
            isData = false
            
        } else {
            
            if let theRange = cachedData.integerForKey("dateRange") as? Int {
                
                theDateRange = theRange
                
            }
            
        }
        
        return (theDateRange, isData)
        
    }
    
    //Gets the cached notification rate
    public func getCachedNotificationRateSetting() -> (notificationRate: Int, isData: Bool) {
        
        var theNotificationRate: Int = 3
        
        //Is changed to false if there is no cached notification rate
        var isData = true
        
        if (cachedData.objectForKey("notificationRate") == nil) {
            
            isData = false
            
        } else {
            
            if let theRate = cachedData.integerForKey("notificationRate") as? Int {
                
                theNotificationRate = theRate
                
            }
            
        }
        
        return (theNotificationRate, isData)
        
    }
    
    //Gets the cached article topic (NEJM) and specialty (Journal Watch)
    public func getCachedArticleTopicSetting() -> (articleTopic: String, articleSpecialty: String, isData: Bool) {
        
        var theArticleTopic = "All topics"
        var theArticleSpecialty = "All specialties"
        
        //Is changed to false if there is no cached topic
        var isData = true
        
        if (cachedData.objectForKey("articleTopic") == nil) {
            
            isData = false
            
        } else {
            
            if let theTopic = cachedData.objectForKey("articleTopic") as? String {
                
                theArticleTopic = theTopic
                
            }
            
        }
        
        if (cachedData.objectForKey("articleSpecialty") == nil) {
            
            isData = false
            
        } else {
            
            if let theSpecialty = cachedData.objectForKey("articleSpecialty") as? String {
                
                theArticleSpecialty = theSpecialty
                
            }
            
        }
        
        return (theArticleTopic, theArticleSpecialty, isData)
        
    }
    
}

