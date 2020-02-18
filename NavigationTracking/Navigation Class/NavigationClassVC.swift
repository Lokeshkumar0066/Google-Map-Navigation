//
//  NavigationClassVC.swift
//  NavigationTracking
//
//  Created by manish on 17/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import CoreLocation

typealias completionHandler = (_ address: String) -> (Void)



class NavigationClassVC: UIViewController,GMSMapViewDelegate {

    var markerList = [GMSMarker]()
    var timer = Timer()

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var viewExit: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblKM: UILabel!
    let markerOne = GMSMarker()
    let marker = GMSMarker()
    var duration: String = ""
    var KM: String = ""
    var cooridnates2D:CLLocationCoordinate2D?
    var second: Int = 0
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentTime()
        self.lblDuration.text = duration
        viewExit.viewStartCornerRadius()
        
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Double(SingleTonClass.shared.sourceLat)!), longitude: CLLocationDegrees(Double(SingleTonClass.shared.sourceLong)!), zoom: 10.0)
        mapView.camera = camera
//        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//        mapView.settings.compassButton = true
//        mapView.settings.indoorPicker = true
        mapView.accessibilityElementsHidden = true
        mapView.isTrafficEnabled = true
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
//        locationManager.activityType = CLActivityTypeOther
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

    }
    
    
    func getCurrentTime(){
        let earlyDate = Calendar.current.date(
        byAdding: .second,
        value: second,
        to: Date())
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm a"
        self.lblKM.text = KM + " . " + dateFormatterGet.string(from: earlyDate!)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
//        if (locationManager.responds(to: #selector(setter: CLLocationManager.allowsBackgroundLocationUpdates))){
//            self.locationManager.allowsBackgroundLocationUpdates = true;
//        }

         locationManager.requestAlwaysAuthorization()

         print("did load")
         print(locationManager)

         //get current user location for startup
         if CLLocationManager.locationServicesEnabled() {
             locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
             locationManager.startMonitoringSignificantLocationChanges()
         }

        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            print("Updating location now")
            }
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            print("User must enable access in settings")
            break
        }
        UpdateMap()
    }
    
    func UpdateMap(){
        let sourceLat = SingleTonClass.shared.sourceLat
        let sourceLong = SingleTonClass.shared.sourceLong
        let sourceAddress = SingleTonClass.shared.sourceAddress
        let destinationLat = SingleTonClass.shared.destinationLat
        let destinationLong = SingleTonClass.shared.destinationLong
        let destinationAddress = SingleTonClass.shared.destinationAddress
        self.loadMap(SourceLatitude: sourceLat, SourceLongitude: sourceLong, SourceAddress: sourceAddress, destinationLatitude: destinationLat, destinationLongitude: destinationLong, destinationAddress: destinationAddress,type: "initial")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func onClickExit(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           if !Connectivity.isConnectedToInternet{
                self.showAlert()
            }
       }
}



//MAR: Load Map

extension NavigationClassVC{
    func loadMap(SourceLatitude:String, SourceLongitude:String, SourceAddress:String, destinationLatitude:String, destinationLongitude:String, destinationAddress:String,type:String){
        
        let lat = (SourceLatitude as NSString).floatValue
        let long = (SourceLongitude as NSString).floatValue
        
        let latSecond = (destinationLatitude as NSString).floatValue
        let longSecond = (destinationLongitude as NSString).floatValue
        
        self.mapView.reloadInputViews()
        marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.title = SourceAddress
//        marker.rotation = 90
        marker.map = mapView
        marker.icon = UIImage(named:"circle")

        markerOne.position = CLLocationCoordinate2DMake(CLLocationDegrees(latSecond), CLLocationDegrees(longSecond))
        markerOne.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        markerOne.title = destinationAddress
        markerOne.map = mapView
        markerOne.icon = UIImage(named:"pin_marker")
        markerList = []
        markerList.append(marker)
        markerList.append(marker)


        let getMovedMapCenterOne: CLLocation =  CLLocation(latitude: CLLocationDegrees(latSecond), longitude: CLLocationDegrees(longSecond))
        let getMovedMapCenterTwo: CLLocation =  CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))

