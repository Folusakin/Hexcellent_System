//
//  optionsMenuController.swift
//  first_draft
//
//  Created by Folusakin Abiola on 10/3/21.
//

import Foundation

import UIKit

class optionsMenuController: UIViewController{
    //The "UserInfo" variable contains the user credentials, completion boolean, authentication token, refresh token, User ID
    var UserInfo:(Bool, String, String, Int)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("This is userInfo:\(UserInfo!)")
    }
    //This function is linked to the "weekly tracking(kCal)" button and displays plot of weekly caloric intake
    @IBAction func dailyTapped(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        guard let DailyController = mainStoryboard.instantiateViewController(withIdentifier: "dailyController") as? dailyController else{
            return
        }
        async{
            //this calls the getData function which returns a boolean for completion and two strings:the authentication and refresh tokens.
            //The getData function is used to generate a new refresh and authtoken based on an administrator credential/URL everytime the screen loads
            
            let userCheck = try await getData(url: "????")
            UserInfo?.1 = userCheck.1
            UserInfo?.2 = userCheck.2
            DailyController.UserCredentials = UserInfo
            //The constant user check returns fresh credentials. The fresh credentails are set to "UserInfo" variable which is set to the "UserCredentials" variable in DailyController
            navigationController?.pushViewController(DailyController, animated: true)
            
        }
        
        
    }
    
    
    //This function is linked to the "weekly tracking(fl.Oz)" button and displays plot of weekly caloric intake
    @IBAction func weeklyTapped(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        //Below pushes the screen to the weekly logs screen itself using the navigation controller
        guard let WeeklyController = mainStoryboard.instantiateViewController(withIdentifier: "weeklyController") as? weeklyController else{
            return
        }
        async{
            //this calls the getData function which returns a boolean for completion and two strings:the authentication and refresh tokens.
            //The getData function is used to generate a new refresh and authtoken based on an administrator credential/URL everytime the screen loads
            let userCheck = try await getData(url: "????")
            UserInfo?.1 = userCheck.1
            UserInfo?.2 = userCheck.2
            //The constant user check returns fresh credentials. The fresh credentails are set to "UserInfo" variable which is set to the "UserCredentials" variable in WeeklyController
            WeeklyController.UserCredentials = UserInfo
            navigationController?.pushViewController(WeeklyController, animated: true)
            
        }
    }
    
    //This function is linked to the "log kCal and fl.Oz" button and executes when daily logs is tapped
    @IBAction func trackTapped(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        //Below pushes the screen to the track health screen itself using the navigation controller
        guard let TrackController = mainStoryboard.instantiateViewController(withIdentifier: "trackController") as? trackController else{
            return
        }
        async{
            //this calls the getData function which returns a boolean for completion and two strings:the authentication and refresh tokens.
            //The getData function is used to generate a new refresh and authtoken based on an administrator credential/URL everytime the screen loads
            let userCheck = try await getData(url: "????")
            UserInfo?.1 = userCheck.1
            UserInfo?.2 = userCheck.2
            TrackController.userInformation = UserInfo
            //The constant user check returns fresh credentials. The fresh credentails are set to "UserInfo" variable which is set to the "userInformation" variable in TrackController
            navigationController?.pushViewController(TrackController, animated: true)
            
        }
        
    }
    //This function is linked to the real-time data button and executes when daily logs is tapped
    @IBAction func realtimeTapped(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        //Below pushes the screen to the real-time data screen itself using the navigation controller
        guard let RealtimeController = mainStoryboard.instantiateViewController(withIdentifier: "realtimeController") as? realtimeController else{
            return
        }
        
        navigationController?.pushViewController(RealtimeController, animated: true)
    }
    
    func getData(url:String) async throws -> (Bool, String, String){
        
        //A variable that stores a boolean for the success case of "getData" is intialized to true. If it fails, it is set to false.
        var verifyUser: Bool
        verifyUser = true
        //An empty string is created for the authentication token
        var authenticate = ""
        //An empty string is created for the refresh token
        var refresh = ""
        //The URL string is converted into a URL
        guard let url = URL(string: url)
        //If it is inconvertible, the boolean variable "verifyUser" is set to false
        else{
            verifyUser=false
            throw DownloadError.NotOK
        }
        do{
            //A tuple containing data and response from the URLsession and input URL is created
            let (data, response) = try await URLSession.shared.data(from: url)
            guard
                //"response as? HTTPURLResponse" enables the statusCode response to be returned.
                
                let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200
                    //If status code is not 200, the boolean variable "verifyUser" is set to false
            else{
                print(response)
                verifyUser = false
                throw DownloadError.NotOK
            }
            //The data is decoded into the Result dictionary and if undecodable, the boolean variable "verifyUser" is set to false
            guard let decodedData = try? JSONDecoder().decode(Result.self, from: data)
            else{
                verifyUser = false
                throw DownloadError.JSONDecoderError
            }
            //The decoded data is set to constant "json"
            let json = decodedData
            //The authenticate and refresh variables intialized to "" are now assigned the authentication and refresh tokens from the decoded data
            authenticate = json.authToken
            refresh = json.refreshToken
        
        }catch{
            //If the "do{" fails the boolean variable "verifyUser" is set to false
            print(error.localizedDescription)
            verifyUser = false
        }
        //The success boolean, authentication token and refresh tokens are returned
        return (verifyUser,authenticate,refresh)

    }

}
