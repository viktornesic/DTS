//
//  SearchAgentsViewController.swift
//  DTS-iOS
//
//  Created by Viktor on 09/01/2017.
//  Copyright © 2017 Mac, LLC. All rights reserved.
//

import UIKit
import KVNProgress

class SearchAgentsViewController: UIViewController {

    @IBOutlet weak var tblSearchAgents: UITableView!
    @IBOutlet weak var btnSideMenu: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    var searchAgents: [AnyObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let revealController = revealViewController()
        revealController?.panGestureRecognizer().isEnabled = false
        revealController?.tapGestureRecognizer()
        self.btnSideMenu.addTarget(revealController, action: #selector(SWRevealViewController.rightRevealToggle(_:)), for: .touchUpInside)
        
        self.tblSearchAgents.dataSource = self
        self.tblSearchAgents.delegate = self
        
        self.tblSearchAgents.isHidden = true
        self.lblMessage.isHidden = true

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getSearchAgents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension SearchAgentsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchAgents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "agentCell", for: indexPath) as! SearchAgentTableViewCell
        let dictSearchAgent = self.searchAgents[indexPath.row] as! [String: AnyObject]
        
        cell.lblTitle.text = dictSearchAgent["name"] as? String
        cell.lblDescription.text = dictSearchAgent["last_execution"] as? String
        
        cell.selectionStyle = .none
        return cell
    }
}

extension SearchAgentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dictSearchAgent = self.searchAgents[indexPath.row] as! NSDictionary
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "editSearchAgentVC") as! EditSearchAgentViewController
        controller.dictSearchAgent = dictSearchAgent
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchAgentsViewController {
    func getSearchAgents() -> Void {
        var strURL = ""
        
        if UserDefaults.standard.object(forKey: "token") != nil {
            let token = UserDefaults.standard.object(forKey: "token") as! String
            strURL = ("\(APIConstants.BasePath)/api/getsearchagents?token=\(token)")
        }
        
        KVNProgress.show(withStatus: "Loading My Search")
        
        let url = URL(string: strURL)
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    DispatchQueue.main.async(execute: {
                        KVNProgress.dismiss()
                    })
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    let result = json as? NSDictionary
                    
                    let isSuccess = result!["success"] as! Bool
                    
                    if isSuccess == false {
                        
                        DispatchQueue.main.async(execute: {
                            KVNProgress.dismiss()
                            let _utils = Utils()
                            _utils.showOKAlert("Error:", message: result!["message"] as! String, controller: self, isActionRequired: false)
                        })
                        
                        return
                    }
                    
                    let allSearchAgents = result!["data"] as! [AnyObject]
                    
                    for searchAgent in allSearchAgents {
                        if let disabled = searchAgent["disabled"] as? Int {
                            if disabled == 0 {
                                self.searchAgents.append(searchAgent)
                            }
                        }
                    }
                    
                    //self.searchAgents = result!["data"] as! [AnyObject]
                    DispatchQueue.main.async(execute: {
                        if self.searchAgents.count > 0 {
                            self.tblSearchAgents.isHidden = false
                            self.lblMessage.isHidden = true
                        }
                        else {
                            self.tblSearchAgents.isHidden = true
                            self.lblMessage.isHidden = false
                        }
                        
                        self.tblSearchAgents.reloadData()
                    })
                    
                }
                catch {
                    
                }
            }
            else {
                DispatchQueue.main.async(execute: {
                    KVNProgress.dismiss()
                })
                Utils.showOKAlertRO("Error", message: (error?.localizedDescription)!, controller: self)
                
            }
        }.resume()
    }
}
