//
//  ProgrammeDetailListViewController.swift
//  Loveq
//
//  Created by xayoung on 16/6/23.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import Wilddog
import ObjectMapper
import NVActivityIndicatorView
import MZDownloadManager
import PKHUD
import FXBlurView
import pop

class ProgrammeDetailListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,programmerDatailCellDelegate{
    private var _tableView :UITableView!

    var year: String?
    
    var count: Int = 0
    
    var indexNum = 0
    
    var dataSource : [String : NSArray] = [String : NSArray]()
    
    var sectionArray: NSArray = []
    
    var dataArray: Array<[ProgrammerListModel]> = Array<[ProgrammerListModel]>()
    
    var DownloadingVC: DownloadingViewController?
    
    let ID = "cell1"
    
    var downloadedFilesArray: [String] = []
    
    var reviewStatu: Bool?
    
    var mulitpleURLArray: NSMutableArray = []
    
    var multipleChoiceButton: UIButton?
    
    private var downloadButtonView: UIView?
    
    private var tableView: UITableView {
        get{
            if(_tableView != nil){
                return _tableView!;
            }
            _tableView = UITableView();
            _tableView.frame = CGRectMake( 0, 60, LoveqConfig.screenW, LoveqConfig.screenH)
            _tableView.backgroundColor = UIColor.clearColor()
            _tableView.estimatedRowHeight = 200
            _tableView.separatorStyle = UITableViewCellSeparatorStyle.None;
            _tableView.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
            _tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: ID)
            _tableView.delegate = self
            _tableView.dataSource = self
            _tableView.hidden = true
            return _tableView!;
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.whiteColor()
        regClass(self.tableView, cell: ProgrammeDetailViewCell.self)
        view.addSubview(tableView)
        setUpDownloadingViewController()
        let yearNum = Int(self.year!)
        if yearNum > 2015 {
            loadNewData()
        }else{
            loadOldData()
        }
        loadFileAppendArray()
        setupDownloadButtonView()
    }
    
    func setupDownloadButtonView(){
        let height = CGFloat(40.0)
        downloadButtonView = UIView.init(frame: CGRectMake(0, LoveqConfig.screenH + height, LoveqConfig.screenW, height))
        downloadButtonView?.backgroundColor = UIColor.init(red: 252/255.0, green: 0/255.0, blue: 61/255.0, alpha: 1.0)
        let button = UIButton.init(type: .Custom)
        button.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        button.setTitle("下 载", forState: .Normal)
        button.addTarget(self, action: NSSelectorFromString("multipleDownloadAction"), forControlEvents: .TouchUpInside)
        downloadButtonView?.addSubview(button)
        button.snp_makeConstraints { (make) in
            make.center.equalTo((downloadButtonView?.snp_center)!)
            make.height.equalTo(height)
            make.width.equalTo(LoveqConfig.screenW)
        }
        self.view.addSubview(downloadButtonView!) 
    }
    
    func addRightButton() {
        let button = UIButton.init(type: .Custom)
        button.frame = CGRectMake(0, 0, 60, 40)
        button.setTitle("多选", forState: .Normal)
        button.setTitle("完成", forState: .Selected)
        button.setTitleColor(UIColor.redColor(), forState: .Normal)
        button.setTitleColor(UIColor.redColor(), forState: .Selected)
        button.hidden = false
        button.addTarget(self, action: NSSelectorFromString("multipleChoice:"), forControlEvents: .TouchUpInside)
        multipleChoiceButton = button
        let BarButton = UIBarButtonItem.init(customView: button)
        navigationItem.rightBarButtonItem = BarButton
    }
    
    func multipleChoice(button: UIButton){
        button.selected = button.selected ? false : true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(button.selected, animated: true)
        tableView.reloadData()
        animationForView(downloadButtonView!, statu: button.selected)
    }
    
    func multipleDownloadAction(){
        multipleChoiceButton?.selected = false
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
            HUD.flash(.Label("已添加至下载队列"))
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        reviewStatu = NSUserDefaults.standardUserDefaults().objectForKey("reviewStatu") as? Bool
        
        if reviewStatu != nil {
            if !reviewStatu! {
                addRightButton()
            }
        }
    }
    override func viewDidAppear(animated: Bool) {
        self.tableView.hidden = false
        let yearNum = Int(self.year!)
        if yearNum > 2015 {
            
        }else{
            self.animateTable()
        }
        
    }
    
