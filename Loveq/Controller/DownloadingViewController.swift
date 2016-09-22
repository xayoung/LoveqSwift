//
//  DownloadingViewController.swift
//  Loveq
//
//  Created by xayoung on 16/6/12.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import MZDownloadManager
import PKHUD

let alertControllerViewTag: Int = 500

class DownloadingViewController: UITableViewController {

    var selectedIndexPath : NSIndexPath!

    let cellIdentifier : String = "DownloadingCell"
    
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        regClass(self.tableView, cell: DownloadingCell.self)
        self.tableView.tableFooterView = UIView.init(frame: CGRectZero)
        self.title = "正在下载"
    }
    
    override func viewWillAppear(animated: Bool) {
        if downloadManager.downloadingArray.count == 0{
            HUD.flash(.Label("暂无下载任务"), delay: 1.0)
        }
    }

    func refreshCellForIndex(downloadModel: MZDownloadModel, index: Int) {
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            let downloadCell = cell as! DownloadingCell
            downloadCell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        }
    }
}
// MARK: UITableViewDatasource Handler Extension

extension DownloadingViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadManager.downloadingArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = getCell(self.tableView, cell: DownloadingCell.self, indexPath: indexPath)
        
        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        cell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        
        return cell
        
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}
// MARK: UITableViewDelegate Handler Extension

extension DownloadingViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath

        let downloadModel = downloadManager.downloadingArray[indexPath.row]
        self.showAppropriateActionController(downloadModel.status)

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}

// MARK: UIAlertController Handler Extension

extension DownloadingViewController {

    func showAppropriateActionController(requestStatus: String) {

        if requestStatus == TaskStatus.Downloading.description() {
            self.showAlertControllerForPause()
        } else if requestStatus == TaskStatus.Failed.description() {
            self.showAlertControllerForRetry()
        } else if requestStatus == TaskStatus.Paused.description() {
            self.showAlertControllerForStart()
        }
    }

    func showAlertControllerForPause() {

        let pauseAction = UIAlertAction(title: "暂停", style: .Default) { (alertAction: UIAlertAction) in
            self.downloadManager.pauseDownloadTaskAtIndex(self.selectedIndexPath.row)
        }

        let removeAction = UIAlertAction(title: "移除下载任务", style: .Destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(pauseAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func showAlertControllerForRetry() {

        let retryAction = UIAlertAction(title: "重置", style: .Default) { (alertAction: UIAlertAction) in
            self.downloadManager.retryDownloadTaskAtIndex(self.selectedIndexPath.row)
        }

        let removeAction = UIAlertAction(title: "移除下载任务", style: .Destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(retryAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func showAlertControllerForStart() {

        let startAction = UIAlertAction(title: "开始", style: .Default) { (alertAction: UIAlertAction) in
            self.downloadManager.resumeDownloadTaskAtIndex(self.selectedIndexPath.row)
        }

        let removeAction = UIAlertAction(title: "移除下载任务", style: .Destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }

        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(startAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func safelyDismissAlertController() {
        /***** Dismiss alert controller if and only if it exists and it belongs to MZDownloadManager *****/
        /***** E.g App will eventually crash if download is completed and user tap remove *****/
        /***** As it was already removed from the array *****/
        if let controller = self.presentedViewController {
            guard controller is UIAlertController && controller.view.tag == alertControllerViewTag else {
                return
            }
            controller.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

extension DownloadingViewController: MZDownloadManagerDelegate {

    func downloadRequestStarted(downloadModel: MZDownloadModel, index: Int) {
//        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
//        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        tableView.reloadData()
    }

    func downloadRequestDidPopulatedInterruptedTasks(downloadModels: [MZDownloadModel]) {
        tableView.reloadData()
    }

    func downloadRequestDidUpdateProgress(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }

    func downloadRequestDidPaused(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }

    func downloadRequestDidResumed(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }

    func downloadRequestCanceled(downloadModel: MZDownloadModel, index: Int) {

        self.safelyDismissAlertController()

        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }

    func downloadRequestFinished(downloadModel: MZDownloadModel, index: Int) {

        self.safelyDismissAlertController()

        downloadManager.presentNotificationForDownload("Ok", notifBody: "节目下载完成！")

        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)

        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(downloadModel.fileName)
        NSNotificationCenter.defaultCenter().postNotificationName(MZUtility.DownloadCompletedNotif as String, object: docDirectoryPath)
    }

    func downloadRequestDidFailedWithError(error: NSError, downloadModel: MZDownloadModel, index: Int) {
        self.safelyDismissAlertController()
        self.refreshCellForIndex(downloadModel, index: index)
    }
}

/*
extension DownloadingViewController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(downloadModel: MZDownloadModel, index: Int) {
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        self.tableView.reloadData()
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(downloadModels: [MZDownloadModel]) {
        tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(downloadModel: MZDownloadModel, index: Int) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.refreshCellForIndex(downloadModel, index: index)
        }
    }
    
    func downloadRequestDidPaused(downloadModel: MZDownloadModel, index: Int) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.refreshCellForIndex(downloadModel, index: index)
        }
        
    }
    
    func downloadRequestDidResumed(downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestCanceled(downloadModel: MZDownloadModel, index: Int) {
        
                self.safelyDismissAlertController()

        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func downloadRequestFinished(downloadModel: MZDownloadModel, index: Int) {
        
                self.safelyDismissAlertController()

        downloadManager.presentNotificationForDownload("Ok", notifBody: "节目下载完成！")
        
        let indexPath = NSIndexPath.init(forRow: index, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(downloadModel.fileName)
        NSNotificationCenter.defaultCenter().postNotificationName(MZUtility.DownloadCompletedNotif as String, object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(error: NSError, downloadModel: MZDownloadModel, index: Int) {
        //        self.safelyDismissAlertController()
        self.refreshCellForIndex(downloadModel, index: index)
    }

}
 */
