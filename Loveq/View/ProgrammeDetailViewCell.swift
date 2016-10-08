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
    func downloadMusicAction(_ model: ProgrammerListModel)
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

    override func setSelected(_ selected: Bool, animated: Bool) {
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
        title?.font = UIFont.systemFont(ofSize: 16.0)
        title?.textColor = UIColor.black
        self.addSubview(title!)
        title?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo(self.snp.left).offset(50)
        })
        
        indexNum = UILabel()
        indexNum?.font = UIFont.systemFont(ofSize: 12.0)
        indexNum?.textColor = UIColor.lightGray
        self.addSubview(indexNum!)
        indexNum?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo(self.snp.left).offset(20)
        })
        
        ActionImg = UIButton()
        ActionImg?.isHidden = false
        ActionImg?.setImage(UIImage.init(named: "ic_downloaded"), for: UIControlState())
        ActionImg?.addTarget(self, action: NSSelectorFromString("downloadButtonClick"), for: .touchUpInside)
        contentView.addSubview(ActionImg!)
        ActionImg?.snp.makeConstraints({ (make) in
            make.centerY.equalTo(contentView.snp.centerY)
            make.right.equalTo(contentView.snp.right).offset(-16)
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
