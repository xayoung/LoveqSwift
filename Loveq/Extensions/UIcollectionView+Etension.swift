//
//  UIcollectionView+Etension.swift
//  Loveq
//
//  Created by xayoung on 16/6/10.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit

extension NSObject {
    /**
     当前的类名字符串
     
     - returns: 当前类名的字符串
     */
    public class func cellIdentifier() -> String {
        return "\(self)";
    }
}

func regCollectionViewClass(collectionView:UICollectionView, cell:AnyClass) -> Void {
    collectionView.registerClass( cell, forCellWithReuseIdentifier: cell.cellIdentifier());
}

func getCollectionViewCell<T: UICollectionViewCell>(collectionView:UICollectionView ,cell: T.Type ,indexPath:NSIndexPath) -> T {
    return collectionView.dequeueReusableCellWithReuseIdentifier("\(cell)", forIndexPath: indexPath) as! T ;
}