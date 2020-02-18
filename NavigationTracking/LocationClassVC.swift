//
//  ViewController.swift
//  NavigationTracking
//
//  Created by Lokesh on 16/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class LocationClassVC: UIViewController,GMSMapViewDelegate,AutoPlaceDelegate {
    
    
    @IBOutlet weak var mapView: GMSMapView!
    var cooridnates2D:CLLocationCoordinate2D?

    @IBOutlet weak var viewPickUp: UIView!
    @IBOutlet weak var viewDrop: UIView!
    @IBOutlet weak var viewStartNavigation: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblKM: UILabel!
    @IBOutlet weak var txtPickUpLocation: UITextField!
    @IBOutlet weak var txtDropLocation: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    var second: Int = 0
    var timer = Timer()
    let marker = GMSMarker()
    let markerOne = GMSMarker()
    let polyline = GMSPolyline()
    var waypointsArray: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewPickUp.viewBorder()
        viewDrop.viewBorder()
        viewStartNavigation.viewStartCornerRadius()
        lblKM.isHidden = true
        lblDuration.isHidden = true
        viewStartNavigation.alpha = 0.4
        startBtn.isEnabled = false
        self.updateCamera(lat: 0.0,long:0.0)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.settings.indoorPicker = true
        mapView.settings.zoomGestures = true
        mapView.accessibilityElementsHidden = true
        mapView.isTrafficEnabled = true
        mapView.animate(toViewingAngle: 45)
        mapView.delegate = self
        
        
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "updateLocation"))
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation), name: NSNotification.Name(rawValue: "updateLocation"), object: nil)
        
        
    }
    
    
    @objc func updateLocation(){
        let sourceLat = Double(SingleTonClass.shared.sourceLat)
        let sourceLong = Double(SingleTonClass.shared.sourceLong)
        self.updateCamera(lat: sourceLat!,long:sourceLong!)
        self.txtPickUpLocation.text = SingleTonClass.shared.sourceAddress
        mapView.clear()
    }
    
    
    func updateCamera(lat:Double, long:Double){
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long), zoom: 10.0)
        mapView.camera = camera
    }
    
    //MAK: On Click on Location Button...

    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: Double(SingleTonClass.shared.lat)!, longitude: Double(SingleTonClass.shared.long)!, zoom: 10.0)
        self.mapView.camera = camera
        self.mapView.isMyLocationEnabled = true
        self.mapView.reloadInputViews()
        
        
        let sourceLat = SingleTonClass.shared.lat
        let sourceLong = SingleTonClass.shared.long
        let sourceAddress = SingleTonClass.shared.currentAddress
        let destinationLat = SingleTonClass.shared.destinationLat
        let destinationLong = SingleTonClass.shared.destinationLong
        let destinationAddress = SingleTonClass.shared.destinationAddress
        
        SingleTonClass.shared.sourceLat = sourceLat
        SingleTonClass.shared.sourceLong = sourceLong
        SingleTonClass.shared.sourceAddress = sourceAddress
        
        if SingleTonClass.shared.sourceAddress != ""{
            txtPickUpLocation.text = SingleTonClass.shared.currentAddress
        }else{
            txtPickUpLocation.text = ""
        }
        
        if SingleTonClass.shared.destinationAddress != ""{
            txtDropLocation.text = SingleTonClass.shared.destinationAddress
        }else{
            txtDropLocation.text = ""
        }
        

        if SingleTonClass.shared.currentAddress != "" && SingleTonClass.shared.destinationAddress != ""{
            
            self.mapView.clear()
            self.loadMap(SourceLatitude: sourceLat, SourceLongitude: sourceLong, SourceAddress: sourceAddress, destinationLatitude: destinationLat, destinationLongitude: destinationLong, destinationAddress: destinationAddress)

            viewStartNavigation.alpha = 1.0
            startBtn.isEnabled = true
            self.fetchTravellingTime(soutLatitude: sourceLat, soutLongitude: sourceLong, destLatitude: destinationLat, destLongitude: destinationLong)
        }

        return true
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !Connectivity.isConnectedToInternet{
            self.showAlert()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
            
    @IBAction func onClickPickUpLocation(_ sender: Any) {
        let story:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
        let viewController: AutoPlaceLocationClassVC = story.instantiateViewController(withIdentifier: "AutoPlaceLocationClassVC") as! AutoPlaceLocationClassVC
        viewController.searchTitle = "PickUp Location"
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func onClickDropLocation(_ sender: Any) {
        let story:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
        let viewController: AutoPlaceLocationClassVC = story.instantiateViewController(withIdentifier: "AutoPlaceLocationClassVC") as! AutoPlaceLocationClassVC
        viewController.searchTitle = "Drop Location"
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    @IBAction func onClickStartNavigation(_ sender: Any) {
        let story:UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
        let viewController: NavigationClassVC = story.instantiateViewController(withIdentifier: "NavigationClassVC") as! NavigationClassVC
        viewController.duration = self.lblDuration.text!
        viewController.KM = self.lblKM.text!
        viewController.second = self.second
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
    //MARK: AutoPlaceDelegate
    func userSelectionLocation(){
        let sourceLat = SingleTonClass.shared.sourceLat
        let sourceLong = SingleTonClass.shared.sourceLong
        let sourceAddress = SingleTonClass.shared.sourceAddress
        let destinationLat = SingleTonClass.shared.destinationLat
        let destinationLong = SingleTonClass.shared.destinationLong
        let destinationAddress = SingleTonClass.shared.destinationAddress
        if SingleTonClass.shared.sourceAddress != ""{
            txtPickUpLocation.text = SingleTonClass.shared.sourceAddress
        }else{
            txtPickUpLocation.text = ""
        }
        
        if SingleTonClass.shared.destinationAddress != ""{
            txtDropLocation.text = SingleTonClass.shared.destinationAddress
        }else{
            txtDropLocation.text = ""
        }
        

        if SingleTonClass.shared.sourceAddress != "" && SingleTonClass.shared.destinationAddress != ""{
            
            self.mapView.clear()
            self.loadMap(SourceLatitude: sourceLat, SourceLongitude: sourceLong, SourceAddress: sourceAddress, destinationLatitude: destinationLat, destinationLongitude: destinationLong, destinationAddress: destinationAddress)

            viewStartNavigation.alpha = 1.0
            startBtn.isEnabled = true
            self.fetchTravellingTime(soutLatitude: sourceLat, soutLongitude: sourceLong, destLatitude: destinationLat, destLongitude: destinationLong)
        }
    }
    
    
    func updateLocationOnMap(lat:Double, Long: Double,address:String){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(Long))
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.title = address
        marker.map = mapView
        marker.icon = UIImage(named:"circle")
    }
}


//MAR: Load Map

extension LocationClassVC{
    func loadMap(SourceLatitude:String, SourceLongitude:String, SourceAddress:String, destinationLatitude:String, destinationLongitude:String, destinationAddress:String){
        
        let lat = (SourceLatitude as NSString).floatValue
        let long = (SourceLongitude as NSString).floatValue
        
        let latSecond = (destinationLatitude as NSString).floatValue
        let longSecond = (destinationLongitude as NSString).floatValue

//        let coordinate1 = CLLocation(latitude: CLLocationDegrees(latSecond), longitude: CLLocationDegrees(longSecond))
//        let coordinate0 = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
//        let distanceInMeters = coordinate0.distance(from: coordinate1)

//        print ("\(distanceInMeters/1000)")
//        let distance = Int(distanceInMeters/1000)
//        lblKM.text = "(" + String(describing:distance) + " Km)"
//        lblKM.isHidden = true
        
        
        marker.position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
        let degrees = 90.0
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.title = SourceAddress
        marker.rotation = degrees
        marker.map = mapView
        marker.icon = UIImage(named:"circle")

        
        markerOne.position = CLLocationCoordinate2DMake(CLLocationDegrees(latSecond), CLLocationDegrees(longSecond))
        markerOne.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        markerOne.title = destinationAddress
        markerOne.map = mapView
        markerOne.icon = UIImage(named:"pin_marker")

        let getMovedMapCenterOne: CLLocation =  CLLocation(latitude: CLLocationDegrees(latSecond), longitude: CLLocationDegrees(longSecond))
        let getMovedMapCenterTwo: CLLocation =  CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))

//        marker.rotation = getBearingBetweenTwoPoints1(point1: getMovedMapCenterOne, point2: getMovedMapCenterTwo)

        
        let origin = "\(lat),\(long)"
        let destination = "\(latSecond),\(longSecond)"
        
//        drawpath(positions: [CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long)),CLLocationCoordinate2DMake(CLLocationDegrees(latSecond), CLLocationDegrees(longSecond))])
        self.createPloyLine(origin: origin, destination: destination, lat: lat, long: long, latSecond: latSecond, longSecond: longSecond,sourceMarker: marker,destinationMarker:markerOne,positions: [CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long)),CLLocationCoordinate2DMake(CLLocationDegrees(latSecond), CLLocationDegrees(longSecond))])

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
extension LocationClassVC{
    
