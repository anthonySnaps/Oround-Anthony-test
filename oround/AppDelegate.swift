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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = WelcomeViewController()
        self.window?.makeKeyAndVisible()
        UINavigationBar.appearance().barStyle = .blackTranslucent

//        let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//        statusBar?.backgroundColor = .red
        //        finger.sharedData().setAppKey("0XfPGBluVrj2GB8KkHu1zQ==")
        //        finger.sharedData().setAppScrete("ysOi9rG0TArxc2vpxrWxdkTQm9EdIKWb0vk2ZQQBDrcZZtDfGQd500srQr5+W3Ij")
        
        
        
        
        registerForPushNotifications()
        
        finger.sharedData().setAppKey("a5dWGhJjqYPm")
        finger.sharedData().setAppScrete("zzcU63y49pcRyHcn8dAC3vi46lhCK4t8")
        
        //Camera
        //         AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
        //             if response {
        //                 //access granted
        //             } else {
        //
        //             }
        //         }
        
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    
                } else {}
            })
        }
        
        return true
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
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
            }
    }
    
    //    //메세지 오픈 및 읽음 처리
    //    func application:(_ application: UIApplication,
    //        didReceiveRemoteNotification:(NSDictionary *)userInfo
    //                      fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    //        //참고 : 메세지 정보 확인
    //        NSDictionary* dicCode = [finger receviveCode:userInfo];
    //        NSString *strPT = [dicCode objectForKey:@"PT"]; //메세지타입 - DEFT(일반) , STOS (서버투서버), LNGT(롱푸시)
    //        NSString *strIM = [dicCode objectForKey:@"IM"]; //이미지 여부 (0: 이미지 미포함 , 1: 이미지 포함)
    //        NSString *strWL = [dicCode objectForKey:@"WL"]; //웹링크 여부 (0: 웹링크 미포함 , 1: 웹링크 포함)
    //
    //       //메세지 읽음 처리
    //       [[finger sharedData]  requestPushCheckWithBlock:userInfo :^(NSString *posts, NSError *error) {
    //          if (!error) {
    //              NSLog(@"check : %@", posts);
    //          }else{
    //              NSLog(@"check error %@", error);
    //          }
    //      )];
    //    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //핑거푸시의 모든 api를 사용하기 위해서 기기등록 우선
        var token: String = ""
        for i in 0..<deviceToken.count { token += String(format: "%02.2hhx", deviceToken[i] as CVarArg) }
        
    }
    
    
}

//extension UINavigationController {
//
//    func setStatusBar(backgroundColor: UIColor) {
//        let statusBarFrame: CGRect
//        if #available(iOS 13.0, *) {
//            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
//        } else {
//            statusBarFrame = UIApplication.shared.statusBarFrame
//        }
//        let statusBarView = UIView(frame: statusBarFrame)
//        statusBarView.backgroundColor = backgroundColor
//        view.addSubview(statusBarView)
//    }
//
//}


//extension UIApplication {
//var statusBarUIView: UIView? {
//    if #available(iOS 13.0, *) {
//        let tag = 38482
//        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//
//        if let statusBar = keyWindow?.viewWithTag(tag) {
//            return statusBar
//        } else {
//            guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
//            let statusBarView = UIView(frame: statusBarFrame)
//            statusBarView.tag = tag
//            keyWindow?.addSubview(statusBarView)
//            return statusBarView
//        }
//    } else if responds(to: Selector(("statusBar"))) {
//        return value(forKey: "statusBar") as? UIView
//    } else {
//        return nil
//    }
//  }
//}
