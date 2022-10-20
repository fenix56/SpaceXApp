//
//  Date+Extension.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation

extension Date {
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
}
