//
//  Article Topic Dictionaries.swift
//  NEJM Today
//
//  Created by Narahara, Andrew on 1/14/16.
//  Copyright © 2016 Narahara, Andrew. All rights reserved.
//

import Foundation
import UIKit

//Gets a dictionary of all NEJM topics and their respective values to be passed in the API request
func getNEJMTopics() -> [String: String] {
    
    var NEJMTopics = [String: String]()
    NEJMTopics["All topics"] = "All topics"
    NEJMTopics["Allergy/Immunology"] = "Allergy/Immunology"
    NEJMTopics["Cardiology"] = "Cardiology"
    NEJMTopics["Dermatology"] = "Dermatology"
    NEJMTopics["Cardiology"] = "Cardiology"
    NEJMTopics["Emergency Medicine"] = "Emergency%20Medicine"
    NEJMTopics["Endocrinology"] = "Endocrinology"
    NEJMTopics["Gastroenterology"] = "Gastroenterology"
    NEJMTopics["Genetics"] = "Genetics"
    NEJMTopics["Geriatrics/Aging"] = "Geriatrics/Aging"
    NEJMTopics["Health Policy and Reform"] = "Health%20Policy%20and%20Reform"
    NEJMTopics["Hematology/Oncology"] = "Hematology/Oncology"
    NEJMTopics["Infectious Disease"] = "Infectious%20Disease"
    NEJMTopics["Medical Ethics"] = "Medical%20Ethics"
    NEJMTopics["Medical Practice, Training, and Education"] = "Medical%20Practice%2C%20Training%2C%20and%20Education"
    NEJMTopics["Medical Statistics"] = "Medical%20Statistics"
    NEJMTopics["Nephrology"] = "Nephrology"
    NEJMTopics["Neurology/Neurosurgery"] = "Neurology/Neurosurgery"
    NEJMTopics["Obstetrics/Gynecology"] = "Obstetrics/Gynecology"
    NEJMTopics["Ophthalmology"] = "Ophthalmology"
    NEJMTopics["Orthopedics"] = "Orthopedics"
    NEJMTopics["Otolaryngology"] = "Otolaryngology"
    NEJMTopics["Pediatrics"] = "Pediatrics"
    NEJMTopics["Primary Care/Hospitalist"] = "Primary%20Care/Hospitalist"
    NEJMTopics["Psychiatry"] = "Psychiatry"
    NEJMTopics["Public Health, Policy, and Training"] = "Public%20Health%2C%20Policy%2C%20and%20Training"
    NEJMTopics["Pulmonary/Critical Care"] = "Pulmonary/Critical%20Care"
    NEJMTopics["Rheumatology"] = "Rheumatology"
    NEJMTopics["Surgery"] = "Surgery"
    NEJMTopics["Urology/Prostate Disease"] = "Urology/Prostate%20Disease"
    
    return NEJMTopics
    
}

//Gets a dictionary of all Journal Watch specialties and their respective values to be passed in the API request
func getJWatchSpecialties() -> [String: String] {
    
    var JWatchSpecialties = [String: String]()
    JWatchSpecialties["All topics"] = "All specialties"
    JWatchSpecialties["Cardiology"] = "jwc"                         //In common with NEJM
    JWatchSpecialties["Dermatology"] = "jwd"                        //In common with NEJM
    JWatchSpecialties["Emergency Medicine"] = "jwe"                 //In common with NEJM
    JWatchSpecialties["Gastroenterology"] = "jwg"                   //In common with NEJM
    JWatchSpecialties["General Medicine"] = "jwa"
    JWatchSpecialties["HIV/AIDS Clinical Care"] = "acc"
    JWatchSpecialties["Hospital Medicine"] = "jhm"
    JWatchSpecialties["Infectious Disease"] = "jwi"                 //In common with NEJM
    JWatchSpecialties["Neurology/Neurosurgery"] = "jwn"             //In common with NEJM - Actually "Infectious Diseases"
    JWatchSpecialties["Oncology and Hematology"] = "joh"
    JWatchSpecialties["Pediatrics"] = "jpa"                         //In common with NEJM - Actually "Pediatrics and Adolescent Medicine"
    JWatchSpecialties["Psychiatry"] = "jwp"                         //In common with NEJM
    JWatchSpecialties["Women's Health"] = "jww"
    
    return JWatchSpecialties
    
}