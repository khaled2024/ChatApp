//
//  ViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import Firebase
import JGProgressHUD
class ConversationsViewController: UIViewController {
    //MARK: - Vars
    private let spinner = JGProgressHUD(style: .dark)
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    private let noConversationLable: UILabel = {
       let lable = UILabel()
        lable.text = "No Conversations!"
        lable.textAlignment = .center
        lable.textColor = .gray
        lable.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        lable.isHidden = true
        return lable
    }()
    //MARK: - lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noConversationLable)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(barBtnTapped))
        setUpTableView()
        fetchConversations()
    }
    @objc func barBtnTapped(){
        let vc = NewConversationViewController()
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        validateAuth()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    //MARK: - private func
    private func fetchConversations(){
        tableView.isHidden = false
    }
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
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
//MARK: - Extensions(TableView)
extension ConversationsViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "khaled"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = "khaled"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
        
}
