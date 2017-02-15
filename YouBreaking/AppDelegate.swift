//
//  AppDelegate.swift
//  YouBreaking
//
//  Created by Giorgio Romano on 30/01/2017.
//  Copyright © 2017 Giorgio Romano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import GooglePlaces
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow?
    var utils  = LoginUtils.sharedInstance


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
         _ = FBSDKLoginButton()
        
        self.window?.tintColor = Colors.red
        
        
        GMSPlacesClient.provideAPIKey("AIzaSyCdNUs-6DJkI79h-lMRPtyj7V_h4AMybCU")
        
        
        LoginUtils.sharedInstance.loginWithFacebookToken{
                        
            if let _ = LoginUtils.sharedInstance.token{
                //self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            }else{
                let rootController = UIStoryboard(name: "Landing", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login Landing Page")
                self.window?.rootViewController = rootController
                let alert = UIAlertController(title: "Il tuo Login non è valido", message: "Autenticati di Nuovo", preferredStyle: UIAlertControllerStyle.alert )
                rootController.present(alert, animated: true, completion: nil)
            }
        }
        
        
                
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let data = userInfo.jsonData() {
            
            if(UIApplication.shared.applicationState == .active){
                
            }else{
                
                let payload = JSON(data: data)
                
                if(payload["type"].stringValue == "NEWS_NOTIFICATION" || payload["type"].stringValue == "NEWS_POSTED"){
                
                    let root = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as! UITabBarController
                    root.selectedIndex = 0
                    
                    let singleController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Single News Controller") as! SingleNews
                    singleController.data = payload["data"]
                    
                    print(root.selectedViewController)
                    let rootNav = root.selectedViewController as! NavigationRed
                    rootNav.pushViewController(viewController: singleController)
                    
                    self.window?.rootViewController = root

                }
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if (viewController as? UINavigationController)?.viewControllers[0] is ScriviNotiziaController {
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "Navigation Scrivi Notizia Controller") {
                tabBarController.present(newVC, animated: true)
                return false
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("REGISTATION SUCCESS")
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})

        utils = LoginUtils.sharedInstance
        if let _ = self.utils.token{
            let parameters = [ "devicetoken" : token ]
            self.utils.session.request(self.utils.baseUrl + "/api/register/ios", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                response in
            }
        }

        
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
        print("FAILED REGISTRATION")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}