    func createPloyLine(origin: String, destination: String,lat:Float,long:Float,latSecond:Float,longSecond:Float,sourceMarker:GMSMarker,destinationMarker:GMSMarker,positions: [CLLocationCoordinate2D]){
        
        let origin = positions.first!
        let destination = positions.last!
        var wayPoints = ""
        for point in positions {
            wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)%7C\(point.latitude),\(point.longitude)"
        }
//        let positionString = wayPoints
//        waypointsArray = []
//        waypointsArray.append(positionString)

//            wayPoints = "optimize:true|" + wayPoints
            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0&mode=driving&waypoints=\(wayPoints)&alternateroutes=true&sensor=true"

            Alamofire.request(url,encoding: JSONEncoding.prettyPrinted ).responseJSON { response in
                print(response.request as Any)  // original URL request
                print(response.response as Any) // HTTP URL response
                print(response.data as Any)     // server data
                print(response.result as Any)   // result of response serialization


                do {
                    let json = try JSON(data: response.data!)
                    let routes = json["routes"].arrayValue

                    if routes.count == 0{
                        let path = GMSMutablePath()
                        path.add(CLLocationCoordinate2DMake(CLLocationDegrees(latSecond), CLLocationDegrees(longSecond)))
                        path.add(CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long)))
                        let rectangle = GMSPolyline(path: path)
                        rectangle.strokeWidth = 8
                        rectangle.strokeColor = UIColor.purple
                        rectangle.map = self.mapView
                    }else{
//                        for route in routes
//                        {
//                            let routeOverviewPolyline = route["overview_polyline"].dictionary
//                            let points = routeOverviewPolyline?["points"]?.stringValue
//                            let path = GMSPath.init(fromEncodedPath: points!)
//                            let polyline = GMSPolyline.init(path: path)
//                            polyline.strokeWidth = 8
//                            polyline.strokeColor = UIColor.purple
//                            polyline.map = self.mapView
//                        }
                        let json = try!  JSON(data: response.data!)
                        let routes = json["routes"][0]["overview_polyline"]["points"].stringValue

                        let path = GMSPath.init(fromEncodedPath: routes)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 8
                        polyline.strokeColor = UIColor.purple
                        polyline.map = self.mapView

                    }

//                    if self.waypointsArray.count > 0 {
//                        for waypoint in self.waypointsArray {
//                            let lat: Double = (waypoint.components(separatedBy: ",")[0] as NSString).doubleValue
//                            let lng: Double = (waypoint.components(separatedBy: ",")[1] as NSString).doubleValue
//                            let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
//                            marker.map = self.mapView
//                            marker.icon = GMSMarker.markerImage(with: UIColor.purple)
//
////                            markersArray.append(marker)
//                        }
//                    }

