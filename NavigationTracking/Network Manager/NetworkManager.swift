//
//  NetworkManager.swift
//  NavigationTracking
//
//  Created by Lokesh on 16/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit
import Alamofire

typealias networkCompletionHandler = (_ responseJSON: AnyObject?, _ error: Error?) -> (Void)


class NetworkManager: NSObject {
    
    static let sharedInstance: NetworkManager = NetworkManager()
    
    private override init() {
        
    }
    
    //MARK: POST Request
    func postRequestWithDataResponse(url urlString:String, parameters: [String: Any], completionHandler: @escaping networkCompletionHandler) -> Void {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            debugPrint("time lines: \(response.timeline)")
            
            switch response.result {
            case .success:

                
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //JSON Parser
                        if let data = response.data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                completionHandler(json as AnyObject, nil)
                            }catch let error {
                                debugPrint("Error while converting json \(error)")
                                completionHandler(response.result.value as AnyObject, error as NSError)
                            }
                        }

                        
//                        completionHandler(response.result as AnyObject, nil)
                    case 511:
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: "some thing issue in Servie side"])
//                        self.showErrorMessages(error: error)

                        completionHandler(response.result as AnyObject, error)
                        

                        
                    default:
                        
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: ""])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                        break
                    }
                }
                break
                
            case .failure:
                
                completionHandler(nil, response.error as Error?)
                
            }
        }
    }
    
    //MARK: POST Request
    func postRequestWithMovieBooking(url urlString:String, parameters: [String: Any], completionHandler: @escaping networkCompletionHandler) -> Void {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            
            debugPrint("time lines: \(response.timeline)")
            
            switch response.result {
            case .success:
                
                
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //JSON Parser
                        if let data = response.data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                completionHandler(json as AnyObject, nil)
                            }catch let error {
                                debugPrint("Error while converting json \(error)")
                                completionHandler(response.result.value as AnyObject, error as NSError)
                            }
                        }
                        
                        
                    //                        completionHandler(response.result as AnyObject, nil)
                    case 511:
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: "some thing issue in Servie side"])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                        
                        
                        
                    default:
                        
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: ""])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                        break
                    }
                }
                break
                
            case .failure:
                
                completionHandler(nil, response.error as Error?)
                
            }
        }
    }
    
    //MARK: GET Request
    func getRequestWithDataResponse(url urlString:String, completionHandler: @escaping networkCompletionHandler) -> Void {
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        
        Alamofire.request(urlString, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            
            debugPrint("time lines: \(response.timeline)")
            //case .success(let JSON):
            switch response.result {
            case .success:
                
                
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //JSON Parser
                        if let data = response.data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                completionHandler(json as AnyObject, nil)
                            }catch let error {
                                debugPrint("Error while converting json \(error)")
                                completionHandler(response.result.value as AnyObject, error as NSError)
                            }
                        }
                        
                        
                    case 511:
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                    default:
                        
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                        
                        break
                    }
                }
                break
                
            case .failure:
                
                completionHandler(nil, response.error as Error?)
                
            }
        }
    }
    
    
    //MARK: POST Request
    func postRequestWithForCab(url urlString:String, parameters: [String: Any], completionHandler: @escaping networkCompletionHandler) -> Void {
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        manager.request(urlString, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON { (response) in
            
            debugPrint("time lines: \(response.timeline)")
            
            switch response.result {
            case .success:
                
                
                if let httpStatusCode = response.response?.statusCode {
                    switch(httpStatusCode) {
                    case 200:
                        //JSON Parser
                        if let data = response.data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                completionHandler(json as AnyObject, nil)
                            }catch let error {
                                debugPrint("Error while converting json \(error)")
                                completionHandler(response.result.value as AnyObject, error as NSError)
                            }
                        }
                        
                        
                    //                        completionHandler(response.result as AnyObject, nil)
                    case 511:
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: "some thing issue in Servie side"])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                        
                        
                        
                    default:
                        
                        let error = NSError(domain: "Error", code: 511, userInfo: [NSLocalizedDescriptionKey: ""])
                        //                        self.showErrorMessages(error: error)
                        
                        completionHandler(response.result as AnyObject, error)
                        break
                    }
                }
                break
                
            case .failure:
                
                completionHandler(nil, response.error as Error?)
                
            }
        }
    }
    
}
