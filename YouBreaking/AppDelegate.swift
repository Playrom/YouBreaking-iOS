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
import Alamofire
import SwiftyJSON
import CoreLocation
import MapKit
import Onboard
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    var utils  = LoginUtils.sharedInstance
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var onboard : OnboardingViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
         _ = FBSDKLoginButton()
        
        self.window?.tintColor = Colors.red
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        LoginUtils.sharedInstance.loginWithFacebookToken{
                        
            if let _ = LoginUtils.sharedInstance.token{
                self.locationManager.requestAlwaysAuthorization()
                //self.window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
            }else{
                
                if UserDefaults.standard.bool(forKey: "Already Launched"){
                    self.locationManager.requestAlwaysAuthorization()
                    let rootController = UIStoryboard(name: "Landing", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login Landing Page")
                    self.window?.rootViewController = rootController
                }else{
                    let rootController = UIStoryboard(name: "Landing", bundle: Bundle.main).instantiateViewController(withIdentifier: "Login Landing Page")
                    self.window?.rootViewController = rootController
                    
                    let first = OnboardingContentViewController(title: "Benvenuto su You Breaking", body: "Per prima cosa per favore autorizza la ricezione delle notifiche, potrai impostare dettagli più avanti", image:  nil , buttonText: "Autorizza") { () -> Void in
                        // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
                        
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){
                            (granted,error) in
                            if(granted){
                                print("GRANTED")
                                UIApplication.shared.registerForRemoteNotifications()
                            }else{
                                print("UNAUTHORIZED")
                            }
                        }
                    

                    }
                    
                    first.movesToNextViewController = true
                    
                    let second = OnboardingContentViewController(title: "Fornisci la tua posizione", body: "Per poter ricevere notifiche geolocalizzate ti chiediamo di fornirci la tua posizione.", image:  nil , buttonText: "Autorizza") { () -> Void in
                        self.locationManager.requestAlwaysAuthorization()
                    }
                    
                    second.movesToNextViewController = true
                    
                    let third = OnboardingContentViewController(title: "Buona Lettura!", body: nil, image:  nil , buttonText: "Inizia ad usare You Breaking") { () -> Void in
                        self.handleOnboardDismiss()
                    }
                    
                    self.onboard = OnboardingViewController(backgroundImage: UIImage.init(named: "red-background")! , contents: [first,second,third])
                    
                    if let onboard = self.onboard{
                        onboard.shouldMaskBackground = false
                        onboard.shouldBlurBackground = true
                    
                        DispatchQueue.main.async {
                            rootController.present(onboard, animated: true){
                                UserDefaults.standard.set(true, forKey: "Already Launched")
                            }
                        }
                    }
                
                }
                
            }
        }
        
        
                
        return true
    }
    
    func handleOnboardDismiss(){
        self.onboard?.dismiss(animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let data = userInfo.jsonData() {
            
            if(UIApplication.shared.applicationState == .active){
                
            }else{
                
                let payload = JSON(data: data)
                
                if(payload["type"].stringValue == "NEWS_NOTIFICATION" || payload["type"].stringValue == "NEWS_POSTED"){
                
                    let root = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as! UITabBarController
                    root.selectedIndex = 0
                    
                    let singleController = UIStoryboard(name: "Single", bundle: Bundle.main).instantiateViewController(withIdentifier: "Single News Controller") as! SingleNews
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
            if let newVC = tabBarController.storyboard?.instantiateViewController(withIdentifier: "Navigation Scrivi Notizia Controller")  {
                                
                if let root = tabBarController.selectedViewController as? UINavigationController, let write = newVC.childViewControllers.first as? ScriviNotiziaController{
                    write.navigationDelegate = root
                }else if let root = tabBarController.selectedViewController?.navigationController, let write = newVC.childViewControllers.first as? ScriviNotiziaController{
                    write.navigationDelegate = root
                }
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
            self.utils.session.request(self.utils.baseUrl + "/api/register/ios", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers : utils.headers).responseJSON{
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
        NotificationCenter.default.post(Notification(name: Notification.Name("reloadNews")))
        
        self.utils.getProfile{
            json in

            if let location = json?["location"], location["type"].stringValue == "Gps"{
                self.locationManager.startUpdatingLocation()
            }
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first{
            
            geocoder.reverseGeocodeLocation(location){
                place, error in
                if let place = place?.first{
                    let mk = MKPlacemark(placemark: place)
                    
                    let parameters : [String : Any] = [
                        "latitude" : mk.coordinate.latitude,
                        "longitude" : mk.coordinate.longitude,
                        "name" : mk.name!,
                        "country" : mk.country!,
                        "type" : "Gps"
                    ]

                    self.utils.updateUserLocation(parameters: parameters){
                        response in
                    }
                    
                }
                
            }
            
        }
    }


}
