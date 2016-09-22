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
    
    private var _tableView :UITableView!
    
    var frostedView = FXBlurView()
    
    var backgroundImageView:UIImageView?
    
    var reviewStatu: Bool?
    
    private let ID = "cell"
    private var dataArray: [String] = []
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.frame = CGRectMake( 0, 100, 180, LoveqConfig.screenH)
            _tableView.backgroundColor = UIColor.clearColor()
            _tableView.estimatedRowHeight=200
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            _tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ID)
            _tableView.delegate = self
            _tableView.dataSource = self
            return _tableView!;
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        backgroundImageView = UIImageView()
        backgroundImageView!.frame = self.view.frame
        backgroundImageView!.contentMode = .ScaleToFill
        view.addSubview(backgroundImageView!)
        frostedView.underlyingView = backgroundImageView!
        frostedView.dynamic = false
        frostedView.tintColor = UIColor.whiteColor()
        frostedView.frame = self.view.frame
        view.addSubview(frostedView)
        view.addSubview(tableView)
        
        
    }
    override func viewWillAppear(animated: Bool) {
        reviewStatu = NSUserDefaults.standardUserDefaults().objectForKey("reviewStatu") as? Bool
        dataArray = ["全部节目","分享","更多"]
        if reviewStatu != nil {
            if !reviewStatu! {
                dataArray = ["全部节目","正在下载","分享","更多"]
            }
        }
        tableView.reloadData()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: ID)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 16.0)!
        cell.textLabel?.text =  dataArray[indexPath.row]
        cell.textLabel?.textColor = UIColor.lightGrayColor()
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if reviewStatu != nil {
            if !reviewStatu! {
                switch indexPath.row {
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
                        self.presentViewController(shareController, animated: true, completion: nil)
                        break
                    case 3:
                        let vc = PrivateSettingViewController.init(style: UITableViewStyle.Grouped)
                        LoveqClient.sharedInstance.centerNavigation?.pushViewController(vc, animated: true)
                        break
                    default:
                        return
                
                }
            }else{
                switch indexPath.row {
                    
                case 0:
                    let VC = ProgrammeCollectionViewController()
                    LoveqClient.sharedInstance.centerNavigation?.pushViewController(VC, animated: true)
                    break
                case 1:
                    let shareController = LoveqConfig.shareToNetwork()
                    self.presentViewController(shareController, animated: true, completion: nil)
                    break
                case 2:
                    let vc = PrivateSettingViewController.init(style: UITableViewStyle.Grouped)
                    LoveqClient.sharedInstance.centerNavigation?.pushViewController(vc, animated: true)
                    break
                default:
                    return
                }
            }
        }
        LoveqClient.sharedInstance.drawerController?.closeDrawerAnimated(true, completion: nil)
    }

    func shareToNetwork(){
        let profileURL = NSURL(string: "http://itunes.apple.com/app/id1123325463"), nickname = "LoveqSwift一些事一些情"
        let thumbnail: UIImage? = UIImage()
        let info = MonkeyKing.Info(
            //title: String(format:NSLocalizedString("Yep! I'm %@.", comment: ""), nickname),
            title: nickname,
            description: NSLocalizedString("纯粹、简约的聆听体验.", comment: ""),
            thumbnail: thumbnail,
            media: .URL(profileURL!)
        )

        let sessionMessage = MonkeyKing.Message.WeChat(.Session(info: info))

        let weChatSessionActivity = WeChatActivity(
            type: .Session,
            message: sessionMessage,
            completionHandler: { success in
                print("share Profile to WeChat Session success: \(success)")
            }
        )

        let timelineMessage = MonkeyKing.Message.WeChat(.Timeline(info: info))

        let weChatTimelineActivity = WeChatActivity(
            type: .Timeline,
            message: timelineMessage,
            completionHandler: { success in
                print("share Profile to WeChat Timeline success: \(success)")
            }
        )
        let activityViewController = UIActivityViewController(activityItems:["\(nickname), \(NSLocalizedString("LoveqSwift - 简约、纯粹的聆听体验", comment: "")) \(profileURL!)"], applicationActivities: [weChatSessionActivity, weChatTimelineActivity])
        activityViewController.excludedActivityTypes = [UIActivityTypeMail, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact,UIActivityTypeMessage];
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
