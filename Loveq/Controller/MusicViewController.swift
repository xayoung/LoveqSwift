//
//  MusicViewController.swift
//  Loveq
//
//  Created by xayoung on 16/5/17.
//  Copyright © 2016年 xayoung. All rights reserved.
//
//import = 导入
import UIKit
import AVFoundation
import FXBlurView
import MZDownloadManager
import PKHUD
import pop
import SnapKit
import Wilddog


class MusicViewController: UIViewController,AVAudioPlayerDelegate,CFWaterWaveDelegate {
    
    private var livePlayer: AVPlayer?
    
    var reviewStatu: Bool?
    
    var delegateMV: MusicViewControllerDelegate?
    
    var fileURL: NSURL!
    
    var musicPlayer:AVAudioPlayer = AVAudioPlayer()
    
    var musicTimer :NSTimer!
    
    var playIndex: Int?
    
    var playerState: Int?
    
    var musiclistFilesArray: [NSURL] = [NSURL]()
    
    var musicTitlelistFilesArray: [String] = [String]()
    
    var backgroundImageView:UIImageView?
    
    var waterWave :CFWaterWave?
    
    var waterWaveWhite :CFWaterWave?

    var newmusicPlayView: UIView!
    
    var newlivePlayView: UIView!
    
    let musicViewAndLiveViewY = LoveqConfig.screenH + 100
    
    var musicSlider: MusicSlider!
    
    var beginTimeLabel: UILabel!
    var endTimeLabel: UILabel!
    var playButton: UIButton!
    var liveButton: UIButton!
    
    @IBOutlet weak var musicPlayView: UIView!
    
    @IBOutlet weak var livePlayView: UIView!
    
    @IBOutlet weak var musicPlayViewY: NSLayoutConstraint!
    @IBOutlet weak var livePlayViewY: NSLayoutConstraint!
    
    let play = UIImage(named: "big_play_button")
    let pause = UIImage(named: "big_pause_button")
    
    @IBOutlet weak var programTitle: UILabel!
    
    @IBOutlet weak var waterView: UIView!
    
    @IBOutlet weak var waterViewWhite: UIView!


    class var sharedInstance: MusicViewController{
        struct Singleton {
            static let instance = MusicViewController()
        }
        return Singleton.instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //波浪工具，创建图形，坐标，大小
        waterWaveWhite = CFWaterWave.init(frame: CGRectMake(waterViewWhite.frame.origin.x, waterViewWhite.frame.origin.y, LoveqConfig.screenW, waterViewWhite.frame.size.height))
        //水波浪的速度
        waterWaveWhite?.waveSpeed = 0.5
        //水波浪的浪的高度
        waterWaveWhite?.waterDepth = 0.8
        waterWaveWhite?.delegate = self
        
        //？？？
        waterWave = CFWaterWave.init(frame: CGRectMake(waterView.frame.origin.x, waterView.frame.origin.y, LoveqConfig.screenW, waterView.frame.size.height))
        waterWave?.waterDepth = 0.8
        waterWave?.delegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("playMusicWithSomething:"), name: "playMusic", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: NSSelectorFromString("downloadFinishedNotificationReload:"), name: MZUtility.DownloadCompletedNotif as String, object: nil)
        
        
        
        
        let leftButton = UIBarButtonItem.init(image: UIImage.init(named: "btn_leftmenu_nor"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MusicViewController.leftClick))
        leftButton.tintColor = UIColor.redColor()
        navigationItem.leftBarButtonItem = leftButton
        
        
        
        
        
        let rightButton = UIBarButtonItem.init(image: UIImage.init(named: "btn_my_nor"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MusicViewController.rightClick))
        rightButton.tintColor = UIColor.redColor()
        navigationItem.rightBarButtonItem = rightButton
        
        
        
        let ref = Wilddog(url: "https://loveq.wilddogio.com/review")
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            let statuDict = snapshot.value as! NSDictionary
            
