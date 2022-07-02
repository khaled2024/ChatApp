//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
class ProfileViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }
}
//MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionSheet = UIAlertController(title: "Are you sure you want to Log out.!", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [weak self]_ in
            guard let strongSelf = self else{return}
            // logout from facebook
            FBSDKLoginKit.LoginManager().logOut()
            // logout from google
//            GIDSignIn.sharedInstance().signOut()
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
            }catch{
                print(error.localizedDescription)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true)
    }
    
}
