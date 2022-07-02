//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import JGProgressHUD
class NewConversationViewController: UIViewController {

    //MARK: - vars
    private let spinner = JGProgressHUD()
    private var searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search for user.."
        return searchBar
    }()
    private let tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = false
        return tableView
    }()
    private let noResultLable: UILabel = {
       let lable = UILabel()
        lable.text = "No Results!"
        lable.textAlignment = .center
        lable.textColor = .gray
        lable.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        lable.isHidden = true
        return lable
    }()
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(noResultLable)
        setUpTableView()
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancle", style: .done, target: self, action: #selector(cancleBtnTapped))
        searchBar.becomeFirstResponder()
        setUpTableView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    //MARK: - private func
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    @objc func cancleBtnTapped(){
        dismiss(animated: true,completion: nil)
    }
}
//MARK: - uitableViewDelegate
extension NewConversationViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Amr"
        return cell
    }
    
    
}
//MARK: - UISearchBarDelegate
extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
