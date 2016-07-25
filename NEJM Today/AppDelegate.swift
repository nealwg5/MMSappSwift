//
//  AppDelegate.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/5/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Registering a notificaiton
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        
        //The time interval between background fetches
        var fetchInterval = NSTimeInterval()
        
        //The current notification rate
        let notificationRate = Cache().getCachedNotificationRateSetting().notificationRate
        
        //Sets the fetch interval according to the user's desired notification rate
        if (notificationRate == 0) {
            
            fetchInterval = 3600                //1 hour
            
        } else if (notificationRate == 1) {
            
            fetchInterval = (3600 * 6)          //6 hours
            
        } else if (notificationRate == 2) {
            
            fetchInterval = (3600 * 12)         //12 hours
            
        } else if (notificationRate == 3) {
            
            fetchInterval = (3600 * 24)         //1 day
            
        } else if (notificationRate == 4) {
            
            fetchInterval = (3600 * 24 * 3)     //3 days
            
        } else if (notificationRate == 5) {
            
            fetchInterval = (3600 * 24 * 7)     //1 week
            
        } else if (notificationRate == 6) {
            
            fetchInterval = UIApplicationBackgroundFetchIntervalNever
            
        } else {
            
            fetchInterval = UIApplicationBackgroundFetchIntervalNever
            
        }

        //Sets the fetch interval
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(fetchInterval)

        return true
        
    }
    
    //Background fetching delegate
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        //Picks the proper view controller to get functions from
        //Gets all view controllers
        if let theNavigationController = window?.rootViewController as? UINavigationController,
            viewControllerList = theNavigationController.viewControllers as? [UIViewController] {
                
                //Loops through each view controller to find the article list one
                for viewController in viewControllerList {

                    //If the view controller is the one which displays the article list, then call functions to check for new articles
                    if let fetchViewController = viewController as? ViewController {

                        //Gets the completion handler value and sends a notification if necessary
                        let theCompletionHandler = fetchViewController.newArticlesFetchHandler()
                                            
                        if (theCompletionHandler == "None") {
                            
                            completionHandler(UIBackgroundFetchResult.NoData)
                            
                        } else if (theCompletionHandler == "New") {
                            
                            completionHandler(UIBackgroundFetchResult.NewData)
                        
                        } else {
                            
                            completionHandler(UIBackgroundFetchResult.NoData)
                            
                        }

                    }
                    
                }
                
        } else {            //If something went wrong, the fetch failed
            
            completionHandler(UIBackgroundFetchResult.Failed)
            
        }
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

