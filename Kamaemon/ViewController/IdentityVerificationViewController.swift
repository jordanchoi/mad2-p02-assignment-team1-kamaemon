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
import Firebase
import FirebaseAuth
import ProjectOxfordFace
import Lottie

class IdentityVerificationViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    //url of images
    var nricurl : String = ""
    var selfieurl : String = ""
    
    
    
    // Lottie Animation
    let animationView = AnimationView()
    
    
    // View Outlets
    @IBOutlet weak var testImgView: UIImageView!    // to remove for testing purpose only
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var selfieBtn: UIButton!
    @IBOutlet weak var nricUploadStatus: UIImageView!
    @IBOutlet weak var selfieUploadStatus: UIImageView!
    @IBOutlet weak var errorMsgLbl: UILabel!
    
    // Firebase Storage
    private let storage = Storage.storage().reference()
    
    // Instantiate Azure Face API
    let faceClient = MPOFaceServiceClient(subscriptionKey: "25d248b997af4fc4b79d2939263dab03")
    
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
    
    private func setUpAnimation() {
        animationView.animation = Animation.named("4432-face-scanning")
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.view.center
        animationView.backgroundColor = UIColor(white: 1, alpha: 0.8)
        animationView.isOpaque = false
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        view.addSubview(animationView)
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
            picker.cameraFlashMode = .off
            break
        default:
            print("Other buttons clicked..")
        }
        
        present(picker, animated: true)
    }
    
    @IBAction func confirmReg(_ sender: Any) {
        // detect image validity, verify images and upload images to FirebaseStorage
        if (nricBytes != nil && selfieBytes != nil) {                   // if image was captured
            setUpAnimation()
            // NRIC Image Detection
            self.faceClient!.detect(with: self.nricBytes!, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
                if error != nil {
                    print(error! as NSError)
                    self.errorMsgLbl.text = "An error occurred"
                    self.errorMsgLbl.isHidden = false
                    self.uploadBtn.isEnabled = true
                    self.selfieBtn.isEnabled = true
                    self.selfieUploadStatus.isHidden = true
                    self.nricUploadStatus.isHidden = true
                    self.animationView.removeFromSuperview()
                    return
                }
                if (faces!.count) > 1 || faces == nil || faces!.count < 1 {
                    self.errorMsgLbl.text = "There was no face detected in one or more images you have uploaded. Please try again"
                    self.errorMsgLbl.isHidden = false
                    self.uploadBtn.isEnabled = true
                    self.selfieBtn.isEnabled = true
                    self.selfieUploadStatus.isHidden = true
                    self.nricUploadStatus.isHidden = true
                    self.animationView.removeFromSuperview()
                    return
                }
                let faceFromIdentity = faces![0]
                
                // Selfie Image Detection
                self.faceClient!.detect(with: self.selfieBytes!, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [], completionBlock: { (faces, error) in
                    if error != nil {
                        print(error! as NSError)
                        self.errorMsgLbl.text = "An error occurred"
                        self.errorMsgLbl.isHidden = false
                        self.uploadBtn.isEnabled = true
                        self.selfieBtn.isEnabled = true
                        self.selfieUploadStatus.isHidden = true
                        self.nricUploadStatus.isHidden = true
                        self.animationView.removeFromSuperview()
                        return
                    }
                    if (faces!.count) > 1 || faces == nil || faces!.count < 1 {
                        self.errorMsgLbl.text = "There was no face detected in one or more images you have uploaded. Please try again"
                        self.errorMsgLbl.isHidden = false
                        self.uploadBtn.isEnabled = true
                        self.selfieBtn.isEnabled = true
                        self.selfieUploadStatus.isHidden = true
                        self.nricUploadStatus.isHidden = true
                        self.animationView.removeFromSuperview()
                        return
                    }
        
                    let faceFromSelfie = faces![0]
                    
                    // Both Images are detected and validated, to verify and compare using Face API
                    self.faceClient!.verify(withFirstFaceId: faceFromIdentity.faceId, faceId2: faceFromSelfie.faceId, completionBlock: { (result, error) in
                        print(result!.isIdentical)
                        print(result!.confidence)
                        if (error != nil) {
                            print(error! as NSError)
                            self.animationView.removeFromSuperview()
                            return
                        }
                        if (result!.isIdentical) {                      // returns boolean based on confidence determined
//                            let uid:String = "tofix"
                            
                            //create volunteer user here
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            //print(appDelegate.verifyEmail!)
                            //print(appDelegate.verifyPassword!)
                            var ref: DatabaseReference!
                            ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
//                            Auth.auth().createUser(withEmail: appDelegate.verifyEmail!, password: appDelegate.verifyPassword!) { (authResult, error) in
//                                    print("success")
//                                    print(authResult?.user.uid)
//                                    appDelegate.verifyUser?.UID = (authResult?.user.uid)!
//                                    var newUser : User = appDelegate.verifyUser!
//                                    ref.child("users").child((authResult?.user.uid)!).setValue(["userUID" :(authResult?.user.uid)!, "UserType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "DOB" : newUser.BirthDate, "PFPURL" : newUser.profilepicurl, "isNewUser" : newUser.isNewUser])
//
//
//                            }
//                            Auth.auth().signIn(withEmail: appDelegate.verifyEmail!, password: appDelegate.verifyPassword!) { (authResult, error) in
//                                if let error = error as? NSError {
//                                    print(error)
//                                }
//                                else{
//                                    var newUser : User = appDelegate.verifyUser!
//                                    ref.child("users").child(Auth.auth().currentUser!.uid).setValue(["userUID" :(Auth.auth().currentUser!.uid), "UserType" : newUser.UserType, "Name" : newUser.n, "Gender" : newUser.Gender, "PhoneNumber" : newUser.PhoneNumber, "DOB" : newUser.BirthDate, "PFPURL" : newUser.profilepicurl, "isNewUser" : newUser.isNewUser])
//                                }
//                            }
                        
         
                            // code is until here for create colunteer
                            //get uid from verify user
                            guard let uid = appDelegate.verifyUser?.UID else { return }
                            //guard let uid = Auth.auth().currentUser?.uid else { return }
                            
                            // Path to save image to
                            let nricRef = self.storage.child("images/nric/\(uid)_nric.png")
                            let selfieRef = self.storage.child("images/selfie/\(uid)_selfie.png")
    
                            
                    
                            // nric image upload
                            nricRef.putData(self.nricBytes!, metadata: nil, completion: {_, error in
                                guard error == nil else {
                                    print("Upload Failed - NRIC")
                                    return
                                }
                                // url of image
                                nricRef.downloadURL(completion: {url, error in
                                                    guard let url = url, error == nil else {
                                    return
                                }
                                                    let urlStr = url.absoluteString
                                                    print("Download URL: \(urlStr)")
                                                    self.nricurl = urlStr
                                                    UserDefaults.standard.set(urlStr, forKey: "url")
                                })
                            })
    
                            // selfie image upload
                            selfieRef.putData(self.selfieBytes!, metadata: nil, completion: {_, error in
                                guard error == nil else {
                                    print("Upload Failed - Selfie")
                                    return
                                }
                                // url of image
                                selfieRef.downloadURL(completion: {url, error in
                                                    guard let url = url, error == nil else {
                                    return
                                }
                                                    let urlStr = url.absoluteString
                                                    self.selfieurl = urlStr
                                                    print("Download URL: \(urlStr)")
                                                    UserDefaults.standard.set(urlStr, forKey: "url")
                                })
                            })
                            
                            //put images in database
                            ref.child("VolunteersVerification").child(uid).setValue(["NRIC" : self.nricurl, "Selfie" : self.selfieurl])
                            
//                            Auth.auth().signIn(withEmail: appDelegate.verifyEmail!, password: appDelegate.verifyPassword!) { (authResult, error) in
//                                if let error = error as? NSError {
//                                    print(error)
//                                }
//                                else{
//                                    self.animationView.removeFromSuperview()
//                                    self.performSegue(withIdentifier:"toVolunteerHomeSegue", sender: nil)
//                                }
//                            }
                            
                            
                            self.animationView.removeFromSuperview()
                            //direct user to login page
                            let controller = self.storyboard?.instantiateViewController(identifier: "ViewController") as! UIViewController
                                        controller.modalPresentationStyle = .fullScreen
                                        controller.modalTransitionStyle = .flipHorizontal
                            self.present(controller, animated: true, completion: nil)
                            //self.performSegue(withIdentifier:"toVolunteerHomeSegue", sender: nil)
                        }
                        else {                  // not identical
                            self.errorMsgLbl.text = "The captured image does not match the image in the identity card. Please try again."
                            self.errorMsgLbl.isHidden = false
                            self.uploadBtn.isEnabled = true
                            self.selfieBtn.isEnabled = true
                            self.selfieUploadStatus.isHidden = true
                            self.nricUploadStatus.isHidden = true
                            self.animationView.removeFromSuperview()
                        }
                    })
                })
            })
        }
        else {
            self.errorMsgLbl.text = "You have to submit both your NRIC and a photo of yourself. Please try again."
            self.errorMsgLbl.isHidden = false
            self.animationView.removeFromSuperview()
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
            nricUploadStatus.isHidden = false
        }
        else {
            selfie = image
            selfieBytes = image.pngData()
            forNric = true;
            testImgView.image = selfie // for testing to remove
            selfieBtn.isEnabled = false
            selfieUploadStatus.isHidden = false
        }
    }
}
