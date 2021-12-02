//This controller is allows the user to input their calorie and water intake
//  trackController.swift
//  Project_Lab_3
//
//  Created by Folusakin Abiola on 11/9/21.
//

import Foundation

import UIKit

class trackController: UIViewController{
    
    //User credentials are assigned from the previous controller OptionsMenuController
    var userInformation:(Bool, String, String, Int)?
    
    @IBOutlet weak var caloriesField: UITextField!
    
    @IBOutlet weak var waterField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func enterTapped(_ sender: Any) {
        var statusCode: Int!
        //The string is converted to URL to be used to make request to the API
        guard let url = URL(string: "???") else {return}
        print("Making api call...")
        //A URL request is created from the URL
        var request = URLRequest(url:url)
       //The httpMethod is set to POST meaning the user gets to post things in the database
        request.httpMethod = "POST"
        //The authentication token and userId from the OptionsMenuCOntroller are assigned to the constants authToken and USERID respectively
        let authToken = userInformation?.1
        let USERID = userInformation?.3
        
        //The calories and water intake to be entered into the databse are retrieved from the textfields
        let getCalories = caloriesField.text
        let getWater = waterField.text
        //Two headers are needed to make this POST request: an authorization token header and content type header
        request.setValue(authToken, forHTTPHeaderField: "authToken")
        request.setValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        //The time, and date calculated by the Date() to be used when posting to the database
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date_Result = formatter.string(from: date)
        //The body for the POST request is created same as a dictionary with requisite variables
        let body: [String: AnyHashable] = [
            "userId":Int(USERID!),
            "entryDate":date_Result,
            "calories":Int(getCalories!),
            "waterOz":Int(getWater!)
        ]
        //the body constant is set to the httpBody
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        //A task is created with URLSession, using the URL request which returns the data, response from the databse(status code) and any errors
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data,let httpResponse = response as? HTTPURLResponse, error == nil else{
                return
            }
            do{
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                statusCode = httpResponse.statusCode
            }
            catch{
                print(error)
            }
        }
        //activate the task
        task.resume()
        do{
            sleep(1)
        }
        //Set the textfields back to nil after the POST request is executed
        caloriesField.text = nil
        waterField.text = nil
    }
    

}


