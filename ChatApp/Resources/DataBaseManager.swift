//
//  DataBaseManager.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 07/06/2022.
//

import Foundation
import FirebaseDatabase

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let email: String
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String  {
        //khaled_gmail.com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
// final bec cant be inherantce from any other class
final class DataBaseManager{
    static let shared = DataBaseManager()
    private let dataBase = Database.database().reference()

    
   
}
//MARK: - Account Management
extension DataBaseManager {
    
    public func userExists(with email: String , completion: @escaping ((Bool)-> Void)){
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        dataBase.child(safeEmail).observeSingleEvent(of: .value) { snapShot in
            guard snapShot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// insert user into database
    public func insertChatAppUser(with user: ChatAppUser , completion: @escaping (Bool)-> Void){
        dataBase.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ], withCompletionBlock: { error , _ in
            guard error == nil else{
                print("failed to write to firebase")
                completion(false)
                return
            }
            completion(true)
            
        })
    }
}


