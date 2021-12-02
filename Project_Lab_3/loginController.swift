//
//  loginController.swift
//  first_draft
//
//
import UIKit
import Foundation
//
enum DownloadError: Error{
    case NotOK
    case JSONDecoderError

}

class loginController: UIViewController{
    
    //A UITextField Object is created for filling in the email and password fields
   
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //A UILabel object is created, hidden and only displays if the user enters the wrong password
    @IBOutlet weak var invalidCredentialsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.text = ""
        passwordField.text = ""
        invalidCredentialsLabel.text = ""
        configureTextFields()
        navigationItem.backButtonTitle = "Log Out"
    }
    
    
    //The user ID which is a number that uniquely identifies all users is needed for retrieving user data. User ID is generated in the "getUser" function below. Using the Authorization token from "usID:String" after it is computed from the "getData" function.
    //The username is also a parameter passed as "user:String" which is computed in the "getData" function and compared to all users present in the database returned as a JSON to ascertain which userID belongs to the current user.
    func getUser(usID:String,user:String) async throws -> (Int){
        //This converts the URL string to a URL that is used to make a URL request.
        let Url = URL(string: "????")
        
        //A variable that will store the UserID is created and set to -1.
        var ID:Int!
        ID = -1
        
        //A variable that is used for counting the user index in the databse based on username.
        //The variable is set to 0
        var index:Int!
        index = 0
        
        //A URL request is created
        var request = URLRequest(url: Url!)

        //The httpMethod is set as a GET
        request.httpMethod = "GET"
        //The required header value "authToken" is set to contain the authorization token stored in "usID"
        request.setValue(usID, forHTTPHeaderField: "authToken")
        
        //A task with a URL Session is created with the URL request "request" with three resulting variables, data, response and error. Data contains the data gotten as a JSON from the database, response stores the status code with a "200" meaning the URL request was successful and error is thrown if there is any error.
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            //"as? HTTPURLResponse" allows response to return the status code.
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            do{
                //The JSON data is decoded into the ResultItem dictionary format
                let Repondres = try JSONDecoder().decode([ResultItem].self, from: data!)
                
                //The current username is compared to all users in the database and index is incremented
                while(Repondres[index].username != user)
                {
                    index+=1
                }
                
                //When the user is found the index is used to identify the userID.
                //This set to ID.
                ID = Repondres[index].userId

            }catch{
                //else an error is printed
                print(error.localizedDescription)
            }
            
        }
        //this activates the task
        task.resume()
        do{
            sleep(1)
        }
        //ID is returned to the continueTapped IBAction.
        //ID is either -1 or the correct UserID.
        //-1 would mean the "getUser" function was not successfully executed.
        return (ID)
        
        
    }
    
    //This generates validation credentials for Authentication and Refresh tokens.
    //Also comes with a boolean that stores response from the API.
    //If boolean is true, then user credentials are good and the user successfully signed in.
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

    @IBAction public func continueTapped(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let username = emailField.text!
        let password = passwordField.text!
        //permanent contains the string format concatenated with the username and password to make requests to the API
        let permanent = "????"
        let permanentUsername = permanent+username
        let url = permanentUsername+"&password="+password
        
        guard let OptionsmenuController = mainStoryboard.instantiateViewController(withIdentifier: "optionsMenuController") as? optionsMenuController else{
            return
        }
        async{
            //this calls the getData function which returns a boolean for completion and two strings:the authentication and refresh tokens.
            let userCheck = try await getData(url: url)
            async{
                //this calls the getUser function which returns the userID.
                let userID = try await getUser(usID: userCheck.1,user: username)
                do{
                    sleep(1)
                }
                //A variable containing the boolean for completion, the authentication token, the refresh token and the userID is created.
                var userInfo = (userCheck.0, userCheck.1, userCheck.2, userID)
                //This variable is set to the "UserInfo" variable in the options menu controller
                OptionsmenuController.UserInfo = userInfo

                //If the email field and password field contain the right credentials the user is able to move onto the next scene through the instantiated navigation controller
                if(userID == -1)//This checks if the userID was retrieved correctly
                {
                    invalidCredentialsLabel.text  = "Try logging in again!"
                }
                else if(userCheck.0 == true ){
                    emailField.text = nil
                    passwordField.text = nil
                    do{
                        sleep(1)
                    }
                    navigationController?.pushViewController(OptionsmenuController, animated: true)
                }
                //else the invalid credentials label is dispalyed
                else{
                    invalidCredentialsLabel.text  = "Enter correct username and password"
                }
            }
            
            
            
    }
}
    
    //the extension below allows the keyboard to be dismissed on user tap anywhere on the screen in conjunction with the handle tap objc function
    private func configureTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loginController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    //This sets the textfields up
    private func configureTextFields(){
        emailField.delegate = self
        passwordField.delegate = self
    }
    @objc func handleTap(){
        print("Handle tap was called")
        view.endEditing(true)
    }
    //When the continue button is tapped, this function is called
    
    //The
    @IBAction func signUpTapped(_ sender: Any) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let SignupController = mainStoryboard.instantiateViewController(withIdentifier: "signupController") as? signupController else{
            return
        }
        
        let url = "?????????"//This would contain the administrator url. This allows the creation of new users.
        async{
            let createVerification = try await getData(url: url)
            //The Authentication and Refresh Tokens are passed on to the next view with the variable "okMoveDataHere" in the "SignupController"
            SignupController.okMoveDataHere = (createVerification.1,createVerification.2)
        }
        
        do{
            sleep(2)
        }
        //Below pushes the screen to the SignUp screen
        navigationController?.pushViewController(SignupController, animated: true)
        
        
    }
    
}
//The dictionary that the getData response is decoded into
struct Result:Codable {
    let authToken: String
    let refreshToken: String
}
//The dictionary that the getUser response is decoded into
struct ResultItem : Codable {
    var userId: Int
    var username: String
    var hashedPassword: String
    var firstName: String
    var lastName: String
    var activeFlag: Bool
}

//the extension below allows the keyboard to be dismissed on user tap anywhere on the screen
extension loginController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

