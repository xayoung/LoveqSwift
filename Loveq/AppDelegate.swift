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
import Wilddog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var backgroundSessionCompletionHandler : (() -> Void)?
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: MZUtility.DownloadCompletedNotif as String, object: nil)
        
        let storyboard = UIStoryboard(name: "MusicPlayer", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("MusicNavigationController") as! LoveqNavigationController
        let centerNav = rootViewController
        let leftViewController = LeftViewController()
        let rightViewController = DownloadedViewController()
        let drawerController = DrawerController(centerViewController: centerNav, leftDrawerViewController: leftViewController , rightDrawerViewController: rightViewController)
        drawerController.maximumLeftDrawerWidth=180
        drawerController.maximumRightDrawerWidth=220
        drawerController.openDrawerGestureModeMask=OpenDrawerGestureMode.All
        drawerController.closeDrawerGestureModeMask=CloseDrawerGestureMode.All
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
                
                if (UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))){
                    
                    application.registerUserNotificationSettings(
                        UIUserNotificationSettings(
                            forTypes: [.Alert, .Badge, .Sound],
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
    
    func application(application: UIApplication , didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        let  deviceTokenStr : String = XGPush.registerDevice(deviceToken);
        
        print(deviceTokenStr)
        
    }
    
    // 远程推送注册失败
    
    func application(application: UIApplication , didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        
        if error.code == 3010 {
            
            print ( "Push notifications are not supported in the iOS Simulator." )
            
        } else {
            
            print ( "application:didFailToRegisterForRemoteNotificationsWithError: \(error) " )
            
        }
        
    }
    //app在前台运行时收到远程通知
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print(userInfo)
        
        XGPush.handleReceiveNotification(userInfo);

        let messageA = userInfo["aps"]!["alert"] as! String
        print(messageA)
        dispatch_async(dispatch_get_main_queue(), {
            let optionMenu = UIAlertController(title: "推送通知", message: messageA, preferredStyle: .Alert)
            let saveAction = UIAlertAction(title: "确定", style: .Destructive, handler: {
               (alert: UIAlertAction!) -> Void in
                let VC = ProgrammeCollectionViewController()
                LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
                (alert: UIAlertAction!) -> Void in
            })
            
            optionMenu.addAction(saveAction)
            optionMenu.addAction(cancelAction)
            self.window?.rootViewController?.presentViewController(optionMenu, animated: true, completion: nil)
            
        })
        
    }
    
    
    
    //收到本地通知
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        application.cancelAllLocalNotifications()
        
    }

    func startShowStory() {

        let storyboard = UIStoryboard(name: "Show", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("ShowNavigationController") as! UINavigationController
        window?.rootViewController = rootViewController
    }
    
    func startMainStory() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        window?.rootViewController = rootViewController
    }
    
    func startMusicStory() {
        
        let storyboard = UIStoryboard(name: "MusicPlayer", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("MusicNavigationController") as! UINavigationController
        window?.rootViewController = rootViewController
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        print("WillResignActive")
        application.applicationIconBadgeNumber -= 1
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("DidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("Foreground")
    }
    
    func applicationDidFinishLaunching(application: UIApplication) {
        print("DidFinishLaunching")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("WillTerminate")
        let musicPlayerController = LoveqClient.sharedInstance.centerViewController
        print("\(musicPlayerController?.musicPlayer.currentTime)")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble((musicPlayerController?.musicPlayer.currentTime)!, forKey: (musicPlayerController?.programTitle.text)!)
        
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        backgroundSessionCompletionHandler = completionHandler
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case .RemoteControlPause:
                let vc = LoveqClient.sharedInstance.centerViewController
                print(vc!.fileURL)
                vc!.musicPlayer.pause()
                break
            case .RemoteControlPlay:
                LoveqClient.sharedInstance.centerViewController!.playAudio()
                break
            case .RemoteControlTogglePlayPause:
                let vc = LoveqClient.sharedInstance.centerViewController
                vc!.remoteControl()
                break
            case .RemoteControlPreviousTrack:
                LoveqClient.sharedInstance.centerViewController!.playPrevious()
                break
            case .RemoteControlNextTrack:
                LoveqClient.sharedInstance.centerViewController!.playNext()
                break
            case .RemoteControlStop:

                break
            default:
                break
            }
        }
            
    }

    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if shortcutItem.type == "0" {
            let shareController = LoveqConfig.shareToNetwork()
            LoveqClient.sharedInstance.centerNavigation?.presentViewController(shareController, animated: true, completion: nil)
        }else{
            let VC = ProgrammeCollectionViewController()
            LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
        }
        
    }


    
    func downloadFinishedNotification(notification : NSNotification) {

        if  UIApplication.sharedApplication().applicationState == UIApplicationState.Active{
            let fileName = notification.object as! String
            let url = NSURL.init(string: fileName)
            HUD.flash(.LabeledSuccess(title: "", subtitle: "\((url?.lastPathComponent)!)下载完成！"), delay: 1.0)
        } 
        
    }

}