                    if let myLocation = self.mapView.myLocation {

                        let path = GMSMutablePath()
                        self.cooridnates2D = myLocation.coordinate
                        path.add(sourceMarker.position)
                        path.add(destinationMarker.position)

                        let bounds = GMSCoordinateBounds(path: path)
                        let update = GMSCameraUpdate.fit(bounds, withPadding: 40.0)
                        self.mapView.moveCamera(update)

                    }
                    

                } catch _ {

                }
            }
        }
}


extension LocationClassVC{
    func fetchTravellingTime(soutLatitude: String,soutLongitude: String,destLatitude: String,destLongitude: String){
        let urlString  = String(format:"https://maps.googleapis.com/maps/api/directions/json?origin=%@,%@&destination=%@,%@&alternatives=%@&mode=%@&key=%@",soutLatitude,soutLongitude,destLatitude,destLongitude,"true","driving","AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0")
        let request = URLRequest(url: URL(string: urlString)!)
        
        let session = URLSession.shared
        let task = session.dataTask(with:request,completionHandler:{(d,response,error)in
            do{
                if let data = d{
                    do{

                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as! NSDictionary

                        let data = jsonResult as? [String:Any] ?? [:]
                        let status = data["status"] as? String ?? ""
                        if status == "OK"{
                            let routes = data["routes"] as? [AnyObject] ?? []
                            let legs = routes[0]["legs"] as? [AnyObject] ?? []
                            let distance = legs[0]["distance"] as? [String:Any] ?? [:]
                            let distanceValue = distance["text"] as? String ?? ""
                            let duration = legs[0]["duration"] as? [String:Any] ?? [:]
                            let durationValue = duration["text"] as? String ?? ""
                            let durationSecond = duration["value"] as? Int ?? 0
                            DispatchQueue.main.async {
                                self.second = durationSecond
                                self.lblDuration.text = durationValue
                                self.lblKM.text = "(" + distanceValue + ")"
                                self.lblKM.isHidden = false
                                self.lblDuration.isHidden = false
                            }
                        }
                } catch
                {
                    self.lblDuration.text = ""
                    self.lblKM.text = ""
                    self.lblKM.isHidden = true
                    self.lblDuration.isHidden = true
                }
            }
        }
    })
    task.resume()
    }
}


