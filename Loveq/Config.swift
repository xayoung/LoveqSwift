//
//  Config.swift
//  Loveq
//
//  Created by xayoung on 16/5/25.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import AVFoundation
import MonkeyKing

class LoveqConfig {
    static let WilddogURL = "https://loveq.wilddogio.com/program/"
    static let screenW = UIScreen.main.bounds.size.width
    static let screenH = UIScreen.main.bounds.size.height
    
    class func durationWithAudio(_ url: URL) -> String {
        let urlAsset = AVAsset.init(url: url)
        let audioDuration = urlAsset.duration
        let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        
        return Tools.calculateTime(audioDurationSeconds)
    }

    class func VersionString() ->String {
        let dict = Bundle.main.infoDictionary
        let string = "Version \(dict!["CFBundleShortVersionString"]!) (Build\(dict!["CFBundleVersion"]!))"
        return string
    }

    class func shareToNetwork() ->UIActivityViewController{
        let profileURL = URL(string: "http://itunes.apple.com/app/id1123325463"), nickname = "LoveqSwift 《一些事一些情》"
        let thumbnail: UIImage? = UIImage()
        let info = MonkeyKing.Info(
            title: nickname,
            description: NSLocalizedString("最纯粹的《一些事一些情》下载播放器.", comment: ""),
            thumbnail: thumbnail,
            media: .url(profileURL!)
        )

        let sessionMessage = MonkeyKing.Message.weChat(.session(info: info))

        let weChatSessionActivity = WeChatActivity(
            type: .session,
            message: sessionMessage,
            completionHandler: { success in
                print("share Profile to WeChat Session success: \(success)")
            }
        )

        let timelineMessage = MonkeyKing.Message.weChat(.timeline(info: info))

        let weChatTimelineActivity = WeChatActivity(
            type: .timeline,
            message: timelineMessage,
            completionHandler: { success in
                print("share Profile to WeChat Timeline success: \(success)")
            }
        )
        let activityViewController = UIActivityViewController(activityItems:["\(nickname), \(NSLocalizedString("LoveqSwift - 简约、纯粹的聆听体验", comment: "")) \(profileURL!)"], applicationActivities: [weChatSessionActivity, weChatTimelineActivity])
        activityViewController.excludedActivityTypes = [UIActivityType.mail, UIActivityType.addToReadingList, UIActivityType.assignToContact,UIActivityType.message];
        return activityViewController
    }

}

class Tools  {
    class func calculateTime(_ time: TimeInterval) -> String {
        let hour_   = abs(Int(time)/3600)
        let minute_ = abs(Int((time/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(time.truncatingRemainder(dividingBy: 60)))
        
        let hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return "\(hour):\(minute):\(second)"
    }
}

struct shareConfigs {

    struct Wechat {
        static let appID = "wxd3887d2988ee48f5"
        static let appKey = "fdb21b6827fb33c3880f779df2ccffee"
    }

}
