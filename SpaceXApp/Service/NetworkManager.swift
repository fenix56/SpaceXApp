//
//  NetworkManager.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import Foundation
import Combine

protocol Networkable {
    func doApiCall(apiRequest: ApiRequestType) -> Future<Data, ServiceError>
}

class NetowrkManager: Networkable {
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func doApiCall(apiRequest: ApiRequestType) -> Future<Data, ServiceError> {
        
        return Future { [weak self ]promise in
            
            guard let request = URLRequest.getURLRequest(for: apiRequest) else {
                promise(.failure(ServiceError.failedToCreateRequest))
                return
            }
            
            self?.session.dataTask(with: request, completionHandler: { data, response, error in
                
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    return promise(.failure(ServiceError.dataNotFound))
                    
                }
                
                guard let data = data, error == nil else {
                    return promise(.failure(ServiceError.dataNotFound))
                }
                
                return promise(.success(data))
            }).resume()
        }
    }
}
