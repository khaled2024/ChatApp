//
//  ChatViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/07/2022.
//

import UIKit
import MessageKit

struct Message: MessageType{
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
struct Sender: SenderType{
    var photoURL: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController{
    private var messages = [Message]()
    private let selfSender = Sender(photoURL: "", senderId: "1", displayName: "khaled hussien")
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world.!")))
        messages.append(Message(sender: selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello world.! Hello world.! Hello world.! Hello world.!")))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }
    
}
//MARK: - extensions
extension ChatViewController: MessagesDataSource , MessagesLayoutDelegate, MessagesDisplayDelegate{
    public func currentSender() -> SenderType {
        return selfSender
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
