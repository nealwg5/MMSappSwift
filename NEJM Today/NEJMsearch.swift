//
//  NEJMsearch.swift
//  NEJM Today
//
//  Created by nwang on 7/11/16.
//  Copyright © 2016 Narahara, Andrew. All rights reserved.
//


import Foundation
import UIKit

class NEJMsearch {
    
    var query = ""
    //Gets all article information of the specified query, returns an array of the article objects
    func getArticles(dateRange: Int) -> [Article] {
        
        //Stores the titles and ids
        var titles = [String]()
        var ids = [String]()
        var pubDates = [String]()
        var extracts = [String]()
        titles = []
        ids = []
        pubDates = []
        extracts = []
        
        //The cache
        let theCache = Cache()
        
        //Sets up the url of the request
        let contentDate = getDateInfoYYYYMMDD(dateRange)
        let endDate = getDateYYYYMMDD()
        var url = ""
        
        let sharedPref = NSUserDefaults.standardUserDefaults()
        if let search = sharedPref.stringForKey("searchQuery")
        {
            query = search
        }
        
        
        //If a specific article topic is selected, include that in the query string
        if ((theCache.getCachedArticleTopicSetting().articleTopic != "All topics") && (theCache.getCachedArticleTopicSetting().isData == true)){
            
            url = "https://ilerxy5ujh.execute-api.us-east-1.amazonaws.com/nejm_stage/search?query=topic:%22\(theCache.getCachedArticleTopicSetting().articleTopic)%22__has_oa_conclusions:%22true%22%20AND%20fullText:\(query)&endDate=\(endDate)&format=xml"
            
        } else {        //Don't include a specific article topic in the search
            
            url = "https://ilerxy5ujh.execute-api.us-east-1.amazonaws.com/nejm_stage/search?query=has_oa_conclusions:true%20AND%20fullText:\(query)&endDate=\(endDate)&format=xml"
            
        }
        
       
        let theURL = NSURL(string: url)
       
        
        
        //Stores the raw XML of the request
        var theXML = String()
        
        //Gets the request XML
        if let urlData = NSData(contentsOfURL: theURL!) {
            
            theXML = String(NSString(data: urlData, encoding: NSUTF8StringEncoding)!)
            
        }
        
        //Stores the total number of articles in the giver date range
        let totalArticles = getArticleCountWithXML(theXML)
        
        //Stores individual titles, ids, pubdates, and conclusions to be added to their respective arrays
        var theTitle = ""
        var theID = ""
        var thePubDate = ""
        var theConclusion = ""
        
        //Loops through each article in the request
        for (var articleIndex = 0; articleIndex < totalArticles; articleIndex += 1) {
            
            //Gets the title, id, pubdate, and conclusion strings of each article and appends them to their respective arrays
            theTitle = getChildContent("title", fullText: theXML)
            theTitle = decodeXML(theTitle)      //Decodes any character entities
            titles.append(theTitle)
            
            theID = getChildContent("id>", fullText: theXML)
            theID = getSubstringToIndexSafe(theID, theIndex: getSubstringIndex(theID, theSubstring: "-nejm"))       //Cuts of the "-nejm" at the end
            ids.append(theID)
            
            thePubDate = getChildContent("pubdate", fullText: theXML)
            pubDates.append(thePubDate)
            
            theConclusion = getChildContent("oa_conclusion", fullText: theXML)
            
            //Parses the conclusion
            //Cuts the conclusion up into arrays of words and tags
            var extractArray = cutContentIntoArray(theConclusion)
            
            //Stores individual extracts
            var parsedExtract = ""
            
            //Loop index
            var wordIndex = 0
            
            //Counts the number of words put into the extract so far
            var numWords = 0
            
            //Loops until the extract is 25 words long
            while (wordIndex < extractArray.count){
                
                //Decodes any character entities, if necessary
                extractArray[wordIndex] = decodeXML(extractArray[wordIndex])
                
                //Checks if the content is a word, and if it is, increments the word counter
                if (isATag(extractArray[wordIndex]) == false) {
                    
                    numWords += 1
                    
                } else {    //If the content is a tag, set its value to nothing, so the tag string isn't included in the extract
                    
                    extractArray[wordIndex] = ""
                    
                }
                
                parsedExtract = parsedExtract + extractArray[wordIndex]
                
                //Increment the index so the next piece of content can be added to the extract
                wordIndex += 1
                
            }
            
            //Appends the extract to the extract array
            extracts.append(parsedExtract)
            
            //Cuts the first list item from the XML so the data can be extracted from the next list item
            if (articleIndex < (totalArticles - 1)) {
                
                theXML = getSubstringFromIndexSafe(theXML, theIndex: (getSubstringIndex(theXML, theSubstring: "</result>") + 9))
                
            }
            
        }
        
        //A list of article objects
        var theArticles = [Article]()
        
        //Loops though each article and adds the data
        for (var articleIndex = 0; articleIndex < totalArticles; articleIndex += 1) {
            
            //A blank article object
            let individualArticle = Article()
            
            //Sets the values of the article object
            individualArticle.title = titles[articleIndex]
            individualArticle.id = ids[articleIndex]
            individualArticle.pubDate = pubDates[articleIndex]
            individualArticle.extract = NSAttributedString(string: extracts[articleIndex])
            
            //Appends the article object to the article array
            theArticles.append(individualArticle)
            
        }
        
        //return theArticles
        return theArticles
        
    }
    
