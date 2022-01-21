//
//  IdentityVerificationViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 21/1/22.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseStorage

class IdentityVerificationViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // View Outlets
    @IBOutlet weak var testImgView: UIImageView!    // to remove for testing purpose only
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var selfieBtn: UIButton!
    
    // Firebase Storage
    private let storage = Storage.storage().reference()
    
    // Flag to use the same delegate function for capturing images
    var forNric:Bool = true
    
    // Image of NRIC captured by user
    var nric:UIImage?
    var nricBytes:Data? = nil
    
    // Image of Selfie captured by user
    var selfie:UIImage?
    var selfieBytes:Data? = nil
    
    // Images shall be uploaded to Firebase and Microsoft Azure Face Biometrics API
    // Selfie captured will be used as Profile Image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadBtn.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func captureImg() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        if (forNric) {
            picker.cameraDevice = .rear
        } else {
            picker.cameraDevice = .front
        }
        present(picker, animated: true)
    }
    
    @IBAction func confirmReg(_ sender: Any) {
        // upload images to FirebaseStorage
        if (nricBytes != nil && selfieBytes != nil) {
            let name = "Jordan" // for testing to remove
            let nricRef = storage.child("images/nric/\(name)_nric.png")
            let selfieRef = storage.child("images/selfie/\(name)_selfie.png")
            
            // nric image
            nricRef.putData(nricBytes!, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print("Upload Failed - NRIC")
                    return
                }
                nricRef.downloadURL(completion: {url, error in
                                    guard let url = url, error == nil else {
                    return
                }
                                    let urlStr = url.absoluteString
                                    print("Download URL: \(urlStr)")
                                    UserDefaults.standard.set(urlStr, forKey: "url")
                })
            })
            
            selfieRef.putData(selfieBytes!, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print("Upload Failed - Selfie")
                    return
                }
                selfieRef.downloadURL(completion: {url, error in
                                    guard let url = url, error == nil else {
                    return
                }
                                    let urlStr = url.absoluteString
                                    print("Download URL: \(urlStr)")
                                    UserDefaults.standard.set(urlStr, forKey: "url")
                })
            })
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        if (forNric) {
            nric = image
            forNric = false;
            nricBytes = image.pngData()
            testImgView.image = nric; // for testing to remove
            uploadBtn.isEnabled = false
        }
        else {
            selfie = image
            selfieBytes = image.pngData()
            forNric = true;
            testImgView.image = selfie // for testing to remove
            selfieBtn.isEnabled = false
        }
    }
}

