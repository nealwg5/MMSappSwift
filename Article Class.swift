//
//  Article Class.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/6/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

//Holds article data
//The NSCoding allows Article objects to be encoded and decoded so they can be cached with NSUserDefaults
public class Article: NSObject, NSCoding {
    
    //The article data
    var title: String
    var id: String
    var pubDate: String
    var extract: NSAttributedString
    
    //Empty initializer
    public override init() {
        
        self.title = String()
        self.id = String()
        self.pubDate = String()
        self.extract = NSAttributedString()
        
    }
    
    //Decoding
    public required init?(coder aDecoder: NSCoder) {
        
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.id = aDecoder.decodeObjectForKey("id") as! String
        self.pubDate = aDecoder.decodeObjectForKey("pubDate") as! String
        self.extract = aDecoder.decodeObjectForKey("extract") as! NSAttributedString
        
        super.init()
        
    }
    
    //Encoding
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(pubDate, forKey: "pubDate")
        aCoder.encodeObject(extract, forKey: "extract")
        
    }
    
}
