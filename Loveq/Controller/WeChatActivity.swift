//
//  WeChatActivity.swift
//  Loveq
//
//  Created by xayoung on 16/6/15.
//  Copyright © 2016年 xayoung. All rights reserved.
//
import UIKit
import MonkeyKing

class WeChatActivity: AnyActivity {

    enum Type {

        case Session
        case Timeline

        var type: String {
            switch self {
            case .Session:
                return "cn.xayoung.WeChat.Session"
            case .Timeline:
                return "cn.xayoung.WeChat.Timeline"
            }
        }

        var title: String {
            switch self {
            case .Session:
                return NSLocalizedString("微信好友", comment: "")
            case .Timeline:
                return NSLocalizedString("微信朋友圈", comment: "")
            }
        }

        var image: UIImage {
            switch self {
            case .Session:
                return UIImage(named: "wechat_session")!
            case .Timeline:
                return UIImage(named: "wechat_timeline")!
            }
        }
    }

    init(type: Type, message: MonkeyKing.Message, completionHandler: MonkeyKing.SharedCompletionHandler) {

        MonkeyKing.registerAccount(.WeChat(appID: shareConfigs.Wechat.appID, appKey: ""))

        super.init(
            type: type.type,
            title: type.title,
            image: type.image,
            message: message,
            completionHandler: completionHandler
        )
    }
}

