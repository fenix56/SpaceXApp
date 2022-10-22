//
//  CompanyDetails.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation

struct CompanyAndLaunchDetails {
    let companyDetails: CompanyDetails
    let launchDetails: [LaunchDetails]
}

struct LaunchDetails {
    let missionName: String
    let missionLaunchDate: String
    let missionLauncDisplayDate: String
    let rocketType: String
    let daysSinceFrom: (String, Int)
    let patchImage: String
    let isMissonSuccessFull: Bool
    var items: [LaunchClickItemDetails] = []
    var year: String
    
    static func getLaunchClickDetails(launchInfo: LaunchInfo) -> [LaunchClickItemDetails] {
        var items: [LaunchClickItemDetails] = []
        
        if let webCast = launchInfo.links.webcast {
            items.append(LaunchClickItemDetails(name: "Web Cast", navigationUrl: webCast))
        }
        
        if let wikipedia = launchInfo.links.wikipedia {
            items.append(LaunchClickItemDetails(name: "Wikipedia", navigationUrl: wikipedia))
        }
        
        if let pressKit = launchInfo.links.presskit {
            items.append(LaunchClickItemDetails(name: "Press Kit", navigationUrl: pressKit))
        }
        
        if let article = launchInfo.links.article {
            items.append(LaunchClickItemDetails(name: "Article", navigationUrl: article))
        }
        return items
    }
}

struct CompanyDetails {
    let name: String
    let founder: String
    let year: Int
    let employees: Int
    let launchSites: Int
    let valuation: Int
}

struct LaunchClickItemDetails {
    let name: String
    let navigationUrl: String
}
