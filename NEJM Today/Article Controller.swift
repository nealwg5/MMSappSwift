//
//  Article Controller.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/6/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

//The web view controller that displays full articles
class WebViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!
    
    //The URL of the displayed article (default is nejm homepage)
    var articleURL = "www.nejm.org"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        //Displays the article in the webview
        self.outputArticle()
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //Displays the article in the webview
    func outputArticle() {
        
        //Creates the URL request
        let theURL = NSURL(string: articleURL)
        let URLToShow = NSURLRequest(URL: theURL!)

        //Loads the page
        webView.loadRequest(URLToShow)
        
    }
    
}