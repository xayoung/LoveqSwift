//
//  ProgrammeCollectionCell.swift
//  Loveq
//
//  Created by xayoung on 16/6/9.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import SnapKit

class ProgrammeCollectionCell: UICollectionViewCell {
    
    var image: UIImageView?
    var year: UILabel?
    var programCount: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setup() -> Void {
        self.backgroundColor = UIColor.clearColor()
        
        self.image = UIImageView()
        self.contentView.addSubview(image!)
        self.image?.snp_makeConstraints{ (make) in
            make.centerX.equalTo(self.contentView)
//            make.width.equalTo(80)
//            make.height.equalTo(80)
        }
        
        self.year = UILabel()
        self.year?.font = UIFont.systemFontOfSize(14.0)
        self.contentView.addSubview(year!)
        self.year?.snp_makeConstraints{ (make) in
            make.centerX.equalTo(image!)
            make.top.equalTo((image?.snp_bottom)!)
            
        }
        
        self.programCount = UILabel()
        self.programCount?.font = UIFont.systemFontOfSize(14.0)
        self.programCount?.textColor = UIColor.lightGrayColor()
        self.contentView.addSubview(programCount!)
        self.programCount?.snp_makeConstraints{ (make) in
            make.centerX.equalTo(image!)
            make.top.equalTo((year?.snp_bottom)!)
            
        }
        
    }
}
