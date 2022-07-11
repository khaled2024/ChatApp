//
//  ChatViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/07/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
struct Sender: SenderType{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}
extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
//MARK: - Start Class
class ChatViewController: MessagesViewController{
    
    public static let dateFormatter: DateFormatter = {
        let formattre = DateFormatter()
        formattre.dateStyle = .medium
        formattre.timeStyle = .long
        formattre.locale = .current
        return formattre
    }()
    
    private var messages = [Message]()
    public var isNewConversation = false
    public let otherUserEmail: String
    private let conversationID: String?
    private var selfSender: Sender?  {
        guard let email = UserDefaults.standard.value(forKey: "email")as? String else {
            return nil
        }
//        let safeEmail = DataBaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: email, displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationID{
            ListenForMessage(id: conversationId)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    //MARK: - private func
    private func ListenForMessage(id: String){
        DataBaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard  !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case .failure(let error):
                print("failed to get messages \(error)")
            }
        }
    }
}
//MARK: - extensions
// MessagesDataSource
extension ChatViewController: MessagesDataSource , MessagesLayoutDelegate, MessagesDisplayDelegate{
    public func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("self sender is nil , email should be cached")
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
// InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty , let selfSender = self.selfSender , let  messageID = createMessageId() else{
            return
        }
        print("sending \(text)")
        // send message
        let message = Message(sender: selfSender, messageId: messageID, sentDate: Date(), kind: .text(text))
        if isNewConversation {
            // create conversation in database
            
            DataBaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "user", firstMessage: message) { [weak self] success in
                if success {
                    print("success to send")
                    self?.isNewConversation = false
                }else{
                    print("failed to send")
                }
            }
        }else{
            // append the existing conversation
            guard let conversationId = conversationID , let name = self.title else{return}
            DataBaseManager.shared.sendMessage(to: conversationId,otherUserEmail: otherUserEmail , name: name, newMessage: message) { succes in
                if succes{
                    print("message sent")
                }else{
                    print("failed to send")
                }
            }
        }
    }
    private func createMessageId() -> String?{
        // date , otherUserEmail , senderEmail , randonInt
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeCurrentEmail = DataBaseManager.safeEmail(emailAddress: currentEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifer = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        print("created message id \(newIdentifer)")
        return newIdentifer
    }
}
