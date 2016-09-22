//
//  LoveqClient.swift
//  Loveq
//
//  Created by xayoung on 16/5/29.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import DrawerController

class LoveqClient: NSObject {
    static let sharedInstance = LoveqClient()
    
    var drawerController :DrawerController? = nil
    var centerViewController : MusicViewController? = nil
    var centerNavigation : LoveqNavigationController? = nil
    var downloadingController :DownloadingViewController? = nil
    var loveqUIWindow: UIWindow? = nil
    
    // 当前程序中，最上层的 NavigationController
    var topNavigationController : UINavigationController {
        get{
            return LoveqClient.getTopNavigationController(LoveqClient.sharedInstance.centerNavigation!)
        }
    }

    var oldProgramListJSON : NSDictionary{
        get{
            let data = NSData.init(contentsOfFile: NSBundle.mainBundle().pathForResource("programList.json", ofType: nil)!)
            let array = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            return array as! NSDictionary
        }
    }


    private class func getTopNavigationController(currentNavigationController:UINavigationController) -> UINavigationController {
        if let topNav = currentNavigationController.visibleViewController?.navigationController{
            if topNav != currentNavigationController && topNav.isKindOfClass(UINavigationController.self){
                return getTopNavigationController(topNav)
            }
        }
        return currentNavigationController
    }
}
