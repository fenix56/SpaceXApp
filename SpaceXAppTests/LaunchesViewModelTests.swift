//
//  LaunchesViewModelTests.swift
//  SpaceXAppTests
//
//  Created by Przemek on 29/08/22.
//

import XCTest
@testable import SpaceXApp

class LaunchesViewModelTests: XCTestCase {

    var launchViewModel:LaunchesViewModel!
    var respository:LaunchRepository!
    var networkManager:MockNetworkManager!
    
    override func setUpWithError() throws {
        
        networkManager = MockNetworkManager()
        
        respository = LaunchRepository(networkManager: networkManager)
        launchViewModel = LaunchesViewModel(repository: respository)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testFetchCompanyAndLaunchInfo_success() {
        
        let companyApiRequest = ApiRequest(baseUrl: EndPoint.baseUrl, path: "company_response_success", params: [:])
        
        let launchApiRequest = ApiRequest(baseUrl: EndPoint.baseUrl, path:"launc_details_scuccess", params: [:])
        
        launchViewModel.fetchCompanyAndLaunchInfo(companyApiRequest: companyApiRequest, launchApiRequest: launchApiRequest)
        
        XCTAssertEqual(launchViewModel.launchesCount, 2)
        
        XCTAssertEqual(launchViewModel.getCompanyInfo(), "SpaceX was founded by Elon Musk in 2002. It has now 9500 employees, 3 launch sites, and is valued at USD 74000000000")
        
        
       let items =  launchViewModel.getLaunchClickDetails(for: 0)
        
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].name, "Web Cast")
        XCTAssertEqual(items[1].name, "Wikipedia")
        XCTAssertEqual(items[2].name, "Article")

       let launchInfo =  launchViewModel.getLaunchInfo(for: 0)
        
        XCTAssertNotNil(launchInfo)
        
        XCTAssertEqual(launchInfo!.year, "2006")
        XCTAssertEqual(launchInfo!.isMissonSuccessFull, false)
        
        XCTAssertNil(launchViewModel.getLaunchInfo(for: -1))
        
        XCTAssertNil(launchViewModel.getLaunchInfo(for: 3))

    }
    
}
