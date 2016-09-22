//
//  DownloadingCell.swift
//  Loveq
//
//  Created by xayoung on 16/6/12.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import MZDownloadManager

class DownloadingCell: UITableViewCell {

    var title : UILabel?
    var details : UILabel?
    var progressDownload : UIProgressView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() -> Void {
        self.title = UILabel()
        self.title?.font = UIFont.systemFontOfSize(16.0)
        self.contentView.addSubview(title!)
        self.title?.snp_makeConstraints{ (make) in
            make.top.equalTo(self.contentView).offset(8)
            make.left.equalTo(self.contentView).offset(16)
        }
        
        self.details = UILabel()
        self.details?.font = UIFont.systemFontOfSize(14.0)
        self.contentView.addSubview(details!)
        self.details?.snp_makeConstraints{ (make) in
            make.top.equalTo(self.title!.snp_bottom).offset(4)
            make.left.equalTo(self.title!.snp_left)
        }
        self.progressDownload = UIProgressView()
        self.contentView.addSubview(progressDownload!)
        self.progressDownload?.progressTintColor = UIColor.redColor()
        self.progressDownload?.snp_makeConstraints{ (make) in
            make.top.equalTo(self.details!.snp_bottom).offset(4)
            make.left.equalTo(self.title!.snp_left)
            make.right.equalTo(self.contentView).offset(-8)
            make.height.equalTo(2)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateCellForRowAtIndexPath(indexPath : NSIndexPath, downloadModel: MZDownloadModel) {
        self.title?.text = "文件名:\(downloadModel.fileName)"
        self.progressDownload?.progress = downloadModel.progress
        var remainingTime: String = ""
        if downloadModel.progress == 1.0 {
            remainingTime = "Please wait..."
        } else if let _ = downloadModel.remainingTime {
            if downloadModel.remainingTime?.hours > 0 {
                remainingTime = "\(downloadModel.remainingTime!.hours) Hours "
            }
            if downloadModel.remainingTime?.minutes > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.minutes) Min "
            }
            if downloadModel.remainingTime?.seconds > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.seconds) sec"
            }
        } else {
            remainingTime = "计算中..."
        }
        
        var fileSize = "Getting information..."
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.2f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }
        
        let detailLabelText = NSMutableString()
        
        detailLabelText.appendFormat("大小:\(fileSize)(%.2f%%)", downloadModel.progress * 100.0)
        details?.text = detailLabelText as String
    }

}
