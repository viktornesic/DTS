//
//  DwollaAddressViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 10/02/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit

class DwollaAddressViewController: UIViewController {

    @IBOutlet weak var btnSideMenu: UIButton!
    @IBOutlet weak var txtAddress: AutoCompleteTextField!
    fileprivate var responseData:NSMutableData?
    fileprivate var dataTask:URLSessionDataTask?
    
    fileprivate let googleMapsKey = "AIzaSyCOd0Y4CQdO05VWv6k3wZwZvq9RkfMlFgE"
    fileprivate let baseURLString = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtAddress.delegate = self
        let revealController = revealViewController()
        revealController?.panGestureRecognizer()
        revealController?.tapGestureRecognizer()
        
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.txtAddress.becomeFirstResponder()
        
        configureTextField()
        handleTextFieldInterfaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DOBViewController") as! DOBViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension DwollaAddressViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DwollaAddressViewController {
    
    fileprivate func configureTextField(){
        txtAddress.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        txtAddress.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        txtAddress.autoCompleteCellHeight = 35.0
        txtAddress.maximumAutoCompleteCount = 20
        txtAddress.hidesWhenSelected = true
        txtAddress.hidesWhenEmpty = true
        txtAddress.enableAttributedText = true
        txtAddress.isFromMap = true
        //txtAddress.tag = 105
        txtAddress.delegate = self
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        txtAddress.autoCompleteAttributes = attributes
        txtAddress.placeholder = "Address"
        txtAddress.showCurrentLocation = nil
    }
    
    fileprivate func handleTextFieldInterfaces(){
        txtAddress.onTextChange = {[weak self] text in
            if !text.isEmpty{
                if let dataTask = self?.dataTask {
                    dataTask.cancel()
                }
                self?.fetchAutocompletePlaces(text)
            }
        }
        
        txtAddress.onSelect = {[weak self] text, indexpath in
            self?.txtAddress.resignFirstResponder()
            self?.txtAddress.text = text
        }
    }
    
    fileprivate func fetchAutocompletePlaces(_ keyword:String) {
        let urlString = "\(baseURLString)?key=\(googleMapsKey)&input=\(keyword)&components=country:usa"
        let s = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        s.addCharacters(in: "+&")
        if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: s as CharacterSet) {
            if let url = URL(string: encodedString) {
                let request = URLRequest(url: url)
                dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                    if let data = data{
                        
                        do{
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                            
                            if let status = result["status"] as? String{
                                if status == "OK"{
                                    if let predictions = result["predictions"] as? NSArray{
                                        var locations = [String]()
                                        for dict in predictions as! [NSDictionary]{
                                            let prediction = (dict["description"] as! String).replacingOccurrences(of: ", United States", with: "")
                                            locations.append(prediction)
                                        }
                                        DispatchQueue.main.async(execute: { () -> Void in
                                            self.txtAddress.autoCompleteStrings = locations
                                        })
                                        return
                                    }
                                }
                            }
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.txtAddress.autoCompleteStrings = nil
                            })
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                })
                dataTask?.resume()
            }
        }
    }
}
