//
//  CompanyInfo.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation

// MARK: - CompanyInfo
struct CompanyInfo: Decodable {
    let headquarters: Headquarters
    let links: CompanyLinks
    let name, founder: String
    let founded, employees, vehicles, launchSites: Int
    let testSites: Int
    let ceo, cto, coo, ctoPropulsion: String
    let valuation: Int
    let summary, id: String

    enum CodingKeys: String, CodingKey {
        case headquarters, links, name, founder, founded, employees, vehicles
        case launchSites = "launch_sites"
        case testSites = "test_sites"
        case ceo, cto, coo
        case ctoPropulsion = "cto_propulsion"
        case valuation, summary, id
    }
}

// MARK: - Headquarters
struct Headquarters: Codable {
    let address, city, state: String
}

// MARK: - Links
struct CompanyLinks: Codable {
    let website, flickr, twitter, elonTwitter: String

    enum CodingKeys: String, CodingKey {
        case website, flickr, twitter
        case elonTwitter = "elon_twitter"
    }
}
