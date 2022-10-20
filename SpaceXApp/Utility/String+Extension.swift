//
//  String+Extension.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation


extension String {
    
    func getDate(_ dateFormater:DateFormatter, currentFormat:String)-> Date? {
        
        dateFormater.dateFormat = currentFormat
        
        return dateFormater.date(from: self)
    }
    
    func getDate(_ dateFormater:DateFormatter, currentFormat:String, newFormat:String)-> String? {
        
        dateFormater.dateFormat = currentFormat
        
        guard let currentDate = dateFormater.date(from: self) else {
            return nil
        }
        
        dateFormater.dateFormat = newFormat

        return  dateFormater.string(from: currentDate)
    }
    
    func daysSinceOrFrom(dateFormatter:DateFormatter)-> (String, Int){
       
        guard  let date = getDate(dateFormatter, currentFormat: Constants.utcDateFormat) else { return ("", 0) }
        
        let days =  Date().days(from: date)
        let str = days > 0 ? "Days Since now" : "Days From now"
        return (str , abs(days))
    }
}
