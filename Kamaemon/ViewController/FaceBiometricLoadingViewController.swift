//
//  FaceBiometricLoadingViewController.swift
//  Kamaemon
//
//  Created by Jordan Choi on 22/1/22.
//

import Foundation
import UIKit
import Lottie

class FaceBiometricLoadingViewController : UIViewController {
//    private var animationView: AnimationView?
    @IBOutlet weak var animationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2. Start AnimationView with animation name (without extension)
        let lottieUrl:URL = URL(string: "https://assets2.lottiefiles.com/private_files/lf30_y5tq70sy.json")!
        Animation.loadedFrom(url: lottieUrl, closure: { (animation) in
                    self.animationView.animation = animation
                    self.animationView.play()
                }, animationCache: LRUAnimationCache.sharedCache)
        
        animationView!.frame = view.bounds
        
        // 3. Set animation content mode
        
        animationView!.contentMode = .scaleAspectFit
        
        // 4. Set animation loop mode
        
        animationView!.loopMode = .loop
        
        // 5. Adjust animation speed
        
        animationView!.animationSpeed = 0.5
        
        view.addSubview(animationView!)
        
        // 6. Play animation
        
        animationView!.play()
    }
}
