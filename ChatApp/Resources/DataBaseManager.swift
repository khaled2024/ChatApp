//
//  DataBaseManager.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 07/06/2022.
//

import Foundation
import FirebaseDatabase

public enum dataBaseError: Error{
    case failedToFetch
}

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
//MARK: - sending message / conversations
extension DataBaseManager {
    /// create a new conversation with a first message sent
    public func createNewConversation(with otherUserEmail: String , firstMessage: Message , completion: @escaping (Bool)-> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email")as? String else{
            return
        }
        let safeEmail = DataBaseManager.safeEmail(emailAddress: currentEmail)
        let refrence = dataBase.child("\(safeEmail)")
        refrence.observe(.value) { snapShot in
            guard var userNode = snapShot.value as? [String:Any] else{
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationID = "conversation_\(firstMessage.messageId)"
            let newConversation: [String:Any] = [
                "id": conversationID,
                "otherUserEmail": otherUserEmail,
                "latestMessage": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                    
                ]
            ]
            if var conversation = userNode["conversations"] as? [[String: Any]] {
                // conversation of user exist for current user
                conversation.append(newConversation)
                refrence.setValue(userNode) {  [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
                
            }else{
                // new conversation
                // create it
                userNode["conversations"] = [
                    newConversation]
                refrence.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    //Functions
    private func finishCreatingConversation(conversationID: String , firstMessage: Message , completion : @escaping (Bool)-> Void){
//        "message": [
//        {
//        "id": "string"
//        "type": teext photo video
//        "content": string
//        "date": Date()
//        "sender email": string
//        "isRead" : true /false
//
//        }
//        ]
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email")as? String else{
            completion(false)
            return
        }
        let collectionMessage: [String:Any] = [
                "id": firstMessage.messageId,
                "type": firstMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "senderEmail": currentUserEmail,
                "is_read": false
        ]
        let value: [String:Any] = [
            "messages" : [
                collectionMessage
            ]
        ]
        dataBase.child("\(conversationID)").setValue(value) { error, snapShot in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    /// fetch and return all conversations for the user with passed in email
    public func getAllConversation(for email: String, completion : @escaping (Result<String , Error>) -> Void){
        
    }
    /// get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String , completion: @escaping (Result<String , Error>) -> Void){
        
    }
    /// sending a message with target conversation and message
    public func sendMessage(to conversation: String , message: Message , completion: @escaping (Bool)-> Void){
        
    }
}

/*
 "dgdgdgdgd" {
 "message": [
 {
 "id": "string"
 "type": teext photo video
 "content": string
 "date": Date()
 "sender email": string
 "isRead" : true /false
 
 
 }
 ]
 }
 
 conversations -> [
 [
 "conv id": "dgdgdgdgd"
 "otherUserEmail":
 "latest message": -> {
 "date": Date()
 "latest message": "message"
 "is read" : true / false
 }
 ]
 ]
 
 */


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

