//
//  ChatViewController.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 02/07/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
struct Message: MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
struct Media: MediaItem{
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    
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
        // here
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setUpInputButton()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    //MARK: - private func
    private func setUpInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    private func presentInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media", message: "What whould you like to attach ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: {  _ in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel,handler: nil))
        
        present(actionSheet, animated: true)
    }
    // select photo
    private func presentPhotoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where whould you like to attach photo from ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    // select video
    private func presentVideoInputActionSheet(){
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where whould you like to attach video from ?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    // listen for messages
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
//MARK: - extensions MessagesDataSource ,MessagesLayoutDelegate , MessageCellDelegate
// MessagesDataSource
extension ChatViewController: MessagesDataSource , MessagesLayoutDelegate, MessagesDisplayDelegate , MessageCellDelegate{
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
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else{
            return
        }
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else{
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default :
            break
        }
    }
    // when u click the message (photo)
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else{
            return
        }
        let message = messages[indexPath.section]
        print("Tapped to photo \(message)")
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else{
                return
            }
            let vc = PhotoViewerViewController(with: imageUrl)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoURL = media.url else{
                return
            }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            
            present(vc, animated: true)
        default :
            break
        }
    }
    
}
//MARK: - InputBarAccessoryViewDelegate
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
                    inputBar.inputTextView.text = ""
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
// UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true , completion: nil)
        guard let messageId = createMessageId() , let conversationId = conversationID , let name = self.title , let selfSender = selfSender else {
            return
        }
        if let image = info[.editedImage] as? UIImage , let imageData = image.pngData() {
            // upload image
            let fileName =  "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            StorageManager.shared.uploadMessageImage(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else{return}
                
                switch result {
                case .success(let urlString):
                    // send message
                    print("uploading photo message : \(urlString)")
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus") else{
                        return
                    }
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                    DataBaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                        if success  {
                            print("success to sent photo message")
                        }else{
                            print("failed to sent photo message")
                        }
                    }
                    break
                case .failure(let error):
                    print("failed to upload photo message \(error)")
                }
            }
        }else if let videoUrl = info[.mediaURL] as? URL{
            let fileName =  "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            // upload video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else{return}
                
                switch result {
                case .success(let urlString):
                    // send message
                    print("uploading Video message : \(urlString)")
                    guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "play") else{
                        return
                    }
                    let media = Media(url: url, image: nil, placeholderImage: placeholder, size: .zero)
                    let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .video(media))
                    DataBaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                        if success  {
                            print("success to sent photo message")
                        }else{
                            print("failed to sent photo message")
                        }
                    }
                    break
                case .failure(let error):
                    print("failed to upload photo message \(error)")
                }
            }
            
        }
        
    }
    
}
