//
//  LoveqNavigationController.swift
//  Loveq
//
//  Created by xayoung on 16/5/29.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit

class LoveqNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = UIColor.redColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]
        
        let nav = UINavigationBar.appearance()
        //取消nav下的边框线
        nav.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        nav.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
