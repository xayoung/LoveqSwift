//
//  AppDelegate.swift
//  Loveq
//
//  Created by xayoung on 16/4/15.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import DrawerController
import MediaPlayer
import MZDownloadManager
import PKHUD
import LeanCloud

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var backgroundSessionCompletionHandler : (() -> Void)?
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //注册LeanCloud
        LeanCloud.initialize(applicationID: "xSKEPbolbbf8kzTyPwh0k8IN-gzGzoHsz", applicationKey: "yfsU1LM3UsB2UPQPURS9zvew")

        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: nil)
        
        let storyboard = UIStoryboard(name: "MusicPlayer", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "MusicNavigationController") as! LoveqNavigationController
        let centerNav = rootViewController
        let leftViewController = LeftViewController()
        let rightViewController = DownloadedViewController()
        let drawerController = DrawerController(centerViewController: centerNav, leftDrawerViewController: leftViewController , rightDrawerViewController: rightViewController)
        drawerController.maximumLeftDrawerWidth=180
        drawerController.maximumRightDrawerWidth=220
        drawerController.openDrawerGestureModeMask=OpenDrawerGestureMode.all
        drawerController.closeDrawerGestureModeMask=CloseDrawerGestureMode.all
        LoveqClient.sharedInstance.drawerController = drawerController
        LoveqClient.sharedInstance.centerViewController = centerNav.viewControllers[0] as? MusicViewController
        LoveqClient.sharedInstance.centerNavigation = centerNav
        LoveqClient.sharedInstance.downloadingController = DownloadingViewController()
        LoveqClient.sharedInstance.loveqUIWindow = self.window
        self.window?.rootViewController = drawerController;

        XGPush.startApp(2200205039,appKey:"I3327UDVYP4J");
        
        XGPush.initForReregister { () -> Void in
            
            if(!XGPush.isUnRegisterStatus()){
                
                print("注册通知");
                
                if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))){
                    
                    application.registerUserNotificationSettings(
                        UIUserNotificationSettings(
                            types: [.alert, .badge, .sound],
                            categories: nil))
                    
                    application.registerForRemoteNotifications();
                    
                } else {
                    application.registerForRemoteNotifications();
                }
            }
        }
        //推送反馈(app不在前台运行时，点击推送激活时)
        XGPush.handleLaunching(launchOptions)
        return true
    }
    
    // 远程推送注册成功，获取deviceToken
    
    func application(_ application: UIApplication , didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        let  deviceTokenStr : String = XGPush.registerDevice(deviceToken);
        
        print(deviceTokenStr)
        
    }
    
    // 远程推送注册失败
    
    func application(_ application: UIApplication , didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
//        if error.code == 3010 {
//            
//            print ( "Push notifications are not supported in the iOS Simulator." )
//            
//        } else {
//            
//            print ( "application:didFailToRegisterForRemoteNotificationsWithError: \(error) " )
//            
//        }

    }
    //app在前台运行时收到远程通知
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        print(userInfo)
        
        XGPush.handleReceiveNotification(userInfo);
        let dict =  userInfo["aps"]! as! NSDictionary
        let messageA = dict["alert"] as! String
        print(messageA)
        DispatchQueue.main.async(execute: {
            let optionMenu = UIAlertController(title: "推送通知", message: messageA, preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "确定", style: .destructive, handler: {
               (alert: UIAlertAction!) -> Void in
                let VC = ProgrammeCollectionViewController()
                LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(saveAction)
            optionMenu.addAction(cancelAction)
            self.window?.rootViewController?.present(optionMenu, animated: true, completion: nil)
            
        })
        
    }
    
    
    
    //收到本地通知
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        application.cancelAllLocalNotifications()
        
    }

    func startShowStory() {

        let storyboard = UIStoryboard(name: "Show", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "ShowNavigationController") as! UINavigationController
        window?.rootViewController = rootViewController
    }
    
    func startMainStory() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        window?.rootViewController = rootViewController
    }
    
    func startMusicStory() {
        
        let storyboard = UIStoryboard(name: "MusicPlayer", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "MusicNavigationController") as! UINavigationController
        window?.rootViewController = rootViewController
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("WillResignActive")
        application.applicationIconBadgeNumber -= 1
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("DidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("Foreground")
    }
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        print("DidFinishLaunching")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("WillTerminate")
        let musicPlayerController = LoveqClient.sharedInstance.centerViewController
        print("\(musicPlayerController?.musicPlayer.currentTime)")
        let userDefaults = UserDefaults.standard
        userDefaults.set((musicPlayerController?.musicPlayer.currentTime)!, forKey: (musicPlayerController?.programTitle.text)!)
        
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == UIEventType.remoteControl {
            switch event!.subtype {
            case .remoteControlPause:
                let vc = LoveqClient.sharedInstance.centerViewController
                print(vc!.fileURL)
                vc!.musicPlayer.pause()
                break
            case .remoteControlPlay:
                LoveqClient.sharedInstance.centerViewController!.playAudio()
                break
            case .remoteControlTogglePlayPause:
                let vc = LoveqClient.sharedInstance.centerViewController
                vc!.remoteControl()
                break
            case .remoteControlPreviousTrack:
                LoveqClient.sharedInstance.centerViewController!.playPrevious()
                break
            case .remoteControlNextTrack:
                LoveqClient.sharedInstance.centerViewController!.playNext()
                break
            case .remoteControlStop:

                break
            default:
                break
            }
        }
            
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "0" {
            let shareController = LoveqConfig.shareToNetwork()
            LoveqClient.sharedInstance.centerNavigation?.present(shareController, animated: true, completion: nil)
        }else{
            let VC = ProgrammeCollectionViewController()
            LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
        }
        
    }


    
    func downloadFinishedNotification(_ notification : Notification) {

        if  UIApplication.shared.applicationState == UIApplicationState.active{
            let fileName = notification.object as! String
            let url = URL.init(string: fileName)
            HUD.flash(.labeledSuccess(title: "", subtitle: "\((url?.lastPathComponent)!)下载完成！"), delay: 1.0)
        } 
        
    }

}

