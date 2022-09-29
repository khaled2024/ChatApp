//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import SwiftUI
class ProfileViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    let data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    //MARK: - func
    private func createTableHeader()-> UIView?{
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DataBaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/"+fileName
        print(email)
        let userName = UserDefaults.standard.value(forKey: "name")as? String
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 270))
        headerView.backgroundColor = .white
        let imageView = UIImageView(frame: CGRect(x: (view.width-150) / 2, y: 30, width: 150, height: 150))
        let profileName = UILabel(frame: CGRect(x: (view.width-200) / 2, y: imageView.bottom + 20, width: 200, height: 30))
        // image
        headerView.addSubview(imageView)
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .white
        imageView.layer.borderWidth = 3.0
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        //lable
        headerView.addSubview(profileName)
        profileName.text = userName
        profileName.textAlignment = .center
        profileName.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        
        StorageManager.shared.downloadURL(for: path) {[weak self] result in
            switch result{
            case .success(let url):
                self?.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("failed to get downloaded profile url.! \(error)")
            }
        }
        return headerView
    }
    private func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data , error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
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
