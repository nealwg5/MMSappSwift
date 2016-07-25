//
//  Settings Controller.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/6/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

//The view controller for the settings page
class SettingsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //The date range stepper and label
    @IBOutlet weak var dateRangeStepper: UIStepper!
    @IBOutlet weak var dateRangeLabel: UILabel!
    
    //The notification rate stepper and label
    @IBOutlet weak var notificationRateStepper: UIStepper!
    @IBOutlet weak var notificationRateLabel: UILabel!
    
    //The specialty type picker
    @IBOutlet weak var articleTopicPicker: UIPickerView!
    
    //The dictionaries which store the specialties and topics
    let NEJMTopics = getNEJMTopics()
    let JWatchSpecialties = getJWatchSpecialties()
    
    //The specialties to be used
    var topics = ["All topics", "Cardiology", "Dermatology", "Gastroenterology", "Infectious Disease", "Pediatrics"]
    
    //The class which holds cached data
    var theCache = Cache()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Sets the settings options to reflect their current state
        //Gets the date range info from the cache
        let setDateRange = theCache.getCachedDateRangeSetting()
        
        //Checks if there is a cached date range value
        if (setDateRange.isData == true) {
            
            //Changes the date range label value to reflect the proper value
            changeDateRangeLabel(setDateRange.dateRange)
            
            //Changes the stepper value to reflect the proper value
            if (setDateRange.dateRange < 5) {
                
                dateRangeStepper.value = Double(setDateRange.dateRange)
                
            } else if (setDateRange.dateRange == 6) {
                
                dateRangeStepper.value = 5
                
            }
            
        } else {            //There is no cached value, so set it to the last week (0)
            
            dateRangeLabel.text = "The last week"
            theCache.cacheDateRangeSetting(6)
            dateRangeStepper.value = 5
            
        }
        
        //Gets the notification rate info from the cache
        let setNotificationRate = theCache.getCachedNotificationRateSetting()

        //Checks if there is a cached notification rate value
        if (setNotificationRate.isData == true) {
            
            //Changes the notification rate label value to reflect the proper value
            changeNotificationRateLabel(setNotificationRate.notificationRate)
            
            //Changes the stepper value to reflect the proper value
            notificationRateStepper.value = Double(setNotificationRate.notificationRate)
            
        } else {            //There is no cached value, so set it to once a day (3)
            
            notificationRateLabel.text = "Once a day"
            theCache.cacheNotificationRateSetting(3)
            notificationRateStepper.value = 3
            
        }
        
        //Gets the article topic info from the cache
        let setArticleTopic = theCache.getCachedArticleTopicSetting()
        
        //Checks if there is a cached article topic
        if (setArticleTopic.isData == true) {
            
            //Changes the picker value to reflect the proper value
            
            articleTopicPicker.selectRow(topics.indexOf(decodeTopic(setArticleTopic.articleTopic))!, inComponent: 0, animated: true)
            
        } else {            //There is no cached value, so set it to "All topics"
            
            theCache.cacheArticleTopicSetting("All topics", articleSpecialty: "All specialties")
            articleTopicPicker.selectRow(0, inComponent: 0, animated: true)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //Changes the date range label to reflect the specified value
    func changeDateRangeLabel (newValue: Int) {
        
        if (newValue == 0) {
            
            dateRangeLabel.text = "Today"
            
        } else if (newValue == 1) {
            
            dateRangeLabel.text = "Today and yesterday"
            
        } else if (newValue == 2) {
            
            dateRangeLabel.text = "The last three days"
            
        } else if (newValue == 3) {
            
            dateRangeLabel.text = "The last four days"
            
        } else if (newValue == 4) {
            
            dateRangeLabel.text = "The last five days"
            
        } else if (newValue == 6) {
            
            dateRangeLabel.text = "The last week"
            
        } else {            //If for some reason there is no valid value set, make it "The last week"
            
            dateRangeLabel.text = "The last week"
            theCache.cacheDateRangeSetting(6)
            
        }
        
    }
    
    //Changes the notification rate label to reflect the specified value
    func changeNotificationRateLabel (newValue: Int) {
        
        if (newValue == 0) {
            
            notificationRateLabel.text = "Once an hour"
            
        } else if (newValue == 1) {
            
            notificationRateLabel.text = "Every 6 hours"
            
        } else if (newValue == 2) {
            
            notificationRateLabel.text = "Every 12 hours"
            
        } else if (newValue == 3) {
            
            notificationRateLabel.text = "Once a day"
            
        } else if (newValue == 4) {
            
            notificationRateLabel.text = "Once every 3 days"
            
        } else if (newValue == 5) {
            
            notificationRateLabel.text = "Once a week"
            
        } else if (newValue == 6) {
            
            notificationRateLabel.text = "Never"
            
        } else {            //If for some reason there is no valid value set, make it "Once a day"
            
            notificationRateLabel.text = "Once a day"
            theCache.cacheNotificationRateSetting(3)
            
        }
        
    }
    
    //Defines the number of components in the specialty picker
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    //Defines the number of rows in the specialty picker
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return topics.count
        
    }
    
    //Returns the title of the selected picker row
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return topics[row]
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let theTopic = NEJMTopics[topics[row]]
        let theSpecialty = JWatchSpecialties[topics[row]]
        
        NSLog("top: \(theTopic), spec: \(theSpecialty)")

        theCache.cacheArticleTopicSetting(theTopic!, articleSpecialty: theSpecialty!)
    
    }
    
    //Decodes the url encoded topic
    func decodeTopic(theContent: String) -> String {
        
        var theTopic = theContent
        
        theTopic = theTopic.stringByReplacingOccurrencesOfString("%20", withString: " ")
        theTopic = theTopic.stringByReplacingOccurrencesOfString("%2C", withString: ",")
        
        return theTopic
        
    }
    
    //Sets the state of the content range option when it is changed
    @IBAction func dateRangeOptionChanged(sender: UIStepper) {
        
        //Stores the new date range selection
        var newDateRange: Int = 1
        
        //Checks if the stepper is outside the valid bounds. If so, returns the value to a valid one
        if (Int(sender.value) > 5) {
            
            sender.value = 5
            
        }
        
        //Based on the stepper value, sets the proper date range
        if (Int(sender.value) < 5 ) {
            
            newDateRange = Int(sender.value)

        } else {
            
            newDateRange = 6

        }
        
        //Changes the date range label to reflect the new value
        changeDateRangeLabel(newDateRange)
        
        //Cache the new value
        theCache.cacheDateRangeSetting(newDateRange)

    }
    
    //Sets the state of the notification rate option when it is changed
    @IBAction func notificationRateOptionChanged(sender: UIStepper) {
        
        //Stores the new date range selection
        var newNotificationRate: Int = 1
        
        //Checks if the stepper is outside the valid bounds. If so, returns the value to a valid one
        if (Int(sender.value) > 6) {
            
            sender.value = 6
            
        }
        
        //Based on the stepper value, sets the proper date range
        newNotificationRate = Int(sender.value)
        
        //Changes the date range label to reflect the new value
        changeNotificationRateLabel(newNotificationRate)
        
        //Cache the new value
        theCache.cacheNotificationRateSetting(newNotificationRate)
        
    }
    
}