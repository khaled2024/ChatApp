//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/06/2022.
//

import UIKit
import Firebase
import JGProgressHUD
class RegisterViewController: UIViewController {
    
    //MARK: - Vars&Outlets
    private let spinner = JGProgressHUD(style: .dark)
    
    private let registerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let LogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .darkGray
        imageView.layer.masksToBounds = true
        //  imageView.layer.borderWidth = 2
        //  imageView.layer.borderColor = UIColor.lightGray.cgColor
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
    private let firstNameField: UITextField = {
        let firstNameTF = UITextField()
        firstNameTF.placeholder = "First Name"
        firstNameTF.autocapitalizationType = .none
        firstNameTF.autocorrectionType = .no
        firstNameTF.returnKeyType = .continue
        firstNameTF.layer.cornerRadius = 10
        firstNameTF.layer.borderColor = UIColor.lightGray.cgColor
        firstNameTF.layer.borderWidth = 1
        firstNameTF.font = .systemFont(ofSize: 18, weight: .regular)
        firstNameTF.keyboardType = .emailAddress
        firstNameTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        firstNameTF.leftViewMode = .always
        firstNameTF.backgroundColor = .white
        return firstNameTF
    }()
    private let lastNameField: UITextField = {
        let lastNameTF = UITextField()
        lastNameTF.placeholder = "Last Name"
        lastNameTF.autocapitalizationType = .none
        lastNameTF.autocorrectionType = .no
        lastNameTF.returnKeyType = .continue
        lastNameTF.layer.cornerRadius = 10
        lastNameTF.layer.borderColor = UIColor.lightGray.cgColor
        lastNameTF.layer.borderWidth = 1
        lastNameTF.font = .systemFont(ofSize: 18, weight: .regular)
        lastNameTF.keyboardType = .emailAddress
        lastNameTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        lastNameTF.leftViewMode = .always
        lastNameTF.backgroundColor = .white
        return lastNameTF
    }()
    private let registerBtn: UIButton = {
        let registerBtn = UIButton()
        registerBtn.setTitle("Register", for: .normal)
        registerBtn.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        registerBtn.layer.cornerRadius = 12
        registerBtn.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        registerBtn.titleLabel?.textColor = .blue
        return registerBtn
    }()
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
        registerBtn.addTarget(self, action: #selector(registerDidTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        
        LogoImageView.isUserInteractionEnabled = true
        registerScrollView.isUserInteractionEnabled = true
        //add views
        view.addSubview(registerScrollView)
        registerScrollView.addSubview(LogoImageView)
        registerScrollView.addSubview(emailField)
        registerScrollView.addSubview(passwordField)
        registerScrollView.addSubview(firstNameField)
        registerScrollView.addSubview(lastNameField)
        registerScrollView.addSubview(registerBtn)
        
        // gesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePic))
        LogoImageView.addGestureRecognizer(gesture)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerScrollView.frame = view.bounds
        let size = registerScrollView.width / 3
        LogoImageView.frame = CGRect(x: (registerScrollView.width - size) / 2, y: 80, width: size, height: size)
        LogoImageView.layer.cornerRadius = LogoImageView.width / 2.0
        firstNameField.frame = CGRect(x: 30, y: LogoImageView.bottom + 30, width: registerScrollView.width - 60, height: 50)
        lastNameField.frame = CGRect(x: 30, y: firstNameField.bottom + 10, width: registerScrollView.width - 60, height: 50)
        emailField.frame = CGRect(x: 30, y: lastNameField.bottom + 10, width: registerScrollView.width - 60, height: 50)
        passwordField.frame = CGRect(x: 30, y: emailField.bottom + 10, width: registerScrollView.width - 60, height: 50)
        registerBtn.frame = CGRect(x: 30 , y: passwordField.bottom + 10, width: registerScrollView.width - 60, height: 50)
    }
    //MARK: - functions
    @objc func changeProfilePic(){
        presentingActionImagePickerSheet()
    }
    @objc func registerDidTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        guard let email = emailField.text , let password = passwordField.text,let fName = firstNameField.text , let lName = lastNameField.text ,!fName.isEmpty , !lName.isEmpty, !password.isEmpty , !email.isEmpty , password.count >= 6 else{
            ErrorRegisterAlert()
            return
        }
        spinner.show(in: view)
        DataBaseManager.shared.userExists(with: email) { [weak self] exist in
            guard let strongSelf = self else{return}
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard !exist else{
                // user already exists
                self?.ErrorRegisterAlert(message: "user already exists")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                guard  authResult != nil , error == nil else{
                    print("Error Creating user \(error?.localizedDescription ?? "")")
                    return
                }
                let chatUser = ChatAppUser(firstName: fName,
                                           lastName: lName,
                                           email: email)
                DataBaseManager.shared.insertChatAppUser(with:chatUser) { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.LogoImageView.image , let data = image.pngData() else{
                            return
                        }
                        let fileName = chatUser.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                            switch result {
                            case .success(let downloadUrl):
                                print(downloadUrl)
                                UserDefaults.standard.set(downloadUrl, forKey: "profilePictureUrl")
                            case .failure(let error):
                                print("storage manager error\(error)")
                                
                            }
                        }
                    }
                }
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    private func ErrorRegisterAlert(message: String = "Please enter all information in Register fields"){
        let alert = UIAlertController(title: "Woops", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: nil))
        self.present(alert, animated: true)
    }
}
//MARK: - extensions
// UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            self.lastNameField.becomeFirstResponder()
        }else if textField == lastNameField {
            self.emailField.becomeFirstResponder()
        }else if textField == emailField {
            self.passwordField.becomeFirstResponder()
        }else if textField == passwordField{
            self.registerDidTapped()
        }
        return true
    }
}
// for ui image picker
extension RegisterViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func presentingActionImagePickerSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select your profile picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {[weak self] cameraAction in
            self?.camera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] libraryAction in
            self?.photoLibrary()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel))
        present(actionSheet, animated: true)
    }
    func camera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func photoLibrary(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{return}
        self.LogoImageView.image = selectedImage
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
}
