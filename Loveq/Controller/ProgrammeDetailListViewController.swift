//
//  ProgrammeDetailListViewController.swift
//  Loveq
//
//  Created by xayoung on 16/6/23.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import ObjectMapper
import NVActivityIndicatorView
import MZDownloadManager
import PKHUD
import pop
import LeanCloud

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ProgrammeDetailListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,programmerDatailCellDelegate{
    fileprivate var _tableView :UITableView!

    var year: String?
    
    var count: Int = 0
    
    var indexNum = 0
    
    var dataSource : [String : NSArray] = [String : NSArray]()
    
    var sectionArray: NSArray = []
    
    var dataArray: Array<ProgrammerListModel> = Array<ProgrammerListModel>()
    
    var DownloadingVC: DownloadingViewController?
    
    let ID = "cell1"

    var downloadedFilesArray: [String] = []
    
    var reviewStatu: Bool?
    
    var mulitpleURLArray: NSMutableArray = []
    
    var multipleChoiceButton: UIButton?
    
    fileprivate var downloadButtonView: UIView?
    
    fileprivate var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.frame = CGRect( x: 0, y: 60, width: LoveqConfig.screenW, height: LoveqConfig.screenH - 60)
            _tableView.backgroundColor = UIColor.clear
            _tableView.estimatedRowHeight = 200
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
            _tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
            _tableView.register(UITableViewCell.self, forCellReuseIdentifier: ID)
            _tableView.delegate = self
            _tableView.dataSource = self
            _tableView.isHidden = true
            return _tableView!;
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        regClass(self.tableView, cell: ProgrammeDetailViewCell.self)
        view.addSubview(tableView)
        setUpDownloadingViewController()
        loadLeanCloudData()
        loadFileAppendArray()
        setupDownloadButtonView()
    }
    
    func setupDownloadButtonView(){
        let height = CGFloat(40.0)
        downloadButtonView = UIView.init(frame: CGRect(x: 0, y: LoveqConfig.screenH + height, width: LoveqConfig.screenW, height: height))
        downloadButtonView?.backgroundColor = UIColor.init(red: 252/255.0, green: 0/255.0, blue: 61/255.0, alpha: 1.0)
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        button.setTitle("下 载", for: UIControlState())
        button.addTarget(self, action: NSSelectorFromString("multipleDownloadAction"), for: .touchUpInside)
        downloadButtonView?.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.center.equalTo((downloadButtonView?.snp.center)!)
            make.height.equalTo(height)
            make.width.equalTo(LoveqConfig.screenW)
        }
        self.view.addSubview(downloadButtonView!) 
    }
    
    func addRightButton() {
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        button.setTitle("多选", for: UIControlState())
        button.setTitle("完成", for: .selected)
        button.setTitleColor(UIColor.red, for: UIControlState())
        button.setTitleColor(UIColor.red, for: .selected)
        button.isHidden = false
        button.addTarget(self, action: NSSelectorFromString("multipleChoice:"), for: .touchUpInside)
        multipleChoiceButton = button
        let BarButton = UIBarButtonItem.init(customView: button)
        navigationItem.rightBarButtonItem = BarButton
    }
    
    func multipleChoice(_ button: UIButton){
        button.isSelected = button.isSelected ? false : true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(button.isSelected, animated: true)
        tableView.reloadData()
        animationForView(downloadButtonView!, statu: button.isSelected)
    }
    
    func multipleDownloadAction(){
        multipleChoiceButton?.isSelected = false
        tableView.setEditing(false, animated: true)
        tableView.reloadData()
        animationForView(downloadButtonView!, statu: false)
        if mulitpleURLArray.count > 0 {
            print(mulitpleURLArray.count)
            for index in 0...mulitpleURLArray.count - 1 {
                print(index)
                let model = mulitpleURLArray[index]
                addDownloadTask(model as! ProgrammerListModel)
            }
            HUD.flash(.label("已添加至下载队列"))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reviewStatu = UserDefaults.standard.object(forKey: "reviewStatu") as? Bool
        
        if reviewStatu != nil {
            if !reviewStatu! {
                addRightButton()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.isHidden = false
        let yearNum = Int(self.year!)
        if yearNum > 2015 {
            
        }else{
            self.animateTable()
        }
        
    }
    
    func loadFileAppendArray() {
        downloadedFilesArray.removeAll()
        do {
            let contentOfDir: [String] = try FileManager.default.contentsOfDirectory(atPath: MZUtility.baseFilePath as String)
            var contentOfDir2: [String] = [String]()
            for str in contentOfDir{
                if (str as NSString).contains(".mp3") {
                    contentOfDir2.append((str as NSString).substring(to: 10))
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
    
    func setUpDownloadingViewController() {
        DownloadingVC = LoveqClient.sharedInstance.downloadingController
    }

    func loadLeanCloudData() {
        let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: NVActivityIndicatorType.ballBeat, color: UIColor.red)
        activityIndicatorView.center = CGPoint(x: LoveqConfig.screenW * 0.5, y: LoveqConfig.screenH * 0.5 - 64)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        let keyQuery = LCQuery(className: "LoveQ")
        keyQuery.whereKey("date", .prefixedBy(self.year!))
        keyQuery.whereKey("date", .descending)
        keyQuery.find { result in
            switch result {
            case .success(let list):
                self.appendToDataArray(list as NSArray)
                activityIndicatorView.stopAnimating()
                self.animateTable()
            break // 查询成功
            case .failure(let error):
                print(error)
            }
        }

    }

    func appendToDataArray(_ list: NSArray) {
        for item in list {
            let obj = item as! LCObject
            let title = obj.get("date") as! LCString
            let url = obj.get("url") as! LCString
            let model = Mapper<ProgrammerListModel>().map(JSON: ["title":title.value,"url":url.value])
            self.dataArray.append(model!)
        }

    }

    
    func animateTable() {
        
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        for (index, cell) in cells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
                }, completion: nil)
        }
        
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: ProgrammeDetailViewCell.self, indexPath: indexPath)
        let model = dataArray[indexPath.row]
        cell.contentView.backgroundColor = UIColor.clear
        cell.model = model
        let attrString = NSMutableAttributedString.init(string: model.title!)
        attrString.addAttribute(NSKernAttributeName, value: 4, range: NSMakeRange(0, model.title!.characters.count))
        cell.title?.attributedText = attrString
        cell.indexNum?.text = String(indexPath.row + 1)
        cell.indexNum?.isHidden = tableView.isEditing ? true : false
        cell.delegate = self
        cell.ActionImg?.isHidden = reviewStatu! ? true : false
        cell.ActionImg?.isUserInteractionEnabled = true
        cell.ActionImg?.setImage(UIImage.init(named: "btn_download_nor"), for: UIControlState())
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.black
        if downloadedFilesArray.contains((model.title! as NSString).substring(to: 10)) {
            cell.ActionImg?.setImage(UIImage.init(named: "ic_downloaded"), for: UIControlState())
            cell.ActionImg?.isUserInteractionEnabled = false
            cell.textLabel?.textColor = UIColor.init(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)

        }

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = bgColorView

        return cell
    }


    func downloadMusicAction(_ model: ProgrammerListModel) {
        if reviewStatu != nil {
            if !reviewStatu! {
                downloadAlertView(model)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 没有添加任何的功能代码
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let model = dataArray[indexPath.row]
            if !mulitpleURLArray.contains(model) {
                mulitpleURLArray.add(model)
            }
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }else{
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        
        if mulitpleURLArray.contains(model) {
            mulitpleURLArray.remove(model)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK:渐变色
    /*
    func colorforIndex(index: Int) -> UIColor {
        
        let itemCount = 11
        let color = (CGFloat(index) / CGFloat(itemCount)) * 0.7
        return UIColor(red: 1.0, green: color, blue: 0.0, alpha: 1.0)
        
    }
    
     func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.backgroundColor =  colorforIndex(indexPath.row)
        
    }
    */
    
    func downloadAlertView(_ model: ProgrammerListModel){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "下载", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addDownloadTask(model)
            HUD.flash(.label("已添加至下载队列"))
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }

    func addDownloadTask(_ model: ProgrammerListModel) {
        let fileURL  : NSString = model.url! as NSString
        let fileName : String = model.title! + ".mp3"
        var fileName2 : NSString
        fileName2 = MZUtility.getUniqueFileNameWithPath((MZUtility.baseFilePath as NSString).appendingPathComponent(fileName) as NSString)

        self.DownloadingVC!.downloadManager.addDownloadTask(fileName2 as String, fileURL: fileURL.addingPercentEscapes(using: String.Encoding.utf8.rawValue)!)
    }
    
    func animationForView(_ view: UIView, statu: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let musicPlayViewAnimation = POPSpringAnimation.init(propertyNamed: kPOPLayerPositionY)
            musicPlayViewAnimation?.toValue = statu ? LoveqConfig.screenH - 20 :  LoveqConfig.screenH + 40
            musicPlayViewAnimation?.springSpeed = 10
            view.layer.pop_add(musicPlayViewAnimation, forKey: "positionAnimation")
            
            let musicPlayViewlayerPositionAnimation = POPSpringAnimation.init(propertyNamed: kPOPLayerScaleXY)
            musicPlayViewlayerPositionAnimation?.toValue = statu ? NSValue.init(cgSize: CGSize(width: 1.0, height: 1.0)) : NSValue.init(cgSize: CGSize(width: 1.0  , height: 1.0))
            musicPlayViewlayerPositionAnimation?.springSpeed = 10
            musicPlayViewlayerPositionAnimation?.springBounciness = 20.0
            view.layer.pop_add(musicPlayViewlayerPositionAnimation, forKey: "layerPositionAnimation")
        }
        
    }

}