//        marker.rotation = getBearingBetweenTwoPoints1(point1: getMovedMapCenterOne, point2: getMovedMapCenterTwo)


        
        if type == "initial"{
//            var bounds = GMSCoordinateBounds()
//            for marker in markerList {
//                bounds = bounds.includingCoordinate(marker.position)
//            }
//            let update = GMSCameraUpdate.fit(bounds, withPadding: 0.0)
//            mapView.animate(with: update)

            let origin = "\(lat),\(long)"
            let destination = "\(latSecond),\(longSecond)"
            self.createPloyLine(origin: origin, destination: destination, lat: lat, long: long, latSecond: latSecond, longSecond: longSecond,sourceMarker: marker,destinationMarker:markerOne)
        }
    }
    
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radians: radiansBearing)
    }
}

//MAR: Create PolyLine Between Coordinate's
extension NavigationClassVC{
    
    func createPloyLine(origin: String, destination: String,lat:Float,long:Float,latSecond:Float,longSecond:Float,sourceMarker:GMSMarker,destinationMarker:GMSMarker){
    if Connectivity.isConnectedToInternet{
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0"

        Alamofire.request(url).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization


            do {
                let json = try JSON(data: response.data!)
                let routes = json["routes"].arrayValue

                // print route using Polyline

                if routes.count == 0{
                    let path = GMSMutablePath()
                    path.add(CLLocationCoordinate2DMake(CLLocationDegrees(latSecond), CLLocationDegrees(longSecond)))
                    path.add(CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long)))
                    let rectangle = GMSPolyline(path: path)
                    rectangle.strokeWidth = 8
                    rectangle.strokeColor = UIColor.purple
                    rectangle.map = self.mapView
                }else{
                    for route in routes
                    {
                        let routeOverviewPolyline = route["overview_polyline"].dictionary
                        let points = routeOverviewPolyline?["points"]?.stringValue
                        let path = GMSPath.init(fromEncodedPath: points!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 8
                        polyline.strokeColor = UIColor.purple
                        polyline.map = self.mapView
                    }
                }

                DispatchQueue.main.async {
                    var bounds = GMSCoordinateBounds()
                    for marker in self.markerList {
                        bounds = bounds.includingCoordinate(marker.position)
                    }
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
//                    self.mapView.animate(with: update)
                    self.mapView.animate(toZoom: 15.0)
                }
                
            } catch _ {

            }
        }        }else{
        self.showAlert()
    }
}
}





extension NavigationClassVC{
        func getAddress(locations: [CLLocation],completionHandler: @escaping completionHandler) -> Void {
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
                    
                    completionHandler(address)
                            
                }
            })
        }
}


// MARK: - CLLocationManagerDelegate
extension NavigationClassVC: CLLocationManagerDelegate {

  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")

    let sourceLat = String(location.coordinate.latitude)
    let sourceLong = String(location.coordinate.longitude)
    let sourceAddress = SingleTonClass.shared.sourceAddress
    let destinationLat = SingleTonClass.shared.destinationLat
    let destinationLong = SingleTonClass.shared.destinationLong
    let destinationAddress = SingleTonClass.shared.destinationAddress
    self.loadMap(SourceLatitude: sourceLat, SourceLongitude: sourceLong, SourceAddress: sourceAddress, destinationLatitude: destinationLat, destinationLongitude: destinationLong, destinationAddress: destinationAddress,type: "")
    
    
    if sourceLat == destinationLat && sourceLong == destinationLong{
        let alertController = UIAlertController(title: "Destination", message: "You reached your location", preferredStyle:UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        { action -> Void in
            self.navigationController?.popViewController(animated: true)
        })
        self.present(alertController, animated: true, completion: nil)

    }

  }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        self.mapView.camera.heading = newHeading.magneticHeading
//        self.mapView.setCamera(mapView.camera, animated: true)
        self.mapView.animate(toBearing: newHeading.magneticHeading)
        marker.rotation = newHeading.trueHeading
    }

    
  // Handle authorization for the location manager.
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .restricted:
      print("Location access was restricted.")
    case .denied:
      print("User denied access to location.")
      // Display the map using the default location.
      mapView.isHidden = false
    case .notDetermined:
      print("Location status not determined.")
    case .authorizedAlways: fallthrough
    case .authorizedWhenInUse:
      print("Location status is OK.")
    }
  }

  // Handle location manager errors.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    locationManager.stopUpdatingLocation()
    print("Error: \(error)")
  }
}

