//
//  JournalWatchSearch.swift
//  NEJM Today
//
//  Created by nwang on 7/11/16.
//  Copyright © 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

class JournalWatchSearch {
    
    var query = ""
    //Gets the article titles and IDs for today
    func getArticles(dateRange: Int) -> [Article] {
        
        //Stores the titles and ids
        var titles = [String]()
        var ids = [String]()
        var pubDates = [String]()
        var extracts = [NSAttributedString]()
        titles = []
        ids = []
        pubDates = []
        extracts = []
        
        //The cache
        let theCache = Cache()
        
        //Sets up the url of the request
        let startDate = getDateInfoYYYYMMDD(dateRange)
        let endDate = getDateYYYYMMDD()
        var url = ""
        
        let sharedPref = NSUserDefaults.standardUserDefaults()
        if let search = sharedPref.stringForKey("searchQuery")
        {
            query = search
        }
        
        //If a specific article topic is selected, include that in the query string
        if ((theCache.getCachedArticleTopicSetting().articleSpecialty != "All specialties") && (theCache.getCachedArticleTopicSetting().isData == true)){
            
            url = "https://avelqu6i45.execute-api.us-east-1.amazonaws.com/jwatch_stage/search?query=\(query)&articleClass:%22Summary%22__specialty:%22\(theCache.getCachedArticleTopicSetting().articleSpecialty)%22&endDate=\(endDate)&format=xml"
            
            NSLog("URL TEST: \(url), specialty: \(theCache.getCachedArticleTopicSetting().articleSpecialty)")
            
        } else {        //Don't include a specific article topic in the search
            
            url = "https://avelqu6i45.execute-api.us-east-1.amazonaws.com/jwatch_stage/search?query=\(query)&articleClass:%22Summary%22&endDate=\(endDate)&format=xml"
        }
        
        NSLog("theURL: \(url)")
        
        let theURL = NSURL(string: url)
        
        //Stores the raw XML of the request
        var theXML = String()
        
        //Gets the request XML
        if let urlData = NSData(contentsOfURL: theURL!) {
            
            theXML = String(NSString(data: urlData, encoding: NSUTF8StringEncoding)!)
            
        }
        
        //Gets the total number of articles for the given day
        let totalArticles = getArticleCountWithXML(theXML)
        
        //Stores individual titles and ids to be added to their respective arrays
        var theTitle = ""
        var theID = ""
        var thePubDate = ""
        
        //Loops through each article in the request
        for (var articleIndex = 0; articleIndex < totalArticles; articleIndex += 1) {
            
            //Gets the information of each article and decodes any character entities, if there are any
            theTitle = getChildContent("title", fullText: theXML)
            theTitle = decodeXML(theTitle)
            titles.append(theTitle)
            
            theID = getChildContent("id>", fullText: theXML)
            ids.append(theID)
            
            thePubDate = getChildContent("pubdate", fullText: theXML)
            pubDates.append(thePubDate)
            
            //The parsed content of the extract
            let parsedExtract = NSMutableAttributedString()
            
            //The parsed content of an individual word or tag
            var individualParsedContent = NSMutableAttributedString()
            
            //Gets the mixed content of the extract
            let theExtract = getChildContent("extract", fullText: theXML)
            
            //Cuts the content up into arrays of words and tags
            var extractArray = cutContentIntoArray(theExtract)
            
            //The "state" of the extract (ie bold, italic...)
            //normal = p, italic = italic, bold = bold boldItalic = bold and italic
            var extractContentState = "normal"
            
            //Loop through each word or tag
            for (var contentIndex = 0; contentIndex < extractArray.count; contentIndex += 1) {
                
                //Gets the content state of the word or tag and decodes any character entities, if necessary
                extractContentState = self.getContentState(extractContentState, theContent: extractArray[contentIndex])
                extractArray[contentIndex] = self.decodeXML(extractArray[contentIndex])
                
                //Checks if the content is a tag, and if so, sets its value to nothing, so the tag string isn't included in the extract
                if (self.isATag(extractArray[contentIndex]) == true) {
                    
                    extractArray[contentIndex] = ""
                    
                }
                
                //Set the font style of the content based on the content state and append it to the extract string
                individualParsedContent = self.setContentStyle(extractContentState, theContent: extractArray[contentIndex])
                parsedExtract.appendAttributedString(individualParsedContent)
                
            }
            
            //Paragraph style for the extract
            let extractParaStyle = NSMutableParagraphStyle()
            extractParaStyle.firstLineHeadIndent = 0.0
            extractParaStyle.paragraphSpacingBefore = 10.0
            
            //Add paragraph style to parsed extract
            parsedExtract.addAttribute(NSParagraphStyleAttributeName, value: extractParaStyle, range: NSRange(location: 0, length: parsedExtract.length))
            
            //Appends the parsed extract to the extract array
            extracts.append(parsedExtract)
            
            //Cuts the first list item from the XML so the data can be extracted from the next list item
            if (articleIndex < (totalArticles - 1)) {
                
                theXML = getSubstringFromIndexSafe(theXML, theIndex: (getSubstringIndex(theXML, theSubstring: "</result>") + 9))
                
            }
            
        }
        
        //A list of article objects
        var theArticles = [Article]()
        
        //Loops though each article and adds the data
        for (var articleIndex = 0; articleIndex < totalArticles; articleIndex++) {
            
            //A blank article object
            let individualArticle = Article()
            
            //Sets the values of the article object
            individualArticle.title = titles[articleIndex]
            individualArticle.id = ids[articleIndex]
            individualArticle.pubDate = pubDates[articleIndex]
            individualArticle.extract = extracts[articleIndex]
            
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
    
    //Returns the number of articles in the article list, taking in the XML as an argument
    func getArticleCount(theList: String) -> Int {
        
        //Stores the number of articles
        var theCount = 0
        
        var theXML = theList
        
        //Loops until the end of the last article in the list
        theSubstring:  while (getSubstringIndex(theXML, theSubstring: "</result>") != -100) {
            
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
        if (indexOfStartTagStart < 0) {
            
            return ""
            
        }
        let cutFromStartTagStart = getSubstringFromIndexSafe(fullText, theIndex: indexOfStartTagStart)
        
        //Cuts off the opening tag
        let indexOfContentStart = getSubstringIndex(cutFromStartTagStart, theSubstring: ">") + 1
        if (indexOfContentStart < 0) {
            
            return ""
            
        }
        let cutFromStartTagEnd = getSubstringFromIndexSafe(cutFromStartTagStart, theIndex: indexOfContentStart)
        
        //Cuts off the content after the closing tag, including the closing tag itself (now you're left with just the content)
        let indexOfEndTag = getSubstringIndex(cutFromStartTagEnd, theSubstring: "</\(tagName)")
        if (indexOfEndTag < 0) {
            
            return ""
            
        }
        let theContent = getSubstringToIndexSafe(cutFromStartTagEnd, theIndex: indexOfEndTag)
        
        return theContent
        
    }
    
    //Returns the content inside the specified tag with the specified attribute (works for both XML and HTML tags, and any other tags enclosed by "<" and ">")
    //Will return ONLY content inside of the first instance of the tag
    //Returns an empty string if there is no instance of the specified tag in the string
    func getChildContentWithAttribute(tagName: String, fullText: String, attribute: String) -> String {
        
        var theText = fullText
        var isProperTag = false
        
        //Cuts content off until the beginning of the specified tag
        while (isProperTag == false) {
            
            //Cuts off the content before the tag
            let indexOfStartTagStart = getSubstringIndex(theText, theSubstring: "<\(tagName)")
            if (indexOfStartTagStart < 0) {
                
                return ""
                
            }
            theText = getSubstringFromIndexSafe(theText, theIndex: indexOfStartTagStart)
            
            //Gets the full tag
            let indexOfStartTagEnd = getSubstringIndex(theText, theSubstring: ">")
            if (indexOfStartTagEnd < 0) {
                
                return ""
                
            }
            let fullTag = getSubstringToIndexSafe(theText, theIndex: indexOfStartTagEnd)
            
            //Checks if the specified attribute is in the tag
            if (getSubstringIndex(fullTag, theSubstring: "\(attribute)") != -100) {
                
                isProperTag = true
                
            }
            
            //Cuts off the openingtheSubstring:  tag
            let indexOfContentStart = getSubstringIndex(theText, theSubstring: ">") + 1
            if (indexOfStartTagStart < 0) {
                
                return ""
                
            }
            theText = getSubstringFromIndexSafe(theText, theIndex: indexOfContentStart)
            
        }
        
        //Cuts off the content after the closing tag, including the closing tag itself (now you're left with justheSubstring: t the content)
        let indexOfEndTag = getSubstringIndex(theText, theSubstring: "</\(tagName)")
        if (indexOfEndTag < 0) {
            
            return ""
            
        }
        let theContent = getSubstringToIndexSafe(theText, theIndex: indexOfEndTag)
        
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
    
    //Returns the given content's state
    func getContentState(currentState: String, theContent: String) -> String {
        
        //Stores the content's state
        var newState = ""
        
        //Checks if there is an XML tag which denotates the beginning or end of a content state (ie beginning or end of bold text)
        //If so, sets the appropriate state
        if (theContent == "<bold>") {   //Start of bold text
            
            if (currentState == "italic") {
                
                newState = "boldItalic"
                
            } else {
                
                newState = "bold"
                
            }
            
        } else if (theContent == "<italic>") {  //Start of italic text
            
            if (currentState == "bold") {
                
                newState = "boldItalic"
                
            } else {
                
                newState = "italic"
                
            }
            
        } else if (theContent == "</bold>") {   //End of bold text
            
            if (currentState == "boldItalic") {
                
                newState = "italic"
                
            } else {
                
                newState = "normal"
                
            }
            
        } else if (theContent == "</italic>") { //End of italic text
            
            if (currentState == "boldItalic") {
                
                newState = "bold"
                
            } else {
                
                newState = "normal"
                
            }
            
        } else if (theContent.rangeOfString("<sec") != nil) {   //Start of a section (used at the end of articles)
            
            newState = "sec"
            
        } else if (theContent.rangeOfString("</sec") != nil) {  //End of a section (used at the end of articles)
            
            newState = "normal"
            
        }  else if (theContent.rangeOfString("<ext-link") != nil) { //Start of a hyperlink
            
            if (currentState == "sec") {
                
                newState = "sec-link"
                
            } else {
                
                newState = "normal"
                
            }
            
        }  else if (theContent.rangeOfString("</ext-link") != nil) {    //End of a hyperlink
            
            if (currentState == "sec-link") {
                
                newState = "sec"
                
            } else {
                
                newState = "normal"
                
            }
            
        } else if (theContent.rangeOfString("<p") != nil) { //Start of a paragraph
            
            if (currentState == "sec") {
                
                newState = "sec"
                
            } else {
                
                newState = "normal"
                
            }
            
        } else if (theContent.rangeOfString("</p") != nil) {    //End of a paragraph
            
            if (currentState == "sec") {
                
                newState = "sec"
                
            } else {
                
                newState = "normal"
                
            }
            
        } else if (theContent.rangeOfString("<title") != nil) { //Start of a title
            
            newState = "title"
            
        } else if (theContent.rangeOfString("</title") != nil) {    //End of a title
            
            newState = "sec"
            
        }  else if (theContent == "<sup>") {   //Superscript
            
            if (currentState == "boldItalic") {
                
                newState = "boldItalic-sup-"
                
            } else if (currentState == "bold") {
                
                newState = "bold-sup-"
                
            } else if (currentState == "italic") {
                
                newState = "italic-sup-"
                
            } else if (currentState == "normal") {
                
                newState = "normal-sup-"
                
            } else {
                
                newState = "normal-sup-"
                
            }
            
        } else if (theContent == "</sup>") {  //End of superscript
            
            newState = getSubstringToIndexSafe(currentState, theIndex: (getSubstringIndex(currentState, theSubstring: "-")))
            
        } else {
            
            newState = currentState
            
        }
        
        return newState
        
    }
    
    //Decodes character entities
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
    
    //Adds the appropriate font style to the content
    func setContentStyle (contentState: String, theContent: String) -> NSMutableAttributedString {
        
        //Font definitions
        let normFont = UIFont(name: "Georgia", size: 12.0) ?? UIFont.systemFontOfSize(12.0)
        let normalFont = [NSFontAttributeName: normFont]
        
        let iFont = UIFont(name: "Georgia-Italic", size: 12.0) ?? UIFont.systemFontOfSize(12.0)
        let italicFont = [NSFontAttributeName: iFont]
        
        let bFont = UIFont(name: "Georgia-Bold", size: 12.0) ?? UIFont.systemFontOfSize(12.0)
        let boldFont = [NSFontAttributeName: bFont]
        
        let biFont = UIFont(name: "Georgia-BoldItalic", size: 12.0) ?? UIFont.systemFontOfSize(12.0)
        let boldItalicFont = [NSFontAttributeName: biFont]
        
        let lFont = UIFont(name: "Georgia", size: 12.0) ?? UIFont.systemFontOfSize(12.0)
        let linkFont = [NSFontAttributeName: lFont]
        
        //Holds the styled content
        var styledContent = NSMutableAttributedString()
        
        //Sets the style based on the content state
        if (contentState == "normal") {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: normalFont)
            
        } else if (contentState.rangeOfString("boldItalic") != nil) {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: boldItalicFont)
            
        } else if (contentState.rangeOfString("italic") != nil) {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: italicFont)
            
        } else if (contentState.rangeOfString("bold") != nil) {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: boldFont)
            
        } else if (contentState == "sec") {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: normalFont)
            
        } else if (contentState == "sec-link") {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: linkFont)
            styledContent.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: NSMakeRange(0, styledContent.length))
            styledContent.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: NSMakeRange(0, styledContent.length))
            
        } else if (contentState == "title") {
            
            styledContent = NSMutableAttributedString(string: "")
            
        } else {
            
            styledContent = NSMutableAttributedString(string: theContent, attributes: normalFont)
            
        }
        
        //Add superscript if necessary
        if (contentState.rangeOfString("-sup-") != nil) {
            
            if (styledContent.length > 0) {
                
                styledContent.addAttribute(kCTSuperscriptAttributeName as String, value: 1, range: NSMakeRange(0, styledContent.length))
                
            }
            
        }
        
        return styledContent
        
    }
    
}