            if statuDict["statu104"] as! NSString == "1" {
                self.reviewStatu = true
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "reviewStatu")
            }else{
                self.reviewStatu = false
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "reviewStatu")
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        playIndex = 0
        musicSlider.setValue(0.0, animated: true)
        setupMusiclist()
        if musiclistFilesArray.count == 0 {
            playerState = 0
        }else{
            playerState = 1
            prepareAudio()
        }
        newlivePlayView = setupLivePlayView()
        view.addSubview(newlivePlayView)
        newmusicPlayView = setupMusicPlayView()
        view.addSubview(newmusicPlayView)
        animationForView(newlivePlayView, statu: false)

        
        
    }

    func setupLivePlayView() -> UIView {
        let backgroundView = UIView.init(frame: CGRectMake(0, musicViewAndLiveViewY, LoveqConfig.screenW, 200))
        let label = UILabel()
        label.font = UIFont(name: "Bodoni 72 Oldstyle", size: 82.0)!
        label.textColor = UIColor.whiteColor()
        label.text = "97.4"
        backgroundView.addSubview(label)
        label.snp_makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp_centerX)
            make.centerY.equalTo(backgroundView.snp_centerY).multipliedBy(0.3)
        }
        
        let radiolabel = UILabel()
        radiolabel.font = UIFont.systemFontOfSize(12.0)
        radiolabel.textColor = UIColor.whiteColor()
        radiolabel.text = "珠江经济台"
        backgroundView.addSubview(radiolabel)
        radiolabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp_centerX)
            make.top.equalTo(label.snp_bottom).offset(8)
        }
        let button = UIButton.init(type: UIButtonType.Custom)
        button.setImage(UIImage.init(named: "btn_stop_nor"), forState: UIControlState.Normal)
        button.setImage(UIImage.init(named: "btn_playing_nor-0"), forState: UIControlState.Selected)
        button.addTarget(self, action: #selector(MusicViewController.livePlayAtion(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        liveButton = button
        backgroundView.addSubview(button)
        button.snp_makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp_centerX)
            make.top.equalTo(radiolabel.snp_bottom).offset(8)
