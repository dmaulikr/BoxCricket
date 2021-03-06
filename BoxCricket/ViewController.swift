//
//  ViewController.swift
//  BoxCricket
//
//  Created by Fnu, Rohit on 11/2/16.
//  Copyright © 2016 Fnu, Rohit. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID

class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var rememeberMeButton: UIButton!
    
    var rememberMe = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        FIRMessaging.messaging().subscribe(toTopic: "/topics/news")
        
        let deviceVersion = UIDevice.current.systemVersion
        print("iOS \(deviceVersion)")
        
       
        

        if rememberMe == true {
            readUsername()
        } else {
            rememeberMeButton.setImage(UIImage(named: "Unchecked Circle Filled-50.png"), for: UIControlState.normal)

        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            readUsername()

        
        
        
    }
    
    func readUsername() {

        let prefs = UserDefaults.standard
        
        if let nameUser = prefs.string(forKey: "userName"){
            rememeberMeButton.setImage(UIImage(named: "Checked Filled-50.png"), for: UIControlState.normal)
            usernameTextField.text = nameUser
            
            print("The user has a city defined: " + nameUser)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func sign_TouchUpInside(_ sender: Any)
    {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100) // CGFloat, Double, Int
        
        let actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: rect) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        view.addSubview(actInd)
        actInd.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        guard let email = usernameTextField.text, let password = passwordTextField.text else { return }
       
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                actInd.stopAnimating()
                self.view.isUserInteractionEnabled = true

                return
            }
            self.signedIn(user!)
            self.view.isUserInteractionEnabled = true

            actInd.stopAnimating()
        }
        
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func signUp_TouchUpInside(_ sender: Any) {
        guard let email = usernameTextField.text, let password = passwordTextField.text else { return }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.setDisplayName(user!)
        }
    }
    
    func setDisplayName(_ user: FIRUser?) {
        let changeRequest = user?.profileChangeRequest()
        changeRequest?.displayName = user?.email!.components(separatedBy: "@")[0]
        changeRequest?.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func signedIn(_ user: FIRUser?) {
        MeasurementHelper.sendLoginEvent()
        
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.photoURL = user?.photoURL
        AppState.sharedInstance.signedIn = true
        let notificationName = Notification.Name(rawValue: Constants.NotificationKeys.SignedIn)
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        performSegue(withIdentifier: Constants.Segues.SignInToFp, sender: nil)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func activityIndicatorDisplay() {
        
    }
    
    @IBAction func rememberMeButton_TouchUpInside(_ sender: Any) {
        
        if (rememberMe == true) {
            rememberMe = false

            rememeberMeButton.setImage(UIImage(named: "Unchecked Circle Filled-50.png"), for: UIControlState.normal)

            let prefs = UserDefaults.standard
            prefs.removeObject(forKey: "userName")

            
        } else {
            rememberMe = true
            
            rememeberMeButton.setImage(UIImage(named: "Checked Filled-50.png"), for: UIControlState.normal)
            let prefs = UserDefaults.standard

            prefs.setValue(usernameTextField.text, forKey: "userName")

        }

    }
}

