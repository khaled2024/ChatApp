//
//  DataBaseManager.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 07/06/2022.
//

import Foundation
import FirebaseDatabase
import AVFoundation

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
    
    // get data (fist name last name)
    public func getDataFor(path: String , completion: @escaping (Result<Any , Error>)-> Void){
        self.dataBase.child("\(path)").observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value else{
                completion(.failure(dataBaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}
//MARK: - sending message / conversations
extension DataBaseManager {
    /// create a new conversation with a first message sent
    public func createNewConversation(with otherUserEmail: String ,name: String, firstMessage: Message , completion: @escaping (Bool)-> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email")as? String,
              let currentName = UserDefaults.standard.value(forKey: "name")as? String else{
            return
        }
        let safeEmail = DataBaseManager.safeEmail(emailAddress: currentEmail)
        let refrence = dataBase.child("\(safeEmail)")
        refrence.observe(.value) {[weak self] snapShot in
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
                "name": name,
                "latestMessage": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                    
                ]
            ]
            let recipient_newConversation: [String:Any] = [
                "id": conversationID,
                "otherUserEmail": safeEmail,
                "name": currentName,
                "latestMessage": [
                    "date": dateString,
                    "message": message,
                    "isRead": false
                    
                ]
            ]
            // update  recipient conversation entry
            self?.dataBase.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { [weak self] snapShot in
                if var conversations = snapShot.value as? [[String: Any]]{
                    // append
                    conversations.append(recipient_newConversation)
                    self?.dataBase.child("\(otherUserEmail)/conversations").setValue(conversationID)
                }else{
                    // creation case
                    self?.dataBase.child("\(otherUserEmail)/conversations").setValue([recipient_newConversation])
                }
            }
            
            // update current user conversation entry
            if var conversation = userNode["conversations"] as? [[String: Any]] {
                // conversation of user exist for current user
                conversation.append(newConversation)
                refrence.setValue(userNode) {  [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name , conversationID: conversationID, firstMessage: firstMessage, completion: completion)
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
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    //Functions
    private func finishCreatingConversation(name: String , conversationID: String , firstMessage: Message , completion : @escaping (Bool)-> Void){
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
            "is_read": false,
            "name": name
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
    public func getAllConversation(for email: String, completion : @escaping (Result<[Conversation] , Error>) -> Void){
        dataBase.child("\(email)/conversations").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String:Any]] else{
                completion(.failure(dataBaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String ,
                      let otherUserEmail = dictionary["otherUserEmail"]as? String,
                      let latestMessage = dictionary["latestMessage"]as? [String:Any],
                      let date = latestMessage["date"] as? String ,
                      let message = latestMessage["message"] as? String ,
                      let isRead = latestMessage["isRead"] as? Bool else{
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date, text: message, isread: isRead)
                return Conversation(id: conversationID, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        }
        
    }
    /// get all messages for a given conversation
    public func getAllMessagesForConversation(with id: String , completion: @escaping (Result<[Message] , Error>) -> Void){
        dataBase.child("\(id)/messages").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String:Any]] else{
                completion(.failure(dataBaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"]as? String ,
                      let content = dictionary["content"]as? String,
                      let dateString = dictionary["date"]as? String ,
                      let is_read = dictionary["is_read"]as? Bool ,
                      let senderEmail = dictionary["senderEmail"]as? String,
                      let type = dictionary["type"]as? String ,
                      let messageID = dictionary["id"]as? String, let date = ChatViewController.dateFormatter.date(from: dateString)  else{
                    return nil
                }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))
            }
            completion(.success(messages))
        }
    }
    /// sending a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserEmail:String, name: String , newMessage: Message , completion: @escaping (Bool)-> Void){
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        guard let myEmail = UserDefaults.standard.value(forKey: "email")as? String else{
            completion(false)
            return
        }
        let currentEmail = DataBaseManager.safeEmail(emailAddress: myEmail)
        self.dataBase.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self]snapShot in
            guard let strongSelf = self else{return}
            guard var currentMessages = snapShot.value as? [[String:Any]]else{
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch newMessage.kind {
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
            
            guard let currentUserEmail = UserDefaults.standard.value(forKey: "email")as? String else{
                completion(false)
                return
            }
            let newMessageEntry: [String:Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "senderEmail": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            strongSelf.dataBase.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                strongSelf.dataBase.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                    guard var currentUserConversations = snapShot.value as? [[String:Any]] else{
                        completion(false)
                        return
                    }
                    let updatedValue: [String:Any] = [
                        "date": dateString,
                        "isRead": false,
                        "message": message
                    ]
                    var targetConversation: [String:Any]?
                    var position = 0
                    for conversationDic in currentUserConversations {
                        if let currentId = conversationDic["id"] as? String , currentId == conversation{
                            targetConversation = conversationDic
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latestMessage"] = updatedValue
                    guard let finalConversation = targetConversation else{
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    strongSelf.dataBase.child("\(currentEmail)/conversations").setValue(currentUserConversations) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        // update latest message for recipient
                        strongSelf.dataBase.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                            guard var otherUserConversations = snapShot.value as? [[String:Any]] else{
                                completion(false)
                                return
                            }
                            let updatedValue: [String:Any] = [
                                "date": dateString,
                                "isRead": false,
                                "message": message
                            ]
                            var targetConversation: [String:Any]?
                            var position = 0
                            for conversationDic in otherUserConversations {
                                if let currentId = conversationDic["id"] as? String , currentId == conversation{
                                    targetConversation = conversationDic
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latestMessage"] = updatedValue
                            guard let finalConversation = targetConversation else{
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            strongSelf.dataBase.child("\(otherUserEmail)/conversations").setValue(otherUserConversations) { error, _ in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
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