    func loadFileAppendArray() {
        downloadedFilesArray.removeAll()
        do {
            let contentOfDir: [String] = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(MZUtility.baseFilePath as String)
            var contentOfDir2: [String] = [String]()
            for str in contentOfDir{
                if (str as NSString).containsString(".mp3") {
                    contentOfDir2.append((str as NSString).substringToIndex(10))
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
    
    func setUpDownloadingViewController() {
        DownloadingVC = LoveqClient.sharedInstance.downloadingController
    }
    
    func loadNewData() {
        
        let activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50), type: NVActivityIndicatorType.BallBeat, color: UIColor.redColor())
        activityIndicatorView.center = CGPointMake(LoveqConfig.screenW * 0.5, LoveqConfig.screenH * 0.5 - 64)
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        let ref = Wilddog(url: LoveqConfig.WilddogURL + year! )
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            let dict = snapshot.value as! NSDictionary
            self.dataSource = dict as! [String : NSArray]
            
            var array = dict.allKeys
            
            array.sortInPlace{($0 as! String) > ($1 as! String)}
            
            for str in array{
                let mapArray = dict.objectForKey(str) as! NSArray
                var outArray: [ProgrammerListModel] = [ProgrammerListModel]()
                for dic in 0 ..< mapArray.count {
                    let model = Mapper<ProgrammerListModel>().map(mapArray[dic])
                    outArray.append(model!)
                }
                self.dataArray.append(outArray)
            }
            self.sectionArray = array
            activityIndicatorView.stopAnimating()
            sleep(1)
            self.animateTable()
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func loadOldData() {

        let dict = LoveqClient.sharedInstance.oldProgramListJSON.objectForKey(self.year!)
        self.dataSource = dict as! [String : NSArray]
        
        var array = dict!.allKeys
        
        array.sortInPlace{($0 as! String) > ($1 as! String)}
        
        for str in array{
            let mapArray = dict!.objectForKey(str) as! NSArray
            var outArray: [ProgrammerListModel] = [ProgrammerListModel]()
            for dic in 0 ..< mapArray.count {
                let model = Mapper<ProgrammerListModel>().map(mapArray[dic])
                outArray.append(model!)
            }
            self.dataArray.append(outArray)
        }
        self.sectionArray = array
        
    }
    
    func animateTable() {
        
        tableView.reloadData()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        for (index, cell) in cells.enumerate() {
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
            UIView.animateWithDuration(1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
        }
        
    }
    
    // MARK: - Table view data source
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataArray.count
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count = count + dataArray[section].count
        return dataArray[section].count
    }
    
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = getCell(tableView, cell: ProgrammeDetailViewCell.self, indexPath: indexPath)
        let model = dataArray[indexPath.section][indexPath.row]
        cell.contentView.backgroundColor = UIColor.clearColor()
        cell.model = model
        let attrString = NSMutableAttributedString.init(string: model.title!)
        attrString.addAttribute(NSKernAttributeName, value: 4, range: NSMakeRange(0, model.title!.characters.count))
        cell.title?.attributedText = attrString
        var index: NSInteger = 0
        
        for a in 0...indexPath.section {
            index += a == indexPath.section ?  indexPath.row : dataArray[indexPath.section].count
        }
        cell.indexNum?.text = String(index + 1)
        cell.indexNum?.hidden = tableView.editing ? true : false
        cell.delegate = self
        cell.ActionImg?.hidden = reviewStatu! ? true : false
        cell.ActionImg?.userInteractionEnabled = true
        cell.ActionImg?.setImage(UIImage.init(named: "btn_download_nor"), forState: .Normal)
        cell.textLabel?.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.blackColor()
        if downloadedFilesArray.contains((model.title! as NSString).substringToIndex(10)) {
            cell.ActionImg?.setImage(UIImage.init(named: "ic_downloaded"), forState: .Normal)
            cell.ActionImg?.userInteractionEnabled = false
            cell.textLabel?.textColor = UIColor.init(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0)

        }

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView = bgColorView
        
        return cell
    }
    
    func downloadMusicAction(model: ProgrammerListModel) {
        if reviewStatu != nil {
            if !reviewStatu! {
                downloadAlertView(model)
            }
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // 没有添加任何的功能代码
    }
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.editing {
            let model = dataArray[indexPath.section][indexPath.row]
            if !mulitpleURLArray.containsObject(model) {
                mulitpleURLArray.addObject(model)
            }
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        }else{
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let model = dataArray[indexPath.section][indexPath.row]
        
        if mulitpleURLArray.containsObject(model) {
            mulitpleURLArray.removeObject(model)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
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
    
    func downloadAlertView(model: ProgrammerListModel){
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let saveAction = UIAlertAction(title: "下载", style: .Destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            self.addDownloadTask(model)
            HUD.flash(.Label("已添加至下载队列"))
        })
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func addDownloadTask(model: ProgrammerListModel) {
        let fileURL  : NSString = model.url!
        var fileName : NSString = model.title! + ".mp3"
        fileName = MZUtility.getUniqueFileNameWithPath((MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(fileName as String))
        
        self.DownloadingVC!.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    func animationForView(view: UIView, statu: Bool) {
        dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue()) {
            let musicPlayViewAnimation = POPSpringAnimation.init(propertyNamed: kPOPLayerPositionY)
            musicPlayViewAnimation.toValue = statu ? LoveqConfig.screenH - 20 :  LoveqConfig.screenH + 40
            musicPlayViewAnimation.springSpeed = 10
            view.layer.pop_addAnimation(musicPlayViewAnimation, forKey: "positionAnimation")
            
            let musicPlayViewlayerPositionAnimation = POPSpringAnimation.init(propertyNamed: kPOPLayerScaleXY)
            musicPlayViewlayerPositionAnimation.toValue = statu ? NSValue.init(CGSize: CGSizeMake(1.0, 1.0)) : NSValue.init(CGSize: CGSizeMake(1.0  , 1.0))
            musicPlayViewlayerPositionAnimation.springSpeed = 10
            musicPlayViewlayerPositionAnimation.springBounciness = 20.0
            view.layer.pop_addAnimation(musicPlayViewlayerPositionAnimation, forKey: "layerPositionAnimation")
        }
        
    }

}
