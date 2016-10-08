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

func regCollectionViewClass(_ collectionView:UICollectionView, cell:AnyClass) -> Void {
    collectionView.register( cell, forCellWithReuseIdentifier: cell.cellIdentifier());
}

func getCollectionViewCell<T: UICollectionViewCell>(_ collectionView:UICollectionView ,cell: T.Type ,indexPath:IndexPath) -> T {
    return collectionView.dequeueReusableCell(withReuseIdentifier: "\(cell)", for: indexPath) as! T ;
}
