//
//  AuthBioMetricsBlockedViewController.swift
//  nibm-events
//
//  Created by Aravinda Rathnayake on 2/24/20.
//  Copyright © 2020 Aravinda Rathnayake. All rights reserved.
//

import UIKit

class AuthBioMetricsBlockedViewController: UIViewController {
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnBioMetric: UIButton!
    
    var bioMetricType = ""

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setBioMetricsLable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onReAuthenticate(_ sender: UIButton) {
        isAuthorized()
    }

    private func setBioMetricsLable() {
        self.btnBioMetric.setTitle(self.bioMetricType, for: .normal)
        self.lblDescription.text = "Unlock with \(self.bioMetricType) to open NIBM Events"
    }

    private func isAuthorized() {
        AuthManager.sharedInstance.isAuthorized {[weak self] (_ success, error) in
            guard let `self` = self else { return }

            if (error == nil) {
                self.canPerformBioMetricsVerification()
            }
        }
    }

    private func canPerformBioMetricsVerification() {
        self.blurBackground()
        AuthManager.sharedInstance.authWithBioMetrics {[weak self] (_ bioMetricType, _ success, error) in
            guard let `self` = self else { return }

            if (error == nil) {
                self.transitionToHome()
            }
            self.unBlurBackground()
        }
    }
    
    private func blurBackground() {
        DispatchQueue.main.async {
            UIEffects.blur(context: self.view)
        }
    }
    
    private func unBlurBackground() {
        DispatchQueue.main.async {
            UIEffects.removeBlur(context: self.view)
        }
    }

    private func transitionToHome() {
        DispatchQueue.main.async {
            TransitionManager.sharedInstance.transitionSegue(sender: self, identifier: "authBMBlockedToHome")
        }
    }
}