    //Returns the number of articles in the article list
    func getArticleCountWithXML(theContent: String) -> Int {
        
        var theXML = theContent
        var theCount: Int = 0
        
        //Loops until the end of the last article in the list
        while (getSubstringIndex(theXML, theSubstring: "</result>") != -100) {
            
            //Cuts the first article in the list from XML string
            theXML = getSubstringFromIndexSafe(theXML, theIndex: (getSubstringIndex(theXML, theSubstring: "</result>") + 9))
            
            //Increments the article count
            theCount += 1
            
        }
        
        return theCount
        
    }
    
    //Allows for safely getting substrings (handles errors gracefully)
    func getSubstringFromIndexSafe(fullText: String, theIndex: Int) -> String {
        
        if (theIndex < 0) { //This used to cause an error because there can't be a negative index for a character in a string
            
            return ""
            
        } else if (fullText.characters.count < (theIndex + 1)) {  //This used to cause an error because the character index can't be outside the string length
            
            return ""
            
        } else {
            
            return fullText.substringFromIndex(fullText.startIndex.advancedBy(theIndex))
            
        }
        
    }
    
    //Allows for safely getting substrings (handles errors gracefully)
    func getSubstringToIndexSafe(fullText: String, theIndex: Int) -> String {
        
        if (theIndex < 0) { //This used to cause an error because there can't be a negative index for a character in a string
            
            return ""
            
        } else if (fullText.characters.count < (theIndex + 1)) {  //This used to cause an error because the character index can't be outside the string length
            
            return ""
            
        } else {
            
            return fullText.substringToIndex(fullText.startIndex.advancedBy(theIndex))
            
        }
        
    }
    
    //Returns the index of the first character of the substring in the string
    //If the substring does not exist in the string, returns -100
    func getSubstringIndex(theString: String, theSubstring: String) -> Int {
        
        if let substringRange = theString.rangeOfString(theSubstring) {
            
            let theIndex: Int = theString.startIndex.distanceTo(substringRange.startIndex)
            
            return theIndex
            
        }
        
        return -100
    }
    
    //Returns the content inside the specified tag (works for both XML and HTML tags, and any other tags enclosed by "<" and ">")
    //Will return ONLY content inside of the first instance of the tag
    //Returns an empty string if there is no instance of the specified tag in the string
    func getChildContent(tagName: String, fullText: String) -> String {
        
        //Cuts off the content before the tag
        let indexOfStartTagStart = getSubstringIndex(fullText, theSubstring: "<\(tagName)")
        let cutFromStartTagStart = getSubstringFromIndexSafe(fullText, theIndex: indexOfStartTagStart)
        
        //Cuts off the opening tag
        let indexOfContentStart = getSubstringIndex(cutFromStartTagStart, theSubstring: ">") + 1
        let cutFromStartTagEnd = getSubstringFromIndexSafe(cutFromStartTagStart, theIndex: indexOfContentStart)
        
        //Cuts off the content after the closing tag, including the closing tag itself (now you're left with just the content)
        let indexOfEndTag = getSubstringIndex(cutFromStartTagEnd, theSubstring: "</\(tagName)")
        let theContent = getSubstringToIndexSafe(cutFromStartTagEnd, theIndex: indexOfEndTag)
        
        return theContent
        
    }
    
