//
//  LaunchRepository.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation
import Combine

protocol LaunchRepositoryType {
    func getCompany(apiRequest:ApiRequestType)->Future<CompanyDetails, ServiceError>
    
    func getLaunches(apiRequest:ApiRequestType)->Future<[LaunchDetails], ServiceError>
}

class LaunchRepository: LaunchRepositoryType {
    
    let networkManager:Networkable
    var cancellables:Set<AnyCancellable?> = Set()

    init(networkManager:Networkable = NetowrkManager()) {
        self.networkManager = networkManager
    }
    
    func getCompany(apiRequest: ApiRequestType) -> Future<CompanyDetails, ServiceError> {
        return Future { [weak self] promise in
            
            let cancellable =  self?.networkManager.doApiCall(apiRequest: apiRequest).sink { completion in
                
            } receiveValue: { data in
                guard let decodedResponse = try? JSONDecoder().decode(CompanyInfo.self, from: data) else {
                    return promise(.failure(ServiceError.parsinError))
                }
                let companyDetails = CompanyDetails(name:decodedResponse.name, founder: decodedResponse.founder, year: decodedResponse.founded, employees: decodedResponse.employees, launchSites: decodedResponse.launchSites, valuation: decodedResponse.valuation)
                return promise(.success(companyDetails))

            }

            self?.cancellables.insert(cancellable)
          
        }
    }
    
    func getLaunches(apiRequest: ApiRequestType) -> Future<[LaunchDetails], ServiceError> {
        return Future { [weak self] promise in
            
            let cancellable =  self?.networkManager.doApiCall(apiRequest: apiRequest).sink { completion in
                
            } receiveValue: { data in
        
                guard let decodedResponse = try? JSONDecoder().decode([LaunchInfo].self, from: data) else {
                    return promise(.failure(ServiceError.parsinError))
                }
                
               let dateFormatter = DateFormatter()
               let launchDetails =  decodedResponse.map{
                   LaunchDetails(missionName: $0.name, missionLaunchDate: "\($0.dateUTC.getDate(dateFormatter, currentFormat: Constants.utcDateFormat, newFormat: Constants.dateFormat1)!)/\($0.dateUTC.getDate(dateFormatter, currentFormat: Constants.utcDateFormat, newFormat: Constants.dateFormat2)!)", missionLauncDisplayDate: "", rocketType: $0.rocket ?? "", daysSinceFrom:$0.dateUTC.daysSinceOrFrom( dateFormatter:dateFormatter), patchImage: $0.links.patch.small ?? "", isMissonSuccessFull: $0.success ?? false,
                                 items: LaunchDetails.getLaunchClickDetails(launchInfo: $0),
                                 year: $0.dateUTC.getDate(dateFormatter, currentFormat: Constants.utcDateFormat, newFormat:"YYYY") ?? "")
                }
                return promise(.success(launchDetails))

            }
            self?.cancellables.insert(cancellable)

        }
    }
    
   
    deinit {
        cancellables.forEach { cancellable in
            cancellable?.cancel()
        }
    }
}
