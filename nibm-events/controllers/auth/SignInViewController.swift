//
//  SignInViewController.swift
//  nibm-events
//
//  Created by Aravinda Rathnayake on 2/23/20.
//  Copyright © 2020 Aravinda Rathnayake. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var txtEmail: NETextField!
    @IBOutlet weak var txtPassword: NETextField!
    
    @IBOutlet weak var btnSignIn: NEButton!
    
    var alert: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStyles()
    }
    
    private func configureStyles() {
        self.txtEmail.setLeftPaddingPoints(5)
        self.txtEmail.setRightPaddingPoints(5)
        
        self.txtPassword.setLeftPaddingPoints(5)
        self.txtPassword.setRightPaddingPoints(5)
    }
    
    @IBAction func onSignIn(_ sender: NEButton) {
        var fields: Dictionary<String, NETextField> = [:]
        var fieldErrors = [String: String]()
        
        let fieldValidator: FieldValidator = FieldValidator()
        let authManager: AuthManager = AuthManager()
        
        fields = [
            "Email": txtEmail,
            "Password": txtPassword
        ]
        
        for (type, field) in fields {
            let (valid, message) = fieldValidator.validate(type: type, textField: field)
            if (!valid) {
                fieldErrors.updateValue(message, forKey: type)
            }
        }
        
        if fieldErrors.count > 0 {
            self.alert = NotificationManager.showAlert(header: "Sign In Failed", body: "The following \(fieldErrors.values.joined(separator: ", ")) field(s) are invalid.", action: "Okay")
            
            self.present(self.alert, animated: true, completion: nil)
            
            return
        }
        
        self.btnSignIn.showLoading()
        
        authManager.signIn(emailField: txtEmail, passwordField: txtPassword) {[weak self] (success, error) in
            guard let `self` = self else { return }
            
            if (error != nil) {
                self.alert = NotificationManager.showAlert(header: "Sign In Failed", body: error!, action: "Okay")
                self.present(self.alert, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(true, forKey: "isAuthorized")
                self.transitionToHome()
            }
            
            self.btnSignIn.hideLoading()
        }
    }
    
    private func transitionToHome() {
        DispatchQueue.main.async {
            TransitionManager.pushViewController(storyBoardName: "Home", vcIdentifier: "HomeVC", context: self.navigationController!)
        }
    }
}
