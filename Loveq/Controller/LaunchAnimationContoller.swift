//
//  LaunchAnimationContoller.swift
//  Loveq
//
//  Created by xayoung on 16/6/19.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import DrawerController
import pop

class LaunchAnimationContoller: UIViewController {
    
    var hugoImageView: UIImageView? = nil
    var chiImageView: UIImageView? = nil
    var drawerController: DrawerController!
    override func viewDidLoad() {
        
        print("动画")
        self.view.backgroundColor = UIColor.white


        hugoImageView = UIImageView.init(frame: CGRect(x: 50, y: 50, width: 120, height: 172))
        let hugoImg = UIImage.init(named: "hugo")
        hugoImageView!.image = hugoImg
        hugoImageView?.alpha = 0;
        self.view.addSubview(hugoImageView!)
        chiImageView = UIImageView.init(frame: CGRect(x: 150, y: 50, width: 120, height: 172))
        let chiImg = UIImage.init(named: "chi")
        chiImageView!.image = chiImg
        chiImageView?.alpha = 0;
        self.view.addSubview(chiImageView!)

        let storyboard = UIStoryboard(name: "MusicPlayer", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "MusicNavigationController") as! LoveqNavigationController
        let centerNav = rootViewController
        let leftViewController = LeftViewController()
        let rightViewController = DownloadedViewController()
        drawerController = DrawerController(centerViewController: centerNav, leftDrawerViewController: leftViewController , rightDrawerViewController: rightViewController)
        drawerController.maximumLeftDrawerWidth=180
        drawerController.maximumRightDrawerWidth=220
        drawerController.openDrawerGestureModeMask=OpenDrawerGestureMode.all
        drawerController.closeDrawerGestureModeMask=CloseDrawerGestureMode.all
        LoveqClient.sharedInstance.drawerController = drawerController
        LoveqClient.sharedInstance.centerViewController = centerNav.viewControllers[0] as? MusicViewController
        LoveqClient.sharedInstance.centerNavigation = centerNav
        LoveqClient.sharedInstance.downloadingController = DownloadingViewController()
    }
    
    
    func startAnimation(_ view: UIView?,delay: TimeInterval) {
        
        UIView.animate(withDuration: 0.3, delay: delay, options: .transitionCrossDissolve, animations: {
            view!.alpha = 1;
            view!.transform = CGAffineTransform(translationX: 0, y: 200)
            }) { (true) in
                let animation = POPSpringAnimation.init(propertyNamed: kPOPLayerPosition)
                let point = CGPoint.init(x: 0, y: 300)
                animation?.velocity = NSValue.init(cgPoint: point)
                animation?.dynamicsTension = 10.0;
                animation?.dynamicsFriction = 1.0;
                animation?.springBounciness = 12.0;
                view!.layer.pop_add(animation, forKey: "layerPositionAnimation")
                if view == self.chiImageView{
                    self.jumpToMusicController()
                }
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        startAnimation(hugoImageView,  delay: 0)
        startAnimation(chiImageView,  delay: 0.5)
    }
    func jumpToMusicController() {

        let UIWindow = LoveqClient.sharedInstance.loveqUIWindow
        UIWindow?.rootViewController = drawerController
        UIWindow?.makeKeyAndVisible()
    }
}
