//
//  SingleTonClass.swift
//  NavigationTracking
//
//  Created by Lokesh on 16/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit

class SingleTonClass: NSObject {
    static var shared = SingleTonClass()

    
    var lat: String = ""
    var long: String = ""
    var currentAddress: String = ""
    var currentCity: String = ""
    var currentCityWithState:String = ""
    var countryName = ""
    
    var sourceLat: String = ""
    var sourceLong: String = ""
    var sourceAddress: String = ""
    
    var destinationLat: String = ""
    var destinationLong: String = ""
    var destinationAddress: String = ""
}
