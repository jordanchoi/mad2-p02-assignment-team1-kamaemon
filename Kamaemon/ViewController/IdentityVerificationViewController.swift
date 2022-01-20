//
//  IdentityVerificationViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 21/1/22.
//

import Foundation
import UIKit

class IdentityVerificationViewController: UIViewController {
    @IBOutlet weak var testImgView: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadBtn.cornerRadius = 10
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @IBAction func uploadNRIC() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @IBAction func confirmReg(_ sender: Any) {
    }
    
}

extension IdentityVerificationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        testImgView.image = image
    }
}

