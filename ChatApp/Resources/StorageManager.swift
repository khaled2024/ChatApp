//
//  StorageManager.swift
//  ChatApp
//
//  Created by KhaleD HuSsien on 03/07/2022.
//

import Foundation
import FirebaseStorage
import AVFoundation

public enum StorageError : Error{
    case failedToUpload
    case failedToGetReference
}

final class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    // upload picture to firebase storage and return completion with url string to download
    public typealias UploadPictureCompletion = (Result<String , Error>)->Void
    public func uploadProfilePicture(with data: Data , fileName: String , completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else{
                // failed
                print("failed to upload picture to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get reference from url")
                    completion(.failure(StorageError.failedToGetReference))
                    return
                }
                let urlString = url.absoluteString
                print("downloaded url \(urlString)")
                completion(.success(urlString))
                
            }
        }
        
    }
    //download url
    public func downloadURL(for path: String, completion: @escaping(Result<URL , Error>)-> Void){
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url , error == nil else {
                completion(.failure(StorageError.failedToGetReference))
                return
            }
            completion(.success(url))
        }
    }
    // upload image that sent for message conversation
    public func uploadMessageImage(with data: Data , fileName: String , completion: @escaping UploadPictureCompletion){
        storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
            guard error == nil else{
                // failed
                print("failed to upload picture to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self?.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get reference from url")
                    completion(.failure(StorageError.failedToGetReference))
                    return
                }
                let urlString = url.absoluteString
                print("downloaded url \(urlString)")
                completion(.success(urlString))
                
            }
        }
        
    }
    // upload video that sent for message conversation
    public func uploadMessageVideo(with fileUrl: URL , fileName: String , completion: @escaping UploadPictureCompletion){
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) { [weak self] metaData, error in
            guard error == nil else{
                // failed
                print("failed to upload video to firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            self?.storage.child("message_videos/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("failed to get reference from url")
                    completion(.failure(StorageError.failedToGetReference))
                    return
                }
                let urlString = url.absoluteString
                print("downloaded url \(urlString)")
                completion(.success(urlString))
                
            }
        }
        
    }
}
