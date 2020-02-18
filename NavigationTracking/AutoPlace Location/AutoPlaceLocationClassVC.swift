//
//  AutoPlaceLocationClassVC.swift
//  NavigationTracking
//
//  Created by Lokesh on 16/02/20.
//  Copyright © 2020 Lokesh. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

protocol AutoPlaceDelegate:class {
    func userSelectionLocation()
}

class AutoPlaceLocationClassVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    var searchResults : [[String:Any]] = []
    var searchTitle: String = ""
    weak var delegate: AutoPlaceDelegate?

    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 50
        tableView.estimatedRowHeight = UITableView.automaticDimension
        self.txtSearch.becomeFirstResponder()
        self.txtSearch.placeholder = searchTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navBarTitle.title = searchTitle
    }
    
    
    @IBAction func onClickCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextField Delegate's
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        addToolBar(textField: textField)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor .blue
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.donePressed))
//        let cancelButton = UIBarButtonItem(title: "Search Location", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed(){
        collapseKeyboard()
    }
    
    @objc func cancelPressed(){
        collapseKeyboard()
    }
    
    func collapseKeyboard(){
        self.txtSearch.resignFirstResponder()
    }
    
    // MARK: - TableView Delegate And Datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCellClass", for: indexPath) as! LocationCellClass
        
        cell.selectionStyle = UITableViewCell.SelectionStyle .none
        cell.backgroundColor = UIColor .white
        
        guard let locationDescription =  self.searchResults[indexPath.row]["description"] as? String, locationDescription != "" else {
            return cell
        }
        
        cell.lblLocationSearch.text = locationDescription
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if Connectivity.isConnectedToInternet{
            self.convertAddress(indexPath: indexPath)
        }else{
            self.showAlert()
        }
    }
    
    
    
    func convertAddress(indexPath: IndexPath){
    self.txtSearch.resignFirstResponder()
    let description: String = self.searchResults[indexPath.row]["description"] as? String ?? ""
        if searchTitle == "PickUp Location"{
            SingleTonClass.shared.sourceAddress = description
        }else{
            SingleTonClass.shared.destinationAddress = description
        }
        
    let tappedAddress:String = self.searchResults[indexPath.row]["place_id"] as? String ?? ""
    
    let urlpath = "https://maps.googleapis.com/maps/api/place/details/json?input=bar&placeid=\(tappedAddress)&key=AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    
    let url = URL(string: urlpath!)
    let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
        
        do {
            if data != nil{
                let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String:Any]
                
                let status:String = dic["status"] as? String ?? ""
                
                if status == "OK"{
                    let result:[String:Any] = dic["result"] as? [String:Any] ?? [:]
                    let geometry:[String:Any] = result["geometry"] as? [String:Any] ?? [:]
                    let location:[String:Any] = geometry["location"] as? [String:Any] ?? [:]
                    
                    let lat:Double = location["lat"] as? Double ?? 0.0
                    let lon:Double = location["lng"] as? Double ?? 0.0
                    
                    if self.searchTitle == "PickUp Location"{
                        SingleTonClass.shared.sourceLat = String(lat)
                        SingleTonClass.shared.sourceLong = String(lon)
                    }else{
                        SingleTonClass.shared.destinationLat = String(lat)
                        SingleTonClass.shared.destinationLong = String(lon)
                    }
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.delegate?.userSelectionLocation()
                        }
                    }
                    
                    }else{
                    
                }
            }
            
        }catch {
            print("Error")
        }
    }
        task.resume()
    
    }
        
    
    @IBAction func seachLocation(_ sender: Any) {
    if Connectivity.isConnectedToInternet{
        let currentLocation: String = "\(SingleTonClass.shared.lat),\(SingleTonClass.shared.long)"
        let urlpath = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(String(describing: self.txtSearch.text!))        &language=en&radius=5000&key=AIzaSyAiiV8oD6A6TIdODy0qwIQWG9n2Hxo-lK0&location=\(currentLocation)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlpath!)
        let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) -> Void in
            do {
                if data != nil{
                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! [String:Any]
                    
                    let status:String = dic["status"] as? String ?? ""
                    if status == "OK"{
                        self.searchResults = dic["predictions"] as? [[String:Any]] ?? []
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }else{
                        print("No Location Found")
                        DispatchQueue.main.async {
                            self.searchResults = []
                            self.tableView.reloadData()
                        }
                    }
                }
            }catch {
                print("Error")
            }
        }
        task.resume()
    }else{
        self.showAlert()
    }
}

}
