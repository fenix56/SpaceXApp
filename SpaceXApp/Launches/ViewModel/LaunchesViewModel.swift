//
//  LaunchesViewModel.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation
import Combine

protocol LaunchesViewModelType {
    var stateBinding: Published<LaunchsState>.Publisher { get }
    var launchesCount: Int { get }
    func getCompanyInfo() -> String
    func getLaunchClickDetails(for index: Int) -> [LaunchClickItemDetails]
    func getLaunchInfo(for index: Int) -> LaunchDetails?
    func fetchCompanyAndLaunchInfo(companyApiRequest: ApiRequestType, launchApiRequest: ApiRequestType)
    
    var filterCriteria: [FilterCriteria] {get}
    
    func updateFilters()
}

enum LaunchsState {
    case none
    case loading
    case finishedLoading
    case error(String)
    case filterSelection
}

class LaunchesViewModel: LaunchesViewModelType {
    
    var filterCriteria: [FilterCriteria] = []
    
    var stateBinding: Published<LaunchsState>.Publisher { $state }
    
    private let repository: LaunchRepositoryType
    private var cancellables: Set<AnyCancellable> = Set()
    
    private var companyAndLaunchDetails: CompanyAndLaunchDetails?
    
    @Published  var state: LaunchsState = .none
    
    var filteredLaunchDetails: [LaunchDetails] = []
    
    var launchesCount: Int {
        if !filteredLaunchDetails.isEmpty {
            return filteredLaunchDetails.count
        }
        return companyAndLaunchDetails?.launchDetails.count ?? 0
    }
    
    init(repository: LaunchRepositoryType) {
        self.repository = repository
    }
    
    func getCompanyInfo() -> String {
        guard let companyAndLaunchDetails = companyAndLaunchDetails else {
            return ""
        }
        
        let companyDetails = companyAndLaunchDetails.companyDetails
        
        return  "\(companyDetails.name) was founded by \(companyDetails.founder) in \(companyDetails.year). It has now \(companyDetails.employees) employees, \(companyDetails.launchSites) launch sites, and is valued at USD \(companyDetails.valuation)" // swiftlint:disable:this line_length
    }
    
    func getLaunchInfo(for index: Int) -> LaunchDetails? {
        guard let companyAndLaunchDetails = companyAndLaunchDetails else {
            return nil
        }
        
        guard index < launchesCount, index >= 0 else {
            return nil
        }
        
        if !filteredLaunchDetails.isEmpty {
            return filteredLaunchDetails[index]
        }
        return companyAndLaunchDetails.launchDetails[index]
    }
    
    func getLaunchClickDetails(for index: Int) -> [LaunchClickItemDetails] {
        guard let companyAndLaunchDetails = companyAndLaunchDetails else {
            return []
        }
        return companyAndLaunchDetails.launchDetails[index].items
    }
    
    func getFilterCriterias() -> [FilterCriteria] {
        var years: Set<String> = Set()
        var filterCriterias: [FilterCriteria] = []
        
        companyAndLaunchDetails?.launchDetails.forEach({ launchDetails in
            years.insert(launchDetails.year)
        })
        
        let sortedYears = years.sorted()
        
        filterCriterias.append(contentsOf: sortedYears.map { FilterByYears(year: $0) })
        
        filterCriterias.append(FilterByLaunchType(launchType: .failure))
        filterCriterias.append(FilterByLaunchType(launchType: .success))
        
        filterCriterias.append(Sorting())
        
        return filterCriterias
    }
    
    func updateFilters() {
        
        let selectedFilterCriterias = filterCriteria.filter {
            $0.isSelected == true
        }
        filteredLaunchDetails = []
        if let companyAndLaunchDetails = companyAndLaunchDetails {
            selectedFilterCriterias.forEach { filter in
                
                if let filter = filter as? FilterByLaunchType {
                    switch filter.launchType {
                    case .success:
                        
                        filteredLaunchDetails =  filteredLaunchDetails.filter { launchDetails in
                            launchDetails.isMissonSuccessFull == true
                        }
                        
                    case .failure:
                        filteredLaunchDetails =  filteredLaunchDetails.filter { launchDetails in
                            launchDetails.isMissonSuccessFull == false
                        }
                        
                    }
                }
                
                if let filter = filter as? FilterByYears {
                    filteredLaunchDetails.append(contentsOf: companyAndLaunchDetails.launchDetails.filter { launchDetails in
                        launchDetails.year == filter.year
                    })
                }
                
                if filter as? Sorting != nil {
                    if filteredLaunchDetails.isEmpty && selectedFilterCriterias.count == 1 {
                        filteredLaunchDetails = companyAndLaunchDetails.launchDetails
                    }
                    filteredLaunchDetails.sort { Int($0.year) ?? 0 > Int($1.year) ?? 0}
                    
                }
                
            }
        } else {
            filteredLaunchDetails = []
        }
        
        self.state = .filterSelection
    }
    
    func fetchCompanyAndLaunchInfo(companyApiRequest companyapiRequest: ApiRequestType, launchApiRequest apiRequest: ApiRequestType) {
        
        state = LaunchsState.loading
        
        let companyPublisher = fetchCompanyInfo(apiRequest: companyapiRequest)
        
        let launchPublisher = fetchLaunches(apiRequest: apiRequest)
        
        let cancalable = Publishers.Zip(companyPublisher, launchPublisher).sink { _ in
            
        } receiveValue: { [weak self] companyDetails, launchesDetails in
            let companyAndLaunchDetails = CompanyAndLaunchDetails(companyDetails: companyDetails, launchDetails: launchesDetails)
            
            self?.companyAndLaunchDetails = companyAndLaunchDetails
            self?.state = LaunchsState.finishedLoading
            self?.filterCriteria = self?.getFilterCriterias() ?? []
            
        }
        
        self.cancellables.insert(cancalable)
        
    }
    
    func fetchCompanyInfo(apiRequest: ApiRequestType)-> AnyPublisher<CompanyDetails, ServiceError> {
        let publisher =   self.repository.getCompany(apiRequest: apiRequest)
        
        return publisher.eraseToAnyPublisher()
        
    }
    
    func fetchLaunches(apiRequest: ApiRequestType)-> AnyPublisher<[LaunchDetails], ServiceError> {
        let publisher =   self.repository.getLaunches(apiRequest: apiRequest)
        
        return publisher.eraseToAnyPublisher()
    }
    
    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
}
