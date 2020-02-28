//
//  SignUpViewController.swift
//  nibm-events
//
//  Created by Aravinda Rathnayake on 2/23/20.
//  Copyright © 2020 Aravinda Rathnayake. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var txtFirstName: NETextField!
    @IBOutlet weak var txtLastName: NETextField!
    @IBOutlet weak var txtEmail: NETextField!
    @IBOutlet weak var txtPassword: NETextField!
    @IBOutlet weak var txtConfirmPassword: NETextField!
    @IBOutlet weak var txtContactNumber: NETextField!
    @IBOutlet weak var txtBatch: NETextField!
    @IBOutlet weak var txtFacebookIdentifier: NETextField!
    
    @IBOutlet weak var btnSignUp: NEButton!

    @IBOutlet weak var cbAgreement: NECustomSwipButton!

    var alert: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureStyles()
    }

    private func configureStyles() {
        self.txtFirstName.setLeftPaddingPoints(5)
        self.txtFirstName.setRightPaddingPoints(5)

        self.txtLastName.setLeftPaddingPoints(5)
        self.txtLastName.setRightPaddingPoints(5)

        self.txtEmail.setLeftPaddingPoints(5)
        self.txtEmail.setRightPaddingPoints(5)

        self.txtPassword.setLeftPaddingPoints(5)
        self.txtPassword.setRightPaddingPoints(5)

        self.txtConfirmPassword.setLeftPaddingPoints(5)
        self.txtConfirmPassword.setRightPaddingPoints(5)

        self.txtContactNumber.setLeftPaddingPoints(5)
        self.txtContactNumber.setRightPaddingPoints(5)
        
        self.txtBatch.setLeftPaddingPoints(5)
        self.txtBatch.setRightPaddingPoints(5)

        self.txtFacebookIdentifier.setLeftPaddingPoints(5)
        self.txtFacebookIdentifier.setRightPaddingPoints(5)
    }

    @IBAction func onSignIn(_ sender: NEButton) {
        self.transitionToSignIn()
    }

    @IBAction func onSignUp(_ sender: NEButton) {
        var fields: [String: NETextField] = [:]
        var fieldErrors = [String: String]()

        // TODO: Refer usage comment
        let isChecked = !cbAgreement.isChecked

        fields = [
            "First Name": txtFirstName,
            "Last Name": txtLastName,
            "Email": txtEmail,
            "Password": txtPassword,
            "Contact Number": txtContactNumber,
            "Batch": txtBatch,
            "Facebook Identifier": txtFacebookIdentifier
        ]

        for (type, field) in fields {
            if type == "Password" {
                let (valid, message) = FieldValidator.validate(type: type, textField: field, optionalField: txtConfirmPassword)
                if (!valid ) {
                    fieldErrors.updateValue(message, forKey: type)
                }
            } else {
                let (valid, message) = FieldValidator.validate(type: type, textField: field)
                if (!valid) {
                    fieldErrors.updateValue(message, forKey: type)
                }
            }
        }

        if !fieldErrors.isEmpty {
            alert = NotificationManager.sharedInstance.showAlert(
                header: "Registration Failed",
                body: "The following \(fieldErrors.values.joined(separator: ", ")) field(s) are missing or invalid.", action: "Okay")

            self.present(alert, animated: true, completion: nil)

            return
        }

        // FIXME: cbAgreement isChecked method returns wrong state of the checkbox
        if isChecked {
            alert = NotificationManager.sharedInstance.showAlert(
                header: "Registration Failed",
                body: "Please read our privacy policy and agree to the terms and conditions.", action: "Okay")

            self.present(alert, animated: true, completion: nil)

            return
        }

        self.btnSignUp.showLoading()

        AuthManager.sharedInstance.createUser(emailField: txtEmail, passwordField: txtPassword) {[weak self] (userData, error) in
            guard let `self` = self else { return }

            if (error != nil) {
                self.alert = NotificationManager.sharedInstance.showAlert(header: "Registration Failed", body: error!, action: "Okay")

                self.present(self.alert, animated: true, completion: nil)
            } else {
                let data: [String: String] = [
                    "uid": userData!.uid,
                    "firstName": self.txtFirstName.text!,
                    "lastName": self.txtLastName.text!,
                    "contactNumber": self.txtContactNumber.text!,
                    "batch": self.txtBatch.text!.uppercased(),
                    "facebookIdentifier": self.txtFacebookIdentifier.text!
                ]

                DatabaseManager.sharedInstance.insertDocument(collection: "users", data: data) {[weak self] (_ success, error) in
                    guard let `self` = self else { return }

                    if (error != nil) {
                        self.alert = NotificationManager.sharedInstance.showAlert(header: "Registration Failed", body: error!, action: "Okay")
                        self.present(self.alert, animated: true, completion: nil)

                        return
                    } else {
                        self.alert = NotificationManager.sharedInstance.showAlert(
                            header: "Registration Success",
                            body: "Registration is Successful, Please Sign In.", action: "Okay", handler: {(_: UIAlertAction!) in
                            self.transitionToSignIn()
                        })
                        self.present(self.alert, animated: true, completion: nil)
                    }
                }
            }
            self.btnSignUp.hideLoading()
        }
    }

    private func transitionToSignIn() {
        DispatchQueue.main.async {
            TransitionManager.sharedInstance.transitionSegue(sender: self, identifier: "signUpToSignIn")
        }
    }
}