//            make.bottom.equalTo(backgroundView.snp_bottom)
        }
        return backgroundView
    }
    
    func setupMusicPlayView() -> UIView {
        let backgroundView = UIView.init(frame: CGRectMake(0, 800, LoveqConfig.screenW, 200))
        let label1 = UILabel()
        label1.font = UIFont.systemFontOfSize(12.0)
        label1.textColor = UIColor.whiteColor()
        label1.text = "00:00:00"
        beginTimeLabel = label1
        backgroundView.addSubview(label1)
        label1.snp_makeConstraints { (make) in
            make.left.equalTo(backgroundView.snp_left).offset(8)
            make.top.equalTo(backgroundView.snp_top).offset(60)
        }
        let label2 = UILabel()
        label2.font = UIFont.systemFontOfSize(12.0)
        label2.textColor = UIColor.whiteColor()
        label2.text = "00:00:00"
        endTimeLabel = label2
        backgroundView.addSubview(label2)
        label2.snp_makeConstraints { (make) in
            make.right.equalTo(backgroundView.snp_right).offset(-8)
            make.centerY.equalTo(label1.snp_centerY)
        }
        
        musicSlider = MusicSlider.init(frame: CGRectZero)
        musicSlider.maximumTrackTintColor = UIColor.init(white: 1.0, alpha: 0.3)
        musicSlider.addTarget(self, action: #selector(MusicViewController.didChangeMusicSlider(_:)), forControlEvents: UIControlEvents.AllEvents)
        backgroundView.addSubview(musicSlider)
        musicSlider.snp_makeConstraints { (make) in
            make.centerY.equalTo(label1.snp_centerY)
            make.left.equalTo(label1.snp_right).offset(16)
            make.right.equalTo(label2.snp_left).offset(-16)
        }
        
        let button = UIButton.init(type: UIButtonType.Custom)
        button.setImage(UIImage.init(named: "btn_stop_nor"), forState: UIControlState.Normal)
        button.setImage(UIImage.init(named: "btn_playing_nor-0"), forState: UIControlState.Selected)
        button.addTarget(self, action: #selector(MusicViewController.playAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        playButton = button
        backgroundView.addSubview(button)
        button.snp_makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp_centerX)
            make.top.equalTo(label1.snp_bottom).offset(20)
        }
        
        let PreviousButton = UIButton.init(type: UIButtonType.Custom)
        PreviousButton.setImage(UIImage.init(named: "btn_lastsong_nor"), forState: UIControlState.Normal)
        PreviousButton.addTarget(self, action: #selector(MusicViewController.playPreviousAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        backgroundView.addSubview(PreviousButton)
        PreviousButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(button.snp_centerY)
            make.right.equalTo(button.snp_left).offset(-30)
        }
        let nextButton = UIButton.init(type: UIButtonType.Custom)
        nextButton.setImage(UIImage.init(named: "btn_nextsong_nor"), forState: UIControlState.Normal)
        nextButton.addTarget(self, action: #selector(MusicViewController.playNextAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        backgroundView.addSubview(nextButton)
        nextButton.snp_makeConstraints { (make) in
            make.centerY.equalTo(button.snp_centerY)
            make.left.equalTo(button.snp_right).offset(30)
        }
        return backgroundView
    }


    func waterWave(waterWave: CFWaterWave!, wavePath path: UIBezierPath!) {
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = path.CGPath
        if waterWave == self.waterWave {
            waterView.layer.mask = maskLayer
        }else{
            waterViewWhite.layer.mask = maskLayer
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        setupMusiclist()
        if musiclistFilesArray.count == 0 {
            playerState = 0
        }else{
            playerState = 1
        }
    }
    
    
    func leftClick() {
        LoveqClient.sharedInstance.drawerController?.toggleLeftDrawerSideAnimated(true, completion: nil)
    }
    
    func rightClick() {
        LoveqClient.sharedInstance.drawerController?.toggleRightDrawerSideAnimated(true, completion: nil)
    }
    
    func setupMusiclist() {
        musicTitlelistFilesArray.removeAll()
        musiclistFilesArray.removeAll()
        let contentOfDir: [String] = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(MZUtility.baseFilePath as String)
        var contentOfDir2: [String] = [String]()
        var contentOfDir3: [NSURL] = [NSURL]()
        for str in contentOfDir{
            if (str as NSString).containsString(".mp3") {
                
                contentOfDir2.append((str as NSString).substringToIndex(10))
                let fileURL  : NSURL = NSURL(fileURLWithPath: (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(str as String))
                contentOfDir3.append(fileURL)
            }
        }
        musicTitlelistFilesArray.appendContentsOf(contentOfDir2)
        musiclistFilesArray.appendContentsOf(contentOfDir3)
        
    }
    
    func updateProgramTitleWithIndex(index: Int) {
        programTitle.text = musicTitlelistFilesArray[index] + "期"
    }
    
    // MARK: - NSNotification Methods -
    func downloadFinishedNotificationReload(notification : NSNotification) {
        
        musicTitlelistFilesArray.removeAll()
        musiclistFilesArray.removeAll()
        let contentOfDir: [String] = try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(MZUtility.baseFilePath as String)
        var contentOfDir2: [String] = [String]()
        var contentOfDir3: [NSURL] = [NSURL]()
        for str in contentOfDir{
            if (str as NSString).containsString(".mp3") {
                
                contentOfDir2.append((str as NSString).substringToIndex(10))
                let fileURL  : NSURL = NSURL(fileURLWithPath: (MZUtility.baseFilePath as NSString).stringByAppendingPathComponent(str as String))
                contentOfDir3.append(fileURL)
            }
        }
        musicTitlelistFilesArray.appendContentsOf(contentOfDir2)
        musiclistFilesArray.appendContentsOf(contentOfDir3)
    }

    func playMusicWithSomething(notification : NSNotification) {
        
        //暂停播放live
        if (livePlayer != nil) {
            livePlayer!.pause()
            livePlayer = nil
        }
        liveButton.selected = false
        
        let index = notification.object as! NSIndexPath
        playIndex = index.row
        playerState = 1
        setupMusiclist()
        fileURL = musiclistFilesArray[index.row]
        let programTitleWithURL = fileURL.lastPathComponent
        programTitle.text = (programTitleWithURL! as NSString).substringToIndex(10) + "期"
        prepareAudio()
        playAudio()
    }

    // MARK: - AVAdioSessionPlayer Methods -
    func prepareAudio(){
        do {
            //keep alive audio at background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        if fileURL != nil || musiclistFilesArray.count > 0 {
            
            fileURL = musiclistFilesArray[playIndex!]
            updateProgramTitleWithIndex(playIndex!)
            
            musicPlayer = try! AVAudioPlayer(contentsOfURL: fileURL)
        }
        musicPlayer.delegate = self
        musicSlider.minimumValue = 0.0
        musicPlayer.prepareToPlay()
    }
    
    func updateSliderValue(){
        if !musicPlayer.playing{
            return
        }
        let time = musicPlayer.currentTime / musicPlayer.duration
        musicSlider.setValue(Float(time), animated: true)
        updateProgressLabelValue()
        if time > 0.9998 {
            playNext()
        }
    }
    
    func updateProgressLabelValue() {
        
        beginTimeLabel.text = Tools.calculateTime(musicPlayer.currentTime)
        endTimeLabel.text = Tools.calculateTime(musicPlayer.duration)
    }

    @IBAction func playAction(sender: AnyObject) {
        if playerState == 1 && fileURL != nil {
            if musicPlayer.playing{
                pauseAudio()
            }else{
                if (livePlayer != nil) {
                    livePlayer!.pause()
                    livePlayer = nil
                }
                liveButton.selected = false
                playAudio()
            }

        }else{
            if let statu = reviewStatu {
                if !statu {
                    HUD.flash(.LabeledError(title: "", subtitle: "前往全部节目下载节目"), delay: 1.5)
                }
            }
            
        }
        
    }



    func playAudio(){

        let memoryTime  = NSUserDefaults.standardUserDefaults().doubleForKey(self.programTitle.text!)
        
        if  memoryTime > 0.0 {
            musicPlayer.currentTime = memoryTime
        }
        musicPlayer.play()
        playButton.selected = true
        startTimer()
    }
    
    func pauseAudio() {
        musicPlayer.pause()
        playButton.selected = false
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble((musicPlayer.currentTime), forKey: (programTitle.text)!)
    }
    
    func playPrevious() {
        if playIndex == 0 {
            HUD.flash(.LabeledError(title: "", subtitle: "已经是第一首了"), delay: 1.5)
        }else{
            playIndex = playIndex! - 1
            prepareAudio()
            playAudio()
        }
    }
    func playNext() {
        
        if playIndex == musiclistFilesArray.count - 1 {
            if UIApplication.sharedApplication().applicationState != UIApplicationState.Background{
                HUD.flash(.LabeledError(title: "", subtitle: "已经是最后一首了"), delay: 1.5)
                musicPlayer.stop()
            }
        }else{
            playIndex = playIndex! + 1
            prepareAudio()
            playAudio()
        }
    }
    
    func startTimer(){
        
        if musicTimer == nil {
             musicTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(MusicViewController.updateSliderValue), userInfo: nil, repeats: true)
            musicTimer.fire()
        }
    }
    
    
    //线控
    func remoteControl() {
        if playerState == 1 && fileURL != nil {
            if musicPlayer.playing{
                pauseAudio()
            }else{
                playAudio()
            }
        }
    }
    @IBAction func didChangeMusicSlider(sender: AnyObject) {
        if playerState == 1 && fileURL != nil {
            musicPlayer.currentTime = musicPlayer.duration * Double(musicSlider.value)
        }
    }

    
    @IBAction func playPreviousAction(sender: UIButton) {
        if playerState == 1 && fileURL != nil {
            playPrevious()
        }else{
            if let statu = reviewStatu {
                if !statu {
                    HUD.flash(.LabeledError(title: "", subtitle: "前往全部节目下载节目"), delay: 1.5)
                }
            }
        }
    }
    @IBAction func playNextAction(sender: UIButton) {
        if playerState == 1 && fileURL != nil {
            playNext()
        }else{
            if let statu = reviewStatu {
                if !statu {
                    HUD.flash(.LabeledError(title: "", subtitle: "前往全部节目下载节目"), delay: 1.5)
                }
            }
        }
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setDouble((musicPlayer.currentTime), forKey: (programTitle.text)!)
    }
    //电话中断恢复播放
    func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int) {

        if (flags == Int(AVAudioSessionInterruptionOptions.ShouldResume.rawValue)) {
            playAudio()
        }
       
    }
    
    @IBAction func changePlayModel(sender: UISegmentedControl) {
        var statu: Bool
        if sender.selectedSegmentIndex == 0{
            statu = false
            programTitle.hidden = true
        }else{
            statu = true
            programTitle.hidden = false
        }
        animationForView(newmusicPlayView, statu: !statu)
        
        animationForView(newlivePlayView, statu: statu)
        newmusicPlayView.frame.origin.y = !statu ? musicViewAndLiveViewY : CGFloat(LoveqConfig.screenH - newmusicPlayView.frame.size.height * 0.5)
        newlivePlayView.frame.origin.y = statu ? musicViewAndLiveViewY : CGFloat(LoveqConfig.screenH - newmusicPlayView.frame.size.height * 0.5)
        newlivePlayView.userInteractionEnabled = true

    }
    func livePlayAtion(sender: UIButton) {
        livePlayer = AVPlayer(URL: NSURL(string: "http://ctt.rgd.com.cn:8000/fm974")!)
        if sender.selected {
            sender.selected = false
            livePlayer!.pause()
        }else{
            sender.selected = true
            livePlayer!.play()
        }
        if playerState == 1 && fileURL != nil {
            if musicPlayer.playing{
                pauseAudio()
            }
        }
        
    }

    func animationForView(view: UIView, statu: Bool) {
        dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue()) {
            let musicPlayViewAnimation = POPSpringAnimation.init(propertyNamed: kPOPLayerPositionY)
            musicPlayViewAnimation.toValue = statu ? self.musicViewAndLiveViewY :  LoveqConfig.screenH - self.newmusicPlayView.frame.size.height * 0.5
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

protocol MusicViewControllerDelegate {
    func updatePlaybackIndicatorOfVisisbleCells()
}

