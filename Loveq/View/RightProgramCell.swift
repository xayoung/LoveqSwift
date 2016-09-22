//
//  RightProgramCell.swift
//  Loveq
//
//  Created by xayoung on 16/6/2.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

class RightProgramCell: UITableViewCell {

    var NO: UILabel?
    var title: UILabel?
    var timeImg: UIImageView?
    var time: UILabel?
    var playingAnimationView: NVActivityIndicatorView?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup()->Void{
        self.selectionStyle = .None
        self.backgroundColor = UIColor.clearColor()
        
        self.NO = UILabel()
        self.NO?.textColor = UIColor.lightGrayColor()
        self.contentView.addSubview(NO!)
        self.NO!.snp_makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(20)
            make.height.equalTo(25)
            make.width.equalTo(20)
        }
        
        self.title = UILabel()
        self.contentView.addSubview(title!)
        self.title!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.NO!.snp_right).offset(8)
            make.top.equalTo(10)
        }
        
        self.timeImg = UIImageView()
        self.timeImg?.image = UIImage.init(named: "ic_clock")
        self.contentView.addSubview(timeImg!)
        self.timeImg!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.title!.snp_left)
            make.bottom.equalTo(-10)
        }
        
        
        self.time = UILabel()
        self.time?.textColor = UIColor.lightGrayColor()
        self.time?.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)!
        self.contentView.addSubview(time!)
        self.time!.snp_makeConstraints{ (make) -> Void in
            make.left.equalTo(self.timeImg!.snp_right).offset(4)
            make.centerY.equalTo(self.timeImg!)
        }
        
        self.playingAnimationView = NVActivityIndicatorView.init(frame: CGRectMake(0, 0, 20, 30), type: NVActivityIndicatorType.LineScalePulseOut, color: UIColor.redColor())
        self.contentView.addSubview(playingAnimationView!)
        self.playingAnimationView!.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-20)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
}
