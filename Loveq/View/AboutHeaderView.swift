//
//  AboutHeaderView.swift
//  Loveq
//
//  Created by xayoung on 16/6/20.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit

class AboutHeaderView: UITableViewHeaderFooterView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var appIcon: UIImageView?
    var appLabel: UILabel?
    var programmerLabel: UILabel?
    var designerLabel: UILabel?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {

        let icon = UIImage.init(named: "logo-180")
        appIcon = UIImageView.init(image: icon)
        self.addSubview(appIcon!)
        appIcon?.snp_makeConstraints{ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(10)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }

        appLabel = UILabel()
        appLabel?.font = UIFont.systemFontOfSize(18.0)
        appLabel?.text = "LoveqSwift"
        self.addSubview(appLabel!)
        appLabel?.snp_makeConstraints{ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo((appIcon?.snp_bottom)!).offset(8)
        }

        programmerLabel = UILabel()
        programmerLabel?.font = UIFont.systemFontOfSize(14.0)
        programmerLabel?.text = "Programmer:@Xayoung"
        self.addSubview(programmerLabel!)
        programmerLabel?.snp_makeConstraints{ (make) in
            make.centerX.equalTo(self)
            make.top.equalTo((appLabel?.snp_bottom)!).offset(8)
        }

        designerLabel = UILabel()
        designerLabel?.font = UIFont.systemFontOfSize(14.0)
        designerLabel?.text = "Designer:@嘉児君"
        self.addSubview(designerLabel!)
        designerLabel?.snp_makeConstraints{ (make) in
            make.left.equalTo((programmerLabel?.snp_left)!)
            make.top.equalTo((programmerLabel?.snp_bottom)!).offset(8)
        }

    }

}
