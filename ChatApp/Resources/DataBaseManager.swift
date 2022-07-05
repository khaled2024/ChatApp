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
    static func safeEmail(emailAddress: String)-> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
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
            self.dataBase.child("users").observeSingleEvent(of: .value) { snapShot in
                if var usersCollection = snapShot.value as? [[String:String]]{
                    // append user to dictionary
                    let newElement =
                    [
                        "name": user.firstName + " " + user.lastName,
                        "safeEmail": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.dataBase.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }else{
                    // crate that array
                    let newCollection: [[String:String]] =
                    [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "safeEmail": user.safeEmail
                        ]
                    ]
                    self.dataBase.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        })
    }
    public func getAllUsers(completion: @escaping(Result<[[String:String]] , Error>)->Void){
        dataBase.child("users").observeSingleEvent(of: .value, with: {snapShot in
            guard let value = snapShot.value as? [[String:String]] else{
                completion(.failure(dataBaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}

public enum dataBaseError: Error{
    case failedToFetch
}
/*
 users -> [
 [
 "name":
 "safeEmail":
 ],
 [
 "name":
 "safeEmail":
 ],
 ]
 */

