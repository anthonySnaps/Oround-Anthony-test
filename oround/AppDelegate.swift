//
//  AppDelegate.swift
//  oround
//
//  Created by thepsyentist on 12/12/21
//

import UIKit
import UserNotifications
import AVFoundation
import Photos
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    private let fingerManager = finger.sharedData()
    private var fcmRegTokenMessage = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Thread.sleep(forTimeInterval: 3.0)

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = WelcomeViewController()
        self.window?.makeKeyAndVisible()
        UINavigationBar.appearance().barStyle = .blackTranslucent
        
        //        registerForPushNotifications()
        
        registeredForRemoteNotifications(application: application)
        //핑거 푸시 sdk 버전
        print("FINGER SDK : " + finger.getSdkVer())
        
        /*핑거 푸시*/
        
        finger.sharedData().setAppKey("a5dWGhJjqYPm")
        finger.sharedData().setAppScrete("zzcU63y49pcRyHcn8dAC3vi46lhCK4t8")
        
        
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    print("PHOTO AUTHORIZED")
                } else {
                    print("PHOTO UNAUTHORIZED")
                }
            })
        }
        
        return true
    }
    
    
    
    //MARK: - 푸시 등록
    func registeredForRemoteNotifications(application: UIApplication) {
        // Firebase
        
        
        
        // APNS
#if !targetEnvironment(simulator)
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            // 카테고리를 이용한 NotificationAction
            //payload category 는 fp (이미지가 있을 경우 fp가 자동으로 함께 전송됩니다.)
            /*
             let acceptAction = UNNotificationAction(identifier: "com.kissoft.yes", title: "확인", options: .foreground)
             let declineAction = UNNotificationAction(identifier: "com.kissoft.no", title: "닫기", options: .destructive)
             let category = UNNotificationCategory(identifier: "fp", actions: [acceptAction,declineAction], intentIdentifiers: [], options: .customDismissAction)
             center.setNotificationCategories([category])
             */
            center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted, error) in
                print("granted : \(granted) / error : \(String(describing: error))")
                DispatchQueue.main.async(execute: {
                    application.registerForRemoteNotifications()
                })
            })
        }
#endif
    }
    
    /**
     * Device Token은 Finger로 보내주자
     */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("DeviceToken: \(deviceTokenString)")
        
        finger.sharedData()?.registerUser(withBlock: deviceToken, { (posts, error) -> Void in
            print("@@@finger token : " + ((finger.sharedData()?.getToken()) ?? "없음"))
            print("@@@finger DeviceIdx : " + ((finger.sharedData()?.getDeviceIdx()) ?? "없음"))
            print("@@@posts: \(String(describing: posts)) error: \(String(describing: error))")
        })
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.fcmRegTokenMessage  = "Remote FCM registration token: \(token)"
            }
        }
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification
                     userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if let dicAps = userInfo["aps"] as? Dictionary<String,Any> {
            if let ca = dicAps["content-available"] {
                if ca as! Int == 1 {
                    //사일런트 푸시일 경우 처리
                    completionHandler(UIBackgroundFetchResult.newData)
                    return
                }
            }
        }
        /*핑거푸시 읽음처리*/
        checkPush(userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(error)")
    }
    
    //MARK: - 푸시 얼럿
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[fcmRegTokenMessage] {
            print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // Print full message.
        print(userInfo)
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping ()
                                -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // [START_EXCLUDE]
        // Print message ID.
        if let messageID = userInfo[fcmRegTokenMessage] {
            print("Message ID: \(messageID)")
        }
        // [END_EXCLUDE]
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print full message.
        print(userInfo)
        
        /*핑거푸시 읽음처리*/
        checkPush(userInfo)
        
        let strAction = response.actionIdentifier
        print(strAction)
//        if strAction.contains("yes") || strAction.contains("UNNotificationDefaultActionIdentifier") {
//            let alert = UIAlertController(title: "OROUND",
//                                          message: userInfo.,
//                                          preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
//        }
//
        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
   
    //MARK: - 푸시 오픈 체크
    func checkPush(_ UserInfo : [AnyHashable : Any]){
        finger.sharedData().requestPushCheck(withBlock: UserInfo , { (posts, error) -> Void in
            print("###posts: \(String(describing: posts)) error: \(String(describing: error))")
        })
    }
}



extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    // [END refresh_token]
}