extension LocationClassVC{
    
        func drawpath(positions: [CLLocationCoordinate2D]) {

        let origin = positions.first!
        let destination = positions.last!
        var wayPoints = ""
        for point in positions {
            wayPoints = wayPoints.count == 0 ? "\(point.latitude),\(point.longitude)" : "\(wayPoints)%7C\(point.latitude),\(point.longitude)"
        }

            let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=driving&waypoints=\(wayPoints)&key=AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0"
        Alamofire.request(url).responseJSON { response in

            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization

            let json = try!  JSON(data: response.data!)
            let routes = json["routes"][0]["overview_polyline"]["points"].stringValue

            let path = GMSPath.init(fromEncodedPath: routes)
            let polyline = GMSPolyline.init(path: path)
            polyline.strokeWidth = 8
            polyline.strokeColor = UIColor.purple
            polyline.map = self.mapView
            
//            if let myLocation = self.mapView.myLocation {
//
//                let path = GMSMutablePath()
//                self.cooridnates2D = myLocation.coordinate
//                path.add(self.marker.position)
//                path.add(self.markerOne.position)
//
//                let bounds = GMSCoordinateBounds(path: path)
//                let update = GMSCameraUpdate.fit(bounds, withPadding: 40.0)
//                self.mapView.moveCamera(update)
//
//            }

        }


    }

}


