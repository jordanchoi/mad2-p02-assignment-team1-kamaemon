//
//  SceneDelegate.swift
//  Kamaemon
//
//  Created by Jordan Choi on 14/1/22.
//

import UIKit
import CircleBar
import Firebase
class SceneDelegate: UIResponder, UIWindowSceneDelegate{

    var window: UIWindow?


    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let storyboard2 = UIStoryboard(name: "User", bundle: nil)
    
       func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
           
           let prefs = SharedPrefsController()
           let id = prefs.getLoginUID()
           var volunteer = false
           
           var ref: DatabaseReference!
           ref = Database.database(url: "https://kamaemon-default-rtdb.asia-southeast1.firebasedatabase.app/").reference()
           
           if(id != ""){
               ref.child("users").child(id).observeSingleEvent(of: .value, with: { [self] snapshot in
                       let value = snapshot.value as? NSDictionary
                       let cat = value?["UserType"] as! String
                       if(cat == "Volunteer"){
                           volunteer = true
                       }
                       if(volunteer){
                           guard let windowScene = scene as? UIWindowScene else { return }
                           let vc = storyboard.instantiateViewController (withIdentifier: "home")
                           window = UIWindow(windowScene: windowScene)
                           window?.rootViewController = vc
                           window?.makeKeyAndVisible()
                       }
                       else{
                           guard let windowScene = scene as? UIWindowScene else { return }
                           let vc = storyboard2.instantiateViewController (withIdentifier: "UserHome")
                           window = UIWindow(windowScene: windowScene)
                           window?.rootViewController = vc
                           window?.makeKeyAndVisible()
                       }
                   })
           }
           else{
               if(!prefs.IsNew()){
                   guard let windowScene = scene as? UIWindowScene else { return }
                   let vc = storyboard.instantiateViewController (withIdentifier: "ViewController")
                   window = UIWindow(windowScene: windowScene)
                   window?.rootViewController = vc
                   window?.makeKeyAndVisible()
               }
               else{
                   guard let windowScene = scene as? UIWindowScene else { return }
                   let vc = storyboard.instantiateViewController (withIdentifier: "onboarding") as! OnboardingViewController
                   window = UIWindow(windowScene: windowScene)
                   window?.rootViewController = vc
                   window?.makeKeyAndVisible()
               }
           }
       }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

