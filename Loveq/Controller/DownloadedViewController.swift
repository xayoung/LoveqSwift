//
//  DownloadedViewController.swift
//  Loveq
//
//  Created by xayoung on 16/5/15.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import MZDownloadManager
import SnapKit

class DownloadedViewController: UITableViewController {
    
    var downloadedFilesArray: [String] = []
    var selectedIndexPath: NSIndexPath?
    var fileManger: NSFileManager = NSFileManager.defaultManager()
    var ID = "DownloadedFileCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init(frame: CGRectZero)
        regClass(self.tableView, cell: RightProgramCell.self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: MZUtility.DownloadCompletedNotif as String, object: nil)
        loadFileAppendArray()
    }
    
    func loadFileAppendArray() {
        downloadedFilesArray.removeAll()
        do {
            let contentOfDir: [String] = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(MZUtility.baseFilePath as String)
            var contentOfDir2: [String] = [String]()
            for str in contentOfDir{
                if (str as NSString).containsString(".mp3") {
                    contentOfDir2.append(str)
                }
            }
            downloadedFilesArray.appendContentsOf(contentOfDir2)
            
            let index = downloadedFilesArray.indexOf(".DS_Store")
            if let index = index {
                downloadedFilesArray.removeAtIndex(index)
            }
            
        } catch let error as NSError {
            print("Error while getting directory content \(error)")
        }
    }
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(notification : NSNotification) {
        loadFileAppendArray()
        tableView.reloadData()
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        tableView.setEditing(false, animated: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        LoveqClient.sharedInstance.centerViewController?.setupMusiclist()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.setEditing(false, animated: true)
    }
    
    func editFile(button :UIButton)  {
        if  button.selected {
            button.selected = false
            tableView.reloadData()
        }else{
            button.selected = true
            tableView.setEditing(true, animated: true)
        }
    }

}


//MARK: UITableViewDataSource Handler Extension

extension DownloadedViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRectMake(0, 0, LoveqConfig.screenW, 60))
        headerView.backgroundColor = UIColor.whiteColor()
        let mainTitle = UILabel()
        mainTitle.font = UIFont.systemFontOfSize(16.0)
        let title = "我的节目(" + String(downloadedFilesArray.count)
        mainTitle.text = title + ")"
        headerView.addSubview(mainTitle)
        mainTitle.snp_makeConstraints { (make) in
            make.top.equalTo(headerView).offset(35)
            make.centerX.equalTo(headerView)
        }
        let editButton = UIButton.init(type: UIButtonType.Custom)
        editButton.setTitle("管理", forState: UIControlState.Normal)
        editButton.setTitle("返回", forState: UIControlState.Selected)
        editButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        editButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        editButton.addTarget(self, action: #selector(DownloadedViewController.editFile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(editButton)
        editButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(mainTitle)
            make.left.equalTo(mainTitle.snp_right).offset(20)
        }
        return headerView
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedFilesArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let musicName = downloadedFilesArray[indexPath.row]
        let cell = getCell(tableView, cell: RightProgramCell.self, indexPath: indexPath)
        let fileURL  : NSURL = NSURL(fileURLWithPath: (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(musicName as String))
        cell.NO?.text = String(indexPath.row + 1)
        cell.title?.text = (musicName as NSString).substringToIndex(10)
        let musicPlayer = LoveqClient.sharedInstance.centerViewController?.musicPlayer
        
        print((musicName as NSString).substringToIndex(10))
        if LoveqClient.sharedInstance.centerViewController?.programTitle.text == ((musicName as NSString).substringToIndex(10) + "期") {
            cell.title?.textColor = UIColor.redColor()
            cell.time?.textColor = UIColor.redColor()
            if LoveqClient.sharedInstance.centerViewController?.fileURL != nil {
                if musicPlayer!.playing{
                    cell.playingAnimationView?.startAnimating()
                }else{
                    cell.playingAnimationView?.stopAnimating()
                }
            }
            
        }else{
            cell.title?.textColor = UIColor.blackColor()
            cell.time?.textColor = UIColor.lightGrayColor()
            cell.playingAnimationView?.stopAnimating()
        }
        
        cell.time?.text = String(LoveqConfig.durationWithAudio(fileURL))
        return cell
    }
}

//MARK: UITableViewDelegate Handler Extension

extension DownloadedViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        selectedIndexPath = indexPath
        NSNotificationCenter.defaultCenter().postNotificationName("playMusic", object: indexPath)
        LoveqClient.sharedInstance.drawerController?.closeDrawerAnimated(true, completion: nil)
        tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let fileName : NSString = downloadedFilesArray[indexPath.row] as NSString
        let fileURL  : NSURL = NSURL(fileURLWithPath: (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(fileName as String))
        
        do {
            try fileManger.removeItemAtURL(fileURL)
            downloadedFilesArray.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
        } catch let error as NSError {
            debugPrint("Error while deleting file: \(error)")
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
}
