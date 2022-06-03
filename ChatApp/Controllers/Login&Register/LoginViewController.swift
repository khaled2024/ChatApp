//
//  LoginViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Vars&Outlets
    private let LoginScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let LogoImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let emailTF = UITextField()
        emailTF.placeholder = "Email Address"
        emailTF.autocapitalizationType = .none
        emailTF.autocorrectionType = .no
        emailTF.returnKeyType = .continue
        emailTF.layer.cornerRadius = 10
        emailTF.layer.borderColor = UIColor.lightGray.cgColor
        emailTF.layer.borderWidth = 1
        emailTF.font = .systemFont(ofSize: 18, weight: .regular)
        emailTF.keyboardType = .emailAddress
        emailTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 0))
        emailTF.leftViewMode = .always
        emailTF.backgroundColor = .white
        return emailTF
    }()
    private let passwordField: UITextField = {
        let passwordTF = UITextField()
        passwordTF.placeholder = "Password"
        passwordTF.autocapitalizationType = .none
        passwordTF.autocorrectionType = .no
        passwordTF.returnKeyType = .done
        passwordTF.layer.cornerRadius = 10
        passwordTF.layer.borderColor = UIColor.lightGray.cgColor
        passwordTF.layer.borderWidth = 1
        passwordTF.font = .systemFont(ofSize: 18, weight: .regular)
        passwordTF.keyboardType = .default
        passwordTF.isSecureTextEntry = true
        passwordTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordTF.leftViewMode = .always
        passwordTF.backgroundColor = .white
        return passwordTF
    }()
    private let loginBtn: UIButton = {
        let loginBtn = UIButton()
        loginBtn.setTitle("Log In", for: .normal)
        loginBtn.backgroundColor = #colorLiteral(red: 0.2629672885, green: 0.4878299236, blue: 0.7413980365, alpha: 1)
        loginBtn.layer.cornerRadius = 12
        loginBtn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        loginBtn.titleLabel?.textColor = .blue
        return loginBtn
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        let createAccountBtn = UIBarButtonItem(image: UIImage(named: "NewAccountImage"), style: .done, target: self, action: #selector(barBtnTapped))
        createAccountBtn.tintColor = #colorLiteral(red: 0.2629672885, green: 0.4878299236, blue: 0.7413980365, alpha: 1)
        navigationItem.rightBarButtonItem = createAccountBtn
        
        loginBtn.addTarget(self, action: #selector(loginDidTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        //add views
        view.addSubview(LoginScrollView)
        LoginScrollView.addSubview(LogoImageView)
        LoginScrollView.addSubview(emailField)
        LoginScrollView.addSubview(passwordField)
        LoginScrollView.addSubview(loginBtn)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LoginScrollView.frame = view.bounds
        let size = LoginScrollView.width / 3
        LogoImageView.frame = CGRect(x: (LoginScrollView.width - size) / 2, y: (view.height) / 8, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: LogoImageView.bottom + 50, width: LoginScrollView.width - 60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 20, width: LoginScrollView.width - 60, height: 50)
        loginBtn.frame = CGRect(x: 30 , y: passwordField.bottom + 20, width: LoginScrollView.width - 60, height: 50)
    }
    //MARK: - functions
    
    @objc func loginDidTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text , let password = passwordField.text , !password.isEmpty , !email.isEmpty , password.count >= 6 else{
            ErrorLoginAlert()
            return
        }
        print(email , password)
    }
    private func ErrorLoginAlert(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all information in Login fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: true)
    }
    @objc func barBtnTapped(){
        let vc = RegisterViewController()
        vc.title = "Register"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
//MARK: - extensions
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            self.passwordField.becomeFirstResponder()
        }else if textField == passwordField {
            self.loginDidTapped()
        }
        return true
    }
}
