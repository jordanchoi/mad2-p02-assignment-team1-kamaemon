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
import ProjectOxfordFace

class IdentityVerificationViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // View Outlets
    @IBOutlet weak var testImgView: UIImageView!    // to remove for testing purpose only
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var selfieBtn: UIButton!
    
    // Firebase Storage
    private let storage = Storage.storage().reference()
    
    // Instantiate Azure Face API
    let faceClient = MPOFaceServiceClient(subscriptionKey: "25d248b997af4fc4b79d2939263dab03")
//    let faceClient:MPOFaceServiceClient = MPOFaceServiceClient.init(endpointAndSubscriptionKey: "https://mad2kamaemon.cognitiveservices.azure.com/face/v1.0/detect", key: "25d248b997af4fc4b79d2939263dab03")
    
    var faceFromIdentity:MPOFace!
    var faceFromSelfie:MPOFace!
    var identityFaceStr:String = "DEFAULT"
    var identitySelfieStr:String = "DEFAULT"
    
    // Flag to use the same delegate function for capturing images
    var forNric:Bool = true
    
    // Image of NRIC captured by user
    var nric:UIImage?
    var nricBytes:Data? = nil
    
    // Image of Selfie captured by user
    var selfie:UIImage?
    var selfieBytes:Data? = nil
    
    // Name/Email of user for Firebase File Names
    
    // Images shall be uploaded to Firebase and Microsoft Azure Face Biometrics API
    // Selfie captured will be used as Profile Image
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set buttons corner to rounded
        uploadBtn.cornerRadius = 10
        selfieBtn.cornerRadius = 10
        
        // For handling in switch case for captureImg func to set default cameraDevice depending on documents to upload.
        uploadBtn.tag = 1
        uploadBtn.addTarget(self,action:#selector(captureImg),
                            for:.touchUpInside)
        selfieBtn.tag = 2
        selfieBtn.addTarget(self,action:#selector(captureImg),
                            for:.touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func captureImg(sender: UIButton) {
        // Configuration for camera - delegate to device
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        
        // Set cameraDevice depending on documents to be uploaded.
        switch (sender.tag) {
        case 1:
            picker.cameraDevice = .rear;
            break
        case 2:
            picker.cameraDevice = .front;
            break
        default:
            print("Other buttons clicked..")
        }
        
        present(picker, animated: true)
    }
    
    func detectImageValidity(nricData:Data, selfieData:Data)->Bool {
        var valid:Bool = true;
        
        faceClient!.detect(with: nricData, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
            if error != nil {
                print(error)
                valid = false;
                return
            }
            if (faces!.count) > 1 || faces == nil || faces!.count < 1 {
                valid = false;
                return
            }
            print(faces!.count)
            print(faces!)
            print(faces![0].faceId)
            self.faceFromIdentity = faces![0]
            self.identityFaceStr = faces![0].faceId
            print(self.faceFromIdentity!.faceId!)
        })
        
        faceClient!.detect(with: selfieData, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
            print(faces!.count)
            if error != nil {
                print(error)
                valid = false;
                return
            }
            if (faces!.count) > 1 || faces == nil || faces!.count < 1 {
                valid = false;
                return
            }
            print(faces!.count)
            print(faces!)
            print(faces![0].faceId)
            self.faceFromSelfie = faces![0]
            self.identitySelfieStr = faces![0].faceId
            print(self.faceFromSelfie!.faceId!)
        })
        return valid
    }
    
    @IBAction func confirmReg(_ sender: Any) {
        // upload images to FirebaseStorage
        if (nricBytes != nil && selfieBytes != nil) {                   // if image was captured
            if (detectImageValidity(nricData: nricBytes!, selfieData: selfieBytes!))
            {
                print("Face STR: \(self.identityFaceStr), Selfie STR: \(self.identitySelfieStr)")
//                faceClient!.verify(withFirstFaceId: faceFromIdentity.faceId, faceId2: faceFromSelfie.faceId, completionBlock: { (result, error) in
//                    if (error != nil) {
//                        print(error!)
//                        return
//                    }
////                    print(result)
//                    if (result!.isIdentical) {
//                        let name = "Jordan" // for testing to remove
//
//                        // Path to save image to
//                        let nricRef = self.storage.child("images/nric/\(name)_nric.png")
//                        let selfieRef = self.storage.child("images/selfie/\(name)_selfie.png")
//
//                        // nric image upload
//                        nricRef.putData(self.nricBytes!, metadata: nil, completion: {_, error in
//                            guard error == nil else {
//                                print("Upload Failed - NRIC")
//                                return
//                            }
//                            // url of image
//                            nricRef.downloadURL(completion: {url, error in
//                                                guard let url = url, error == nil else {
//                                return
//                            }
//                                                let urlStr = url.absoluteString
//                                                print("Download URL: \(urlStr)")
//                                                UserDefaults.standard.set(urlStr, forKey: "url")
//                            })
//                        })
//
//                        // selfie image upload
//                        selfieRef.putData(self.selfieBytes!, metadata: nil, completion: {_, error in
//                            guard error == nil else {
//                                print("Upload Failed - Selfie")
//                                return
//                            }
//                            // url of image
//                            selfieRef.downloadURL(completion: {url, error in
//                                                guard let url = url, error == nil else {
//                                return
//                            }
//                                                let urlStr = url.absoluteString
//                                                print("Download URL: \(urlStr)")
//                                                UserDefaults.standard.set(urlStr, forKey: "url")
//                            })
//                        })
//                    }
//                    else {
//
//                    }
//                })
            }
        }
        
    }
    
    // Delegate func to capture image with camera - on cancel, dismiss camera
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Delegate func to capture image with camera - on successful capture
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

