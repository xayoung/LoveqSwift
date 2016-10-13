//
//  LeftViewController.swift
//  Loveq
//
//  Created by xayoung on 16/5/29.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import FXBlurView
import MonkeyKing

class LeftViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    fileprivate var _tableView :UITableView!
    
    var frostedView = FXBlurView()
    
    var backgroundImageView:UIImageView?
    
    var reviewStatu: Bool?
    
    fileprivate let ID = "cell"
    fileprivate var dataArray: [String] = []
    fileprivate var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.frame = CGRect( x: 0, y: 100, width: 180, height: LoveqConfig.screenH)
            _tableView.backgroundColor = UIColor.clear
            _tableView.estimatedRowHeight=200
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
            _tableView.register(UITableViewCell.self, forCellReuseIdentifier: ID)
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        backgroundImageView = UIImageView()
        backgroundImageView!.frame = self.view.frame
        backgroundImageView!.contentMode = .scaleToFill
        view.addSubview(backgroundImageView!)
        frostedView.underlyingView = backgroundImageView!
        frostedView.isDynamic = false
        frostedView.tintColor = UIColor.white
        frostedView.frame = self.view.frame
        view.addSubview(frostedView)
        view.addSubview(tableView)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        reviewStatu = UserDefaults.standard.object(forKey: "reviewStatu") as? Bool
        dataArray = ["全部节目","分享","更多"]
        if reviewStatu != nil {
            if !reviewStatu! {
                dataArray = ["全部节目","正在下载","分享","更多"]
            }
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: ID)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 16.0)!
        cell.textLabel?.text =  dataArray[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = UIColor.lightGray
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if reviewStatu != nil {
            if !reviewStatu! {
                switch (indexPath as NSIndexPath).row {
                    case 0:
                        let VC = ProgrammeCollectionViewController()
                        LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
                        break
                    case 1:
                        let downloadingVC = LoveqClient.sharedInstance.downloadingController
                        LoveqClient.sharedInstance.centerNavigation?.pushViewController(downloadingVC!, animated: true)
                        break
                    case 2:
                        let shareController = LoveqConfig.shareToNetwork()
                        self.present(shareController, animated: true, completion: nil)
                        break
                    case 3:
                        let vc = PrivateSettingViewController.init(style: UITableViewStyle.grouped)
                        LoveqClient.sharedInstance.centerNavigation?.pushViewController(vc, animated: true)
                        break
                    default:
                        return
                
                }
            }else{
                switch (indexPath as NSIndexPath).row {
                    
                case 0:
                    let VC = ProgrammeCollectionViewController()
                    LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
                    break
                case 1:
                    let shareController = LoveqConfig.shareToNetwork()
                    self.present(shareController, animated: true, completion: nil)
                    break
                case 2:
                    let vc = PrivateSettingViewController.init(style: UITableViewStyle.grouped)
                    LoveqClient.sharedInstance.centerNavigation?.pushViewController(vc, animated: true)
                    break
                default:
                    return
                }
            }
        }
        LoveqClient.sharedInstance.drawerController?.closeDrawer(animated: true, completion: nil)
    }

    func shareToNetwork(){
        let profileURL = URL(string: "http://itunes.apple.com/app/id1123325463"), nickname = "LoveqSwift一些事一些情"
        let thumbnail: UIImage? = UIImage()
        let info = MonkeyKing.Info(
            title: nickname,
            description: NSLocalizedString("纯粹、简约的聆听体验.", comment: ""),
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
        self.present(activityViewController, animated: true, completion: nil)
    }

}
