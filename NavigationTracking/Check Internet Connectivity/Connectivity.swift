//
//  Connectivity.swift
//  NavigationTracking
//
//  Created by manish on 18/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit
import Alamofire

class Connectivity: NSObject {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }

}
