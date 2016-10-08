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
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        
        self.NO = UILabel()
        self.NO?.textColor = UIColor.lightGray
        self.contentView.addSubview(NO!)
        self.NO!.snp.makeConstraints{ (make) -> Void in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(20)
            make.height.equalTo(25)
            make.width.equalTo(20)
        }
        
        self.title = UILabel()
        self.contentView.addSubview(title!)
        self.title!.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.NO!.snp.right).offset(8)
            make.top.equalTo(10)
        }
        
        self.timeImg = UIImageView()
        self.timeImg?.image = UIImage.init(named: "ic_clock")
        self.contentView.addSubview(timeImg!)
        self.timeImg!.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.title!.snp.left)
            make.bottom.equalTo(-10)
        }
        
        
        self.time = UILabel()
        self.time?.textColor = UIColor.lightGray
        self.time?.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)!
        self.contentView.addSubview(time!)
        self.time!.snp.makeConstraints{ (make) -> Void in
            make.left.equalTo(self.timeImg!.snp.right).offset(4)
            make.centerY.equalTo(self.timeImg!)
        }
        
        self.playingAnimationView = NVActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 20, height: 30), type: NVActivityIndicatorType.lineScalePulseOut, color: UIColor.red)
        self.contentView.addSubview(playingAnimationView!)
        self.playingAnimationView!.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.right.equalTo(self.contentView).offset(-20)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
    }
}
