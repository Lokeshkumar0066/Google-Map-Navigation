//
//  SceneDelegate.swift
//  NavigationTracking
//
//  Created by Lokesh on 16/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    var locManager = CLLocationManager()
    var currentLocation = CLLocation()
    var latitudeDegree = Double()
    var longitudeDegree = Double()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        self.getLatLong()

    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

        func getLatLong()
        {
            
            locManager = CLLocationManager()
            if (locManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)))
            {
                locManager.requestWhenInUseAuthorization()
            }
            locManager.delegate = self
            locManager.distanceFilter = kCLDistanceFilterNone
            locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locManager.pausesLocationUpdatesAutomatically = true
            locManager.startUpdatingLocation()
            locManager.startMonitoringSignificantLocationChanges()
            #if (arch(i386) || arch(x86_64)) && os(iOS)
                let userDefault:UserDefaults = UserDefaults.standard
                userDefault.set(29.7677659002815, forKey: "latitude")
                userDefault.set(-95.4144173445003, forKey: "longitude")
            #endif

        }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationPermisson()
    }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
        {
            print("did update called")
            let newLocation:CLLocation = locations.last!
            currentLocation = newLocation
            latitudeDegree = newLocation.coordinate.latitude
            longitudeDegree = newLocation.coordinate.longitude
            
            
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            let coord = locationObj.coordinate

            SingleTonClass.shared.lat = String(coord.latitude)
            SingleTonClass.shared.long = String(coord.longitude)

            SingleTonClass.shared.sourceLat = String(coord.latitude)
            SingleTonClass.shared.sourceLong = String(coord.longitude)
            self.serviceLatLongToAddress()
    //        getAddress(locations: locations)

           

            let latitude:NSString = "\(latitudeDegree)" as NSString
            let longitude:NSString = "\(longitudeDegree)" as NSString
            let userDefault:UserDefaults = UserDefaults.standard
            if latitude.length>0 && longitude.length>0
            {
                userDefault.set(latitude, forKey: "latitude")
                userDefault.set(longitude, forKey: "longitude")
            }
            userDefault.synchronize()
            locManager.stopUpdatingLocation()
        }
        

        func serviceLatLongToAddress() -> Void {
            
            let serviceURL: String = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(SingleTonClass.shared.sourceLat),\(SingleTonClass.shared.sourceLong)&key=AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0"
            
            let apiURL = serviceURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            
            NetworkManager.sharedInstance.getRequestWithDataResponse(url: apiURL!, completionHandler: { (response, error) -> (Void) in
                if error != nil {
                    
                }else {
                    
                    print(response ?? "0")
                    let data:[String:Any] = response as? [String : Any] ?? [:]
                    let status: String = data["status"] as? String ?? ""
                    if status == "OK"{
                        
                        let results:[Any] = data["results"] as? [Any] ?? []
                        let formatted_address: [String:Any] = results[0] as? [String:Any] ?? [:]
                        let address: String = formatted_address["formatted_address"] as? String ?? ""
                        SingleTonClass.shared.sourceAddress = address
                        SingleTonClass.shared.currentAddress = address
                        print("Current Address :\(address)")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
                    }else{
                        
                        
                    }
                }
            })
        }

        func getAddress(locations: [CLLocation]) -> Void {
                var address: String = ""
                
                let geoCoder = CLGeocoder()
                let locationArray = locations as NSArray
                let locationObj = locationArray.lastObject as! CLLocation
                let coord = locationObj.coordinate

                let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                
                geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    var placeMark: CLPlacemark!
                    placeMark = placemarks?[0]
                    if let place = placeMark{
                        print(place)
                        print(place.country ?? " ")
                        print(place.locality ?? " ")
                        print(place.subLocality ?? " ")
                        print(place.thoroughfare ?? " ")
                        print(place.postalCode ?? " ")
                        print(place.subThoroughfare ?? " ")
                        if place.subLocality != nil {
                            address = address + place.subLocality! + ", "
                        }
                        if place.thoroughfare != nil {
                            address = address + place.thoroughfare! + ", "
                        }
                        if place.locality != nil {
                            address = address + place.locality! + ", "
                        }
                        if place.country != nil {
                            address = address + place.country! + ", "
                        }
                        if place.postalCode != nil {
                            address = address + place.postalCode! + " "
                        }
                        
                        var currentCityName = ""
                        if place.locality != nil {
                            currentCityName = currentCityName + place.locality! + ", "
                        }
                        
                        if place.administrativeArea != nil {
                            currentCityName = currentCityName + place.administrativeArea!
                        }
                        
                        SingleTonClass.shared.currentCity = place.locality ?? ""
                        SingleTonClass.shared.currentCityWithState = currentCityName
                        SingleTonClass.shared.countryName = place.country ?? ""
                        print("Latitute ==>> \(SingleTonClass.shared.sourceLat)")
                        print("Longitude ==>> \(SingleTonClass.shared.sourceLong)")
                        print("Latitute ==>> \(SingleTonClass.shared.lat)")
                        print("Longitude ==>> \(SingleTonClass.shared.long)")


                    }
                })
            }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            SingleTonClass.shared.sourceLat = String(29.7677659002815)
            SingleTonClass.shared.sourceLong = String(-95.4144173445003)
            SingleTonClass.shared.lat = String(29.7677659002815)
            SingleTonClass.shared.long = String(-95.4144173445003)

            SingleTonClass.shared.sourceAddress  = ""
            SingleTonClass.shared.currentAddress = ""
        }
        


}

//MARK: Location Permission

@available(iOS 13.0, *)
extension SceneDelegate{
    func locationPermisson(){
              if CLLocationManager.locationServicesEnabled() {
                  switch CLLocationManager.authorizationStatus() {
                  case .notDetermined, .restricted, .denied:
                      print("No access")
                      self.showAcessDeniedAlert(title: "Your Location Services Are Disabled", message: "Navigation Tracking needs your location to better serve you. Please enable location services within Settings on your phone.")
                  case .authorizedAlways, .authorizedWhenInUse:
                      print("Access")
                  }
              } else {
                  print("Location services are not enabled")
              }
          }
       
       
       func showAcessDeniedAlert(title:String, message:String) {
           let alertController = UIAlertController(title: title,
                                                   message: message,
                                                   preferredStyle: .alert)
           
           let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
               
               // THIS IS WHERE THE MAGIC HAPPENS!!!!
               if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                   if #available(iOS 10.0, *) {
                       UIApplication.shared.open(appSettings as URL)
                   } else {
                       // Fallback on earlier versions
                       UIApplication.shared.openURL(NSURL(string:UIApplication.openSettingsURLString)! as URL)
                   }
               }
           }
           alertController.addAction(settingsAction)
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (alertAction) in
               self.locationPermisson()
           }
           alertController.addAction(cancelAction)
        window?.makeKeyAndVisible()
        window?.rootViewController!.present(alertController, animated: true, completion: nil)
       }
}
