//
//  ViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import Firebase
import JGProgressHUD

struct Conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}
struct LatestMessage{
    let date: String
    let text: String
    let isread: Bool
}
class ConversationsViewController: UIViewController {
    //MARK: - Vars
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(conversationTableViewCell.self, forCellReuseIdentifier: conversationTableViewCell.identifier)
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
        startListeningConversations()
    }
    @objc func barBtnTapped(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
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
    private func startListeningConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DataBaseManager.safeEmail(emailAddress: email)
        DataBaseManager.shared.getAllConversation(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else{
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to get conv \(error)")
            }
        }
    }
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
    private func createNewConversation(result: [String:String]){
        guard let name = result["name"] , let email = result["safeEmail"] else{
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        
    }
}
//MARK: - Extensions(TableView)
extension ConversationsViewController: UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: conversationTableViewCell.identifier,for: indexPath) as! conversationTableViewCell
        let model = conversations[indexPath.row]
        cell.configure(with: model)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
