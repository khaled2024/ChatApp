//
//  LoginViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import Firebase
import FBSDKLoginKit
import JGProgressHUD
class LoginViewController: UIViewController {
    
    //MARK: - Vars&Outlets
    private let spinner = JGProgressHUD(style: .dark)
    
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
    private let faceBookBtn = FBLoginButton()
    private var loginObserver: NSObjectProtocol?
    //    private let googleSignBtn = GIDSignInButton()
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] notification in
            guard let strongSelf = self else{
                return
            }
            strongSelf.navigationController?.dismiss(animated: true)
        })
        title = "Login"
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        let createAccountBtn = UIBarButtonItem(image: UIImage(named: "NewAccountImage"), style: .done, target: self, action: #selector(barBtnTapped))
        createAccountBtn.tintColor = #colorLiteral(red: 0.2629672885, green: 0.4878299236, blue: 0.7413980365, alpha: 1)
        navigationItem.rightBarButtonItem = createAccountBtn
        
        loginBtn.addTarget(self, action: #selector(loginDidTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        faceBookBtn.delegate = self
        //add views
        view.addSubview(LoginScrollView)
        LoginScrollView.addSubview(LogoImageView)
        LoginScrollView.addSubview(emailField)
        LoginScrollView.addSubview(passwordField)
        LoginScrollView.addSubview(loginBtn)
        LoginScrollView.addSubview(faceBookBtn)
        //LoginScrollView.addSubview(googleSignBtn)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LoginScrollView.frame = view.bounds
        let size = LoginScrollView.width / 3
        LogoImageView.frame = CGRect(x: (LoginScrollView.width - size) / 2, y: (view.height) / 8, width: size, height: size)
        emailField.frame = CGRect(x: 30, y: LogoImageView.bottom + 30, width: LoginScrollView.width - 60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 20, width: LoginScrollView.width - 60, height: 50)
        loginBtn.frame = CGRect(x: 30 , y: passwordField.bottom + 20, width: LoginScrollView.width - 60, height: 50)
        faceBookBtn.frame = CGRect(x: 30 , y: loginBtn.bottom + 20, width: LoginScrollView.width - 60, height: 50)
        faceBookBtn.layer.cornerRadius = 20
        //        googleSignBtn.frame = CGRect(x: 30 , y: faceBookBtn.bottom + 20, width: LoginScrollView.width - 60, height: 50)
        
    }
    //MARK: - functions
    // login tapped
    @objc func loginDidTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text , let password = passwordField.text , !password.isEmpty , !email.isEmpty , password.count >= 6 else{
            ErrorLoginAlert()
            return
        }
        spinner.show(in: view)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {[weak self] authResult, error in
            guard let strongSelf = self else{return}
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult , error == nil else{
                print("Error for Login with email : \(email) because \(error?.localizedDescription ?? "")")
                strongSelf.ErrorLoginAlert(message: "Please check your Email & Password")
                return
            }
            let user = result.user
            // to get the first name and last name from db
            let safeEmail = DataBaseManager.safeEmail(emailAddress: email)
            DataBaseManager.shared.getDataFor(path: safeEmail) { result in
                switch result {
                case .failure(let error):
                    print("failed to get data \(error)")
                case .success(let data):
                    guard let userData = data as? [String:Any], let firstName = userData["firstName"] , let lastName = userData["lastName"] else{
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    print("\(firstName) \(lastName)")
                }
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            print("Login \(user)")
        }
    }
    // error alert pop Up
    private func ErrorLoginAlert(message: String = "Please enter all information in Login fields"){
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
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
extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operations
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("user failed to log in with facebook")
            return
        }
        let facbookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        facbookRequest.start(completionHandler: {_,result,error in
            guard let result = result as? [String:Any] , error == nil else{
                print("failed to make graph request")
                return
            }
            print(result)
            guard let email = result["email"] as? String,
                  let userName = result["name"] as? String else{
                print("failed to get email and username (facebook)")
                return
            }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else{
                return
            }
            let firstComponent = nameComponents[0]
            let secondComponent = nameComponents[1]

            UserDefaults.standard.set(email, forKey: "email")
            
            DataBaseManager.shared.userExists(with: email) { exist in
                if !exist{
                    let chatUser = ChatAppUser(firstName: firstComponent, lastName: secondComponent, email: email)
                    DataBaseManager.shared.insertChatAppUser(with: chatUser) { success in
                        if success {
                            // upload image
                        }
                    }
                }
            }
            let codential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: codential) { [weak self] authResult, error in
                guard let strongSelf = self else{return}
                guard authResult != nil , error == nil else{
                    print("facebook codintial failed \(error?.localizedDescription ?? "") ")
                    return
                }
                print("succesully log in with facebook")
                strongSelf.navigationController?.dismiss(animated: true,completion: nil)
            }
            
        })
        
    }
    
}
