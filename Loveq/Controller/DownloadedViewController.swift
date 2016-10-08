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
    var selectedIndexPath: IndexPath?
    var fileManger: FileManager = FileManager.default
    var ID = "DownloadedFileCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        regClass(self.tableView, cell: RightProgramCell.self)
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("downloadFinishedNotification:"), name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: nil)
        loadFileAppendArray()
    }
    
    func loadFileAppendArray() {
        downloadedFilesArray.removeAll()
        do {
            let contentOfDir: [String] = try FileManager.default.contentsOfDirectory(atPath: MZUtility.baseFilePath as String)
            var contentOfDir2: [String] = [String]()
            for str in contentOfDir{
                if (str as NSString).contains(".mp3") {
                    contentOfDir2.append(str)
                }
            }
            downloadedFilesArray.append(contentsOf: contentOfDir2)
            
            let index = downloadedFilesArray.index(of: ".DS_Store")
            if let index = index {
                downloadedFilesArray.remove(at: index)
            }
            
        } catch let error as NSError {
            print("Error while getting directory content \(error)")
        }
    }
    
    // MARK: - NSNotification Methods -
    
    func downloadFinishedNotification(_ notification : Notification) {
        loadFileAppendArray()
        tableView.reloadData()
        tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.fade)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        tableView.setEditing(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LoveqClient.sharedInstance.centerViewController?.setupMusiclist()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.setEditing(false, animated: true)
    }
    
    func editFile(_ button :UIButton)  {
        if  button.isSelected {
            button.isSelected = false
            tableView.reloadData()
        }else{
            button.isSelected = true
            tableView.setEditing(true, animated: true)
        }
    }

}


//MARK: UITableViewDataSource Handler Extension

extension DownloadedViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: LoveqConfig.screenW, height: 60))
        headerView.backgroundColor = UIColor.white
        let mainTitle = UILabel()
        mainTitle.font = UIFont.systemFont(ofSize: 16.0)
        let title = "我的节目(" + String(downloadedFilesArray.count)
        mainTitle.text = title + ")"
        headerView.addSubview(mainTitle)
        mainTitle.snp.makeConstraints { (make) in
            make.top.equalTo(headerView).offset(35)
            make.centerX.equalTo(headerView)
        }
        let editButton = UIButton.init(type: UIButtonType.custom)
        editButton.setTitle("管理", for: UIControlState())
        editButton.setTitle("返回", for: UIControlState.selected)
        editButton.setTitleColor(UIColor.black, for: UIControlState())
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        editButton.addTarget(self, action: #selector(DownloadedViewController.editFile(_:)), for: UIControlEvents.touchUpInside)
        headerView.addSubview(editButton)
        editButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(mainTitle)
            make.left.equalTo(mainTitle.snp.right).offset(20)
        }
        return headerView
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedFilesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let musicName = downloadedFilesArray[(indexPath as NSIndexPath).row]
        let cell = getCell(tableView, cell: RightProgramCell.self, indexPath: indexPath)
        let fileURL  : URL = URL(fileURLWithPath: (MZUtility.baseFilePath as NSString).appendingPathComponent(musicName as String))
        cell.NO?.text = String((indexPath as NSIndexPath).row + 1)
        cell.title?.text = (musicName as NSString).substring(to: 10)
        let musicPlayer = LoveqClient.sharedInstance.centerViewController?.musicPlayer
        
        print((musicName as NSString).substring(to: 10))
        if LoveqClient.sharedInstance.centerViewController?.programTitle.text == ((musicName as NSString).substring(to: 10) + "期") {
            cell.title?.textColor = UIColor.red
            cell.time?.textColor = UIColor.red
            if LoveqClient.sharedInstance.centerViewController?.fileURL != nil {
                if musicPlayer!.isPlaying{
                    cell.playingAnimationView?.startAnimating()
                }else{
                    cell.playingAnimationView?.stopAnimating()
                }
            }
            
        }else{
            cell.title?.textColor = UIColor.black
            cell.time?.textColor = UIColor.lightGray
            cell.playingAnimationView?.stopAnimating()
        }
        
        cell.time?.text = String(LoveqConfig.durationWithAudio(fileURL))
        return cell
    }
}

//MARK: UITableViewDelegate Handler Extension

extension DownloadedViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndexPath = indexPath
        NotificationCenter.default.post(name: Notification.Name(rawValue: "playMusic"), object: indexPath)
        LoveqClient.sharedInstance.drawerController?.closeDrawer(animated: true, completion: nil)
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let fileName : NSString = downloadedFilesArray[(indexPath as NSIndexPath).row] as NSString
        let fileURL  : URL = URL(fileURLWithPath: (MZUtility.baseFilePath as NSString).appendingPathComponent(fileName as String))
        
        do {
            try fileManger.removeItem(at: fileURL)
            downloadedFilesArray.remove(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
        } catch let error as NSError {
            debugPrint("Error while deleting file: \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
}
