//
//  ViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import Firebase
class ConversationsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validateAuth()
    }
    //MARK: - private func
    func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }else{
            print("conversations screen")
            self.modalTransitionStyle = .flipHorizontal
        }
    }
}

