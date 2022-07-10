//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.

import UIKit
import JGProgressHUD
class NewConversationViewController: UIViewController {
    //MARK: - vars
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String:String]]()
    private var results = [[String:String]]()
    private var hasFetched = false
    public var completion: (([String:String]) -> (Void))?
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
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancle", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
        setUpTableView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLable.frame = CGRect(x: view.width / 4, y: (view.height - 200) / 2, width: view.width / 2, height: 200)
    }
    //MARK: - private functions
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    @objc func dismissSelf(){
        dismiss(animated: true,completion: nil)
    }
}
//MARK: - uitableViewDelegate
extension NewConversationViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targerUserData = results[indexPath.row]
        dismiss(animated: true,completion: { [weak self] in
            self?.completion?(targerUserData)
        })
    }
}
//MARK: - UISearchBarDelegate
extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text , !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        self.searchUser(query: text)
    }
    ///funcs for search bar result (filter users)
    func searchUser(query: String){
        //check if array has firebase results
        if hasFetched{
            // if does: filter
            filterUser(with: query)
        }else{
            // if not ,fetch then filter
            DataBaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    print("userCollection is \(userCollection)")
                    self?.users = userCollection
                    self?.filterUser(with: query)
                case .failure(let error):
                    print("failed to get users \(error)")
                }
            }
        }
    }
    func filterUser(with term: String){
        guard hasFetched else{
            return
        }
        self.spinner.dismiss()
        let results: [[String:String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        updateUI()
        
    }
    func updateUI(){
        if results.isEmpty{
            self.noResultLable.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.noResultLable.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
