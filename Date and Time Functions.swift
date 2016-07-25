//
//  Date and Time Functions.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/6/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

//Returns the date in YYYY-MM-DD format
func getDateYYYYMMDD() -> String {
    
    let todayDateFull = NSDate()
    let todayDateFormat = NSDateFormatter()
    todayDateFormat.dateFormat = "yyyy-MM-dd"
    let date = todayDateFormat.stringFromDate(todayDateFull)
    
    return date
    
}

//Returns the date in human readable form (ie July 17, 2015)
func getDateHuman() -> String {
    
    let todayDateFull = NSDate()
    let todayDateFormat = NSDateFormatter()
    todayDateFormat.dateStyle = NSDateFormatterStyle.LongStyle
    let date = todayDateFormat.stringFromDate(todayDateFull)
    
    return date
    
}

//Converts a date with YYYY-MM-DD format to a human readable format
func convertDateYYYYMMDDToHuman(theDate: String) -> String {
    
    //Converts the date to a NSDate
    let yyyymmddDateFormatter = NSDateFormatter()
    yyyymmddDateFormatter.dateFormat = "yyyy-MM-dd"
    let unformattedDate = yyyymmddDateFormatter.dateFromString(theDate)
    
    //Converts the NSDate to a date string with the proper format
    let humanDateFormatter = NSDateFormatter()
    humanDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
    let convertedDate = humanDateFormatter.stringFromDate(unformattedDate!)
    
    return convertedDate
    
}

//Returns the date before the specified date in YYYY-MM-DD format
func getDayBeforeYYYYMMDD(theDate: String) -> String {
    
    //Gets the current calendar to assist in determining yesterday's date
    let theCalendar = NSCalendar.currentCalendar()
    
    //Converts the specified date string to a NSDate
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    var newDate = dateFormatter.dateFromString(theDate)
    
    //The components for getting yesterday's date
    let yesterdayComponent = NSDateComponents()
    yesterdayComponent.day = -1
    
    //Gets yesterday's date
    newDate = theCalendar.dateByAddingComponents(yesterdayComponent, toDate: newDate!, options: [])
    let newDateString = dateFormatter.stringFromDate(newDate!)
    
    return newDateString
    
}

//Returns the date before the specified date in human readable format (ie July 17, 2015)
func getDayBeforeHuman(theDate: String) -> String {
    
    //Gets the current calendar to assist in determining yesterday's date
    let theCalendar = NSCalendar.currentCalendar()
    
    //Converts the specified date string to a NSDate
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
    var newDate = dateFormatter.dateFromString(theDate)
    
    //The components for getting yesterday's date
    let yesterdayComponent = NSDateComponents()
    yesterdayComponent.day = -1
    
    //Gets yesterday's date
    newDate = theCalendar.dateByAddingComponents(yesterdayComponent, toDate: newDate!, options: [])
    let newDateString = dateFormatter.stringFromDate(newDate!)
    
    return newDateString
    
}

//Returns the current time in human readable form (12 hour time)
func getTimeHuman() -> String {
    
    let theDate = NSDate()
    let dateFormatter = NSDateFormatter()
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.timeZone = NSTimeZone()
    
    let theTime = dateFormatter.stringFromDate(theDate)
    
    return theTime
}

//Returns the day (DD), month (MM), year (YYYY), and full date (YYYY-MM-DD) the specified amount of days before today
func getDateInfoYYYYMMDD(daysBeforeToday: Int) -> (day: String, month: String, year: String, fullDate: String) {

    //Store the date, month, and year values
    var theDay = "00"
    var theMonth = "00"
    var theYear = "0000"
    
    //Gets today's date in yyyy-mm-dd format
    var theDate = getDateYYYYMMDD()
    
    //Loops to get the specified date in yyyy-mm-dd format
    if (daysBeforeToday >= 0) {
    
        for (var dateIndex = 0; dateIndex < daysBeforeToday; dateIndex++) {
    
            theDate = getDayBeforeYYYYMMDD(theDate)
        
        }
        
    }
    
    //Makes sure that a valid date was received
    if (theDate.characters.count == 10) {
        
        theDay = theDate.substringFromIndex(theDate.startIndex.advancedBy(8))
        theMonth = theDate.substringToIndex(theDate.startIndex.advancedBy(7))
        theMonth = theMonth.substringFromIndex(theMonth.startIndex.advancedBy(5))
        theYear = theDate.substringToIndex(theDate.startIndex.advancedBy(4))
        
    }
    
    return (theDay, theMonth, theYear, theDate)
    
}