    //Returns true if new paragraph
    //Returns false otherwise
    func isNewParagraph(theContent: String) -> Bool {
        
        let cutContent = theContent
        var isNewPara = false
        
        if ((getSubstringIndex(cutContent, theSubstring: "</p") != -100) && (getSubstringIndex(cutContent, theSubstring: ">") != -100)) {
            
            isNewPara = true
            
        }
        
        return isNewPara
        
    }
    
    //Returns true if the string is an XML or HTML tag, or any other kind of tag enclosed by "<" and ">"
    //Returns false otherwise
    func isATag(theContent: String) -> Bool {
        
        let cutContent = theContent
        var isTag = false
        
        if ((getSubstringIndex(cutContent, theSubstring: "<") != -100) && (getSubstringIndex(cutContent, theSubstring: ">") != -100)) {
            
            isTag = true
            
        }
        
        return isTag
        
    }
    
    //Cuts the content into an array of individual words and tags
    func cutContentIntoArray(theContent: String) -> [String] {
        
        //The array of words and tags
        var contentArray = [String]()
        
        //The uncut content
        let content = theContent
        
        //Used to build words or tags from indiviual characters
        var arrayItem = ""
        
        //True if you're currently building a tag
        //False if you're currently building a word
        var inTag = false
        
        //Loops through each character in the content string
        for indivChar in content.characters {
            
            //If this is true, then you're currently at the end of a word
            if ((indivChar == " ") && (inTag == false)) {
                
                //Add a space to the end of the word
                arrayItem = arrayItem + " "
                
                //Append the word to the content array
                contentArray.append(arrayItem)
                
                //Set the value of the current word or tag to nothing, since you're about to start a new word or tag
                arrayItem = ""
                
            } else if (indivChar == "<") {  //You're starting to either build a tag, or the "<" character is used in the content
                
                //If you're currently building something else, append it to the content array
                if (arrayItem != "") {
                    
                    contentArray.append(arrayItem)
                    
                }
                
                //You're starting a new tag (or possibly a word), the first character of which is a "<"
                arrayItem = "<"
                
                //Assume you're in a tag
                inTag = true
                
            } else if (indivChar == ">") {  //You're either done building a tag, or the ">" character is used in the content
                
                //Add a ">" to the end of the tag or word you're currently building
                arrayItem = arrayItem + ">"
                
                //Append the tag or word to the content array
                contentArray.append(arrayItem)
                
                //Set the value of the current word or tag to nothing, since you're about to start a new word or tag
                arrayItem = ""
                
                //You're no longer building a tag
                inTag = false
                
            } else {    //You're in the middle of a word or tag
                
                //Append the character to the end of the current word or tag
                arrayItem = arrayItem + String(indivChar)
                
            }
            
        }
        
        return contentArray
        
    }
    
    //Decodes character entities (ex: accented a = &#225)
    func decodeXML(theContent: String) -> String {
        
        //The content to decode
        var cutContent = theContent
        
        //Loops until there are no more character entities
        while ((getSubstringIndex(cutContent, theSubstring: "&") != -100) && (getSubstringIndex(cutContent, theSubstring: ";") != -100)) {
            
            //Cuts and stores the substring from the beginning of the string to the start of the first character entitiy
            let leftIndex = getSubstringIndex(cutContent, theSubstring: "&")
            let leftCut = getSubstringToIndexSafe(cutContent, theIndex: leftIndex)
            
            //The substring from the start of the first character entity to the end of the string
            let leftEntityCut = getSubstringFromIndexSafe(cutContent, theIndex: leftIndex)
            
            //Cuts and stores the string of the first character entity
            let rightIndex = getSubstringIndex(leftEntityCut, theSubstring: ";") + 1
            let entityCut = getSubstringToIndexSafe(leftEntityCut, theIndex: rightIndex)
            
            //Cuts and stores the substring from the end of the first character entity to the end of the string
            let rightCut = getSubstringFromIndexSafe(leftEntityCut, theIndex: rightIndex)
            
            //Decodes the character entity
            let charEntity = entityCut.dataUsingEncoding(NSUTF8StringEncoding)
            let attributedOptions: [String: AnyObject] = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding]
            let attributedString = try? NSAttributedString(data: charEntity!, options: attributedOptions, documentAttributes: nil)
            let decodedEntity = attributedString?.string
            
            //Recombines the string with the first character entity decoded
            cutContent = leftCut + decodedEntity! + rightCut
            
        }
        
        return cutContent
        
    }
    
    
}