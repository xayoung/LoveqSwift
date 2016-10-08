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
        self.title?.font = UIFont.systemFont(ofSize: 16.0)
        self.contentView.addSubview(title!)
        self.title?.snp.makeConstraints{ (make) in
            make.top.equalTo(self.contentView).offset(8)
            make.left.equalTo(self.contentView).offset(16)
        }
        
        self.details = UILabel()
        self.details?.font = UIFont.systemFont(ofSize: 14.0)
        self.contentView.addSubview(details!)
        self.details?.snp.makeConstraints{ (make) in
            make.top.equalTo(self.title!.snp.bottom).offset(4)
            make.left.equalTo(self.title!.snp.left)
        }
        self.progressDownload = UIProgressView()
        self.contentView.addSubview(progressDownload!)
        self.progressDownload?.progressTintColor = UIColor.red
        self.progressDownload?.snp.makeConstraints{ (make) in
            make.top.equalTo(self.details!.snp.bottom).offset(4)
            make.left.equalTo(self.title!.snp.left)
            make.right.equalTo(self.contentView).offset(-8)
            make.height.equalTo(2)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateCellForRowAtIndexPath(_ indexPath : IndexPath, downloadModel: MZDownloadModel) {
        self.title?.text = "文件名:\(downloadModel.fileName)"
        self.progressDownload?.progress = downloadModel.progress
        var remainingTime: String = ""
        if downloadModel.progress == 1.0 {
            remainingTime = "Please wait..."
        } else if let _ = downloadModel.remainingTime {
            if (downloadModel.remainingTime?.hours)! > 0 {
                remainingTime = "\(downloadModel.remainingTime!.hours) Hours "
            }
            if (downloadModel.remainingTime?.minutes)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.minutes) Min "
            }
            if (downloadModel.remainingTime?.seconds)! > 0 {
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
        
        detailLabelText.appendFormat("大小:\(fileSize)(%.2f%%)" as NSString, downloadModel.progress * 100.0)
        details?.text = detailLabelText as String
    }

}
