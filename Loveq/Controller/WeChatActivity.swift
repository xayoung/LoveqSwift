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

    enum `Type` {

        case session
        case timeline

        var type: String {
            switch self {
            case .session:
                return "cn.xayoung.WeChat.Session"
            case .timeline:
                return "cn.xayoung.WeChat.Timeline"
            }
        }

        var title: String {
            switch self {
            case .session:
                return NSLocalizedString("微信好友", comment: "")
            case .timeline:
                return NSLocalizedString("微信朋友圈", comment: "")
            }
        }

        var image: UIImage {
            switch self {
            case .session:
                return UIImage(named: "wechat_session")!
            case .timeline:
                return UIImage(named: "wechat_timeline")!
            }
        }
    }

    init(type: Type, message: MonkeyKing.Message, completionHandler: @escaping MonkeyKing.DeliverCompletionHandler) {

        MonkeyKing.registerAccount(.weChat(appID: shareConfigs.Wechat.appID, appKey: ""))

        super.init(
            type: UIActivityType(rawValue: type.type),
            title: type.title,
            image: type.image,
            message: message,
            completionHandler: completionHandler
        )
    }
}

