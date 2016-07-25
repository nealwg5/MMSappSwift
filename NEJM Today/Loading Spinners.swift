//
//  Loading Spinners.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/6/16.
//  Copyright (c) 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

//Makes the screen-filling semi-translucent dark container which appears when articles are refreshing
func makeDarkContainer(theView: UIView, theContainer: UIView) -> UIView {
    
    theContainer.frame = theView.frame
    theContainer.center = theView.center
    theContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    theContainer.hidden = true
    
    return theContainer
    
}

//Makes the centered box which contains the refresh spinner
func makeSpinContainer(theView: UIView, theContainer: UIView) -> UIView {
    
    theContainer.frame = CGRectMake(0, 0, 160, 80)
    theContainer.center = theView.center
    theContainer.backgroundColor = UIColor(red: 63.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 0.7)
    theContainer.clipsToBounds = true
    theContainer.layer.cornerRadius = 10
    
    return theContainer
    
}

//Makes the refresh spinner
func makeSpinner(theSpinner: UIActivityIndicatorView, theContainer: UIView) -> UIActivityIndicatorView {
    
    theSpinner.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    theSpinner.activityIndicatorViewStyle =
        UIActivityIndicatorViewStyle.WhiteLarge
    theSpinner.center = CGPointMake(theContainer.frame.size.width / 2,
        (theContainer.frame.size.height / 2) - 15);
    
    return theSpinner
    
}

//Makes the label that appears with the refresh spinner
func makeSpinLabel(theLabel: UILabel, theContainer: UIView) -> UILabel {
    
    theLabel.frame = CGRectMake(0.0, 0.0, 150, 20.0)
    theLabel.center = CGPointMake(theContainer.frame.size.width / 2, (theContainer.frame.size.height / 2) + 15)
    theLabel.textColor = UIColor.whiteColor()
    theLabel.text = "Loading Articles"
    theLabel.textAlignment = NSTextAlignment.Center
    theLabel.font = UIFont(name: "Helvetica-Bold", size: 16)
    
    return theLabel
    
}






