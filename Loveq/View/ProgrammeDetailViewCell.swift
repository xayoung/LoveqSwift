//
//  ProgrammeDetailViewCell.swift
//  Loveq
//
//  Created by xayoung on 16/6/20.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import SnapKit



protocol programmerDatailCellDelegate {
    func downloadMusicAction(model: ProgrammerListModel)
}

class ProgrammeDetailViewCell: UITableViewCell {
    let gradientLayer = CAGradientLayer()
    var ActionImg: UIButton?
    
    var title: UILabel?
    
    var indexNum: UILabel?
    
    var model: ProgrammerListModel?
    
    var delegate: programmerDatailCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

//        gradientLayer.frame = self.bounds
//        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
//        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
//        let color3 = UIColor.clearColor().CGColor as CGColorRef
//        let color4 = UIColor(white: 0.0, alpha: 0.05).CGColor as CGColorRef
//
//        gradientLayer.colors = [color1, color2, color3, color4]
//        gradientLayer.locations = [0.0, 0.04, 0.95, 1.0]
//        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        title = UILabel()
        title?.font = UIFont.systemFontOfSize(16.0)
        title?.textColor = UIColor.blackColor()
        self.addSubview(title!)
        title?.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(contentView.snp_centerY)
            make.left.equalTo(self.snp_left).offset(50)
        })
        
        indexNum = UILabel()
        indexNum?.font = UIFont.systemFontOfSize(12.0)
        indexNum?.textColor = UIColor.lightGrayColor()
        self.addSubview(indexNum!)
        indexNum?.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(contentView.snp_centerY)
            make.left.equalTo(self.snp_left).offset(20)
        })
        
        ActionImg = UIButton()
        ActionImg?.hidden = false
        ActionImg?.setImage(UIImage.init(named: "ic_downloaded"), forState: .Normal)
        ActionImg?.addTarget(self, action: NSSelectorFromString("downloadButtonClick"), forControlEvents: .TouchUpInside)
        contentView.addSubview(ActionImg!)
        ActionImg?.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(contentView.snp_centerY)
            make.right.equalTo(contentView.snp_right).offset(-16)
        })
    }
    
    func downloadButtonClick(){
        if (delegate != nil) {
            delegate?.downloadMusicAction(self.model!)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
//        gradientLayer.frame = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
