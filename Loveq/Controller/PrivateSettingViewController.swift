//
//  PrivateSettingViewController.swift
//  Loveq
//
//  Created by xayoung on 16/5/7.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit


class PrivateSettingViewController: UITableViewController {
    
    fileprivate let dataSourcePath = Bundle.main.path(forResource: "SettingSource", ofType: "plist")
    var dataArray = []
    let ID = "settingCell"
    let headerID = "headerView"
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil,bundle:nibBundleOrNil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        dataArray = NSArray(contentsOfFile:dataSourcePath!)! as! [Any]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ID)
        tableView.register(AboutHeaderView.self, forHeaderFooterViewReuseIdentifier: headerID)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataArray[section] as AnyObject).count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 200
        }else{
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = AboutHeaderView.init(reuseIdentifier: headerID)
        if section == 0 {
            return header
        }else{
            return nil
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: ID)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        let array = dataArray[(indexPath as NSIndexPath).section] as! NSArray
        cell.textLabel?.text = array[(indexPath as NSIndexPath).row] as? String
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14.0)
            cell.detailTextLabel?.text = LoveqConfig.VersionString()
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 0:
            if (indexPath as NSIndexPath).row == 0 {
                UIApplication.shared.openURL(URL.init(string: "https://itunes.apple.com/app/id1123325463/")!)
            }else if ((indexPath as NSIndexPath).row == 1){
                UIApplication.shared.openURL(URL.init(string: "http://www.xayoung.cn/2016/06/25/LoveqSwift%EF%BC%88%E4%BA%8C%EF%BC%89%EF%BC%9ALoveQ%E2%80%94%E2%80%94%E4%B8%AA%E4%BA%BA%E9%A1%B9%E7%9B%AE%E3%80%8A%E4%B8%80%E4%BA%9B%E4%BA%8B%E4%B8%80%E4%BA%9B%E6%83%85%E3%80%8B%E7%AC%AC%E4%B8%89%E6%96%B9APP/")!)
            }else{
                UIApplication.shared.openURL(URL.init(string: "http://www.loveq.cn/")!)
            }
        case 1:
            if (indexPath as NSIndexPath).row == 1 {
                let aboutLoveqAlertView = UIAlertController(title: "关于", message: "本app致力于提供节目收听以及纯净无广告的播放体验。所有节目内容均来至www.loveq.cn提供的公开引用资源，版权归www.loveq.cn所有。", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                })
                aboutLoveqAlertView.addAction(cancelAction)
                self.present(aboutLoveqAlertView, animated: true, completion: nil)
            }
        default:
            break
        }
    }
}
