//
//  NSMutableArray+X.swift
//  Loveq
//
//  Created by xayoung on 16/4/16.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import Foundation


extension NSMutableArray {
    
    public override func descriptionWithLocale(locale: AnyObject?) -> String {
        var str = "(\n"
        
        [self .enumerateObjectsUsingBlock({
            str += "\t\($0.0), \n"
        })]
        
        str += ")"
        
        return str
    }
}
