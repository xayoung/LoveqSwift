//
//  NSMutableArray+X.swift
//  Loveq
//
//  Created by xayoung on 16/4/16.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import Foundation


extension NSMutableArray {
    
    open override func description(withLocale locale: Any?) -> String {
        var str = "(\n"
        
        [self .enumerateObjects({
            str += "\t\($0.0), \n"
        })]
        
        str += ")"
        
        return str
    }
}
