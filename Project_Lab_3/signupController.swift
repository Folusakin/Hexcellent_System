//This is the controller that allows for new user signup
//  signupController.swift
//  first_draft
//
//  Created by Folusakin Abiola on 10/21/21.
//

import Foundation

import UIKit

class signupController: UIViewController{
    //okMoveDataHere is set in the logInController and contains the authentication and refresh token generated from administrator credentials
    var okMoveDataHere:(String,String)?

    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var verifypasswordField: UITextField!

    @IBOutlet weak var emptyFields: UILabel!
    @IBOutlet weak var creationResult: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    @IBAction func continueTapped(_ sender: Any) {
        var authToken:String!
        var statusCode: Int!
        //an instance of the storyboard and options menu controller are created which enables the program to animate the optionsMenuController linked screen
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let OptionsmenuController = mainStoryboard.instantiateViewController(withIdentifier: "optionsMenuController") as? optionsMenuController else{
            return
        }
        //This checks that none of the textfields are empty
        if((firstnameField.text!.isEmpty || lastnameField.text!.isEmpty || usernameField.text!.isEmpty ||   passwordField.text!.isEmpty||verifypasswordField.text!.isEmpty)==true)
        {
            //If any of the text fields are not empty a label informs the user to fill out all fields
            emptyFields.text = "All the fields should be filled"
        }
        //Also check that the user inputted password matches the verify password
        else if(passwordField.text != verifypasswordField.text){
            emptyFields.text = "Make sure the passwords match"
        }
        
        else{
            //The string url that is able to the request to the database is converted to a string
            guard let url = URL(string: "???") else {return}
            print("Making api call...")
            
            //The URL request is created from the URL
            var request = URLRequest(url:url)
            
            //The request method is set to a POST and two header fields are set. The first is the authorization token and the other is the content type.
            request.httpMethod = "POST"
            authToken = okMoveDataHere!.0
            request.setValue(authToken, forHTTPHeaderField: "authToken")
            request.setValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
            
            //The body for the POST request is created same as a dictionary with requisite variables
            let body: [String: AnyHashable] = [
                "username":usernameField.text,
                "password":passwordField.text,
                "firstName":firstnameField.text,
                "lastName":lastnameField.text
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
                    print("SUCCESS: \(httpResponse.statusCode)")
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
            //Check if the status code is 200 signifying successful completion of the request
            let httpResponse = task.response as? HTTPURLResponse
            statusCode = httpResponse?.statusCode
            print(statusCode as Any)
            if(statusCode == 200){
                do{
                    sleep(1)
                }
                creationResult.text = "Account successfully created!"
                do{
                    sleep(4)
                }
                navigationController?.pushViewController(OptionsmenuController, animated: true)
                
            }
            //If the request was not successfully made, ask the user to try signing up later
            else{
                creationResult.textColor = UIColor.red
                creationResult.text = "Try signing up later!"
            }
        }
        
        
    }
    
}
