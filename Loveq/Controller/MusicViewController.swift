//
//  MusicViewController.swift
//  Loveq
//
//  Created by xayoung on 16/5/17.
//  Copyright © 2016年 xayoung. All rights reserved.
//
import UIKit
import AVFoundation
import MZDownloadManager
import PKHUD
import pop
import SnapKit
import LeanCloud
import DrawerController
import MediaPlayer

class MusicViewController: UIViewController,AVAudioPlayerDelegate,CFWaterWaveDelegate {
    
    fileprivate var livePlayer: AVPlayer?
    
    var reviewStatu: Bool?
    
    var delegateMV: MusicViewControllerDelegate?
    
    var fileURL: URL!
    
    var musicPlayer:AVAudioPlayer = AVAudioPlayer()
    
    var musicTimer :Timer!
    
    var playIndex: Int?
    
    var playerState: Int?
    
    var musiclistFilesArray: [URL] = [URL]()
    
    var musicTitlelistFilesArray: [String] = [String]()
    
    var backgroundImageView:UIImageView?
    
    var waterWave :CFWaterWave?
    
    var waterWaveWhite :CFWaterWave?

    var newmusicPlayView: UIView!
    
    var newlivePlayView: UIView!
    
    let musicViewAndLiveViewY = LoveqConfig.screenH + 100
    
    var musicSlider: MusicSlider!

    let drawerContoller = LoveqClient.sharedInstance.drawerController

    let nowPlayingCenter = MPNowPlayingInfoCenter.default()
    
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
        waterWaveWhite = CFWaterWave.init(frame: CGRect(x: waterViewWhite.frame.origin.x, y: waterViewWhite.frame.origin.y, width: LoveqConfig.screenW, height: waterViewWhite.frame.size.height))
        //水波浪的速度
        waterWaveWhite?.waveSpeed = 0.5
        //水波浪的浪的高度
        waterWaveWhite?.waterDepth = 0.8
        waterWaveWhite?.delegate = self
        
        //？？？
        waterWave = CFWaterWave.init(frame: CGRect(x: waterView.frame.origin.x, y: waterView.frame.origin.y, width: LoveqConfig.screenW, height: waterView.frame.size.height))
        waterWave?.waterDepth = 0.8
        waterWave?.delegate = self
        
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("playMusicWithSomething:"), name: NSNotification.Name(rawValue: "playMusic"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("downloadFinishedNotificationReload:"), name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: nil)
        
        
        
        
        let leftButton = UIBarButtonItem.init(image: UIImage.init(named: "btn_leftmenu_nor"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MusicViewController.leftClick))
        leftButton.tintColor = UIColor.red
        navigationItem.leftBarButtonItem = leftButton
        
        
        
        
        
        let rightButton = UIBarButtonItem.init(image: UIImage.init(named: "btn_my_nor"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(MusicViewController.rightClick))
        rightButton.tintColor = UIColor.red
        navigationItem.rightBarButtonItem = rightButton

        //LeanCloud获取当前版本审核信息
        let keyQuery = LCQuery(className: "Review")
        keyQuery.whereKey("version", .prefixedBy("1.2.0"))
        keyQuery.getFirst { result in
            switch result {
            case .success(let list):
                let statu = list.get("statu") as! LCBool
                if  statu.value {
                    self.reviewStatu = true
                    UserDefaults.standard.set(true, forKey: "reviewStatu")
                }else{
                    self.reviewStatu = false
                    UserDefaults.standard.set(false, forKey: "reviewStatu")
                }


            break // 查询成功
            case .failure(let error):
                print(error)
            }
        }
        
        playIndex = 0
        musicSlider.setValue(0.0, animated: true)
        setupMusiclist()
        if musiclistFilesArray.count == 0 {
            playerState = 0
        }else{
            playerState = 0
            prepareAudio()
        }
        newlivePlayView = setupLivePlayView()
        view.addSubview(newlivePlayView)
        newmusicPlayView = setupMusicPlayView()
        view.addSubview(newmusicPlayView)
        animationForView(newlivePlayView, statu: false)


        //设置NowPlayingCenter
        let artWork = MPMediaItemArtwork.init(image: UIImage.init(named: "logo-120")!)
        nowPlayingCenter.nowPlayingInfo = [MPMediaItemPropertyTitle:"Hugo&阿智",MPMediaItemPropertyArtwork:artWork]

        
        
    }

    func setupLivePlayView() -> UIView {
        let backgroundView = UIView.init(frame: CGRect(x: 0, y: musicViewAndLiveViewY, width: LoveqConfig.screenW, height: 200))
        let label = UILabel()
        label.font = UIFont(name: "Bodoni 72 Oldstyle", size: 82.0)!
        label.textColor = UIColor.white
        label.text = "97.4"
        backgroundView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp.centerX)
            make.centerY.equalTo(backgroundView.snp.centerY).multipliedBy(0.3)
        }
        
        let radiolabel = UILabel()
        radiolabel.font = UIFont.systemFont(ofSize: 12.0)
        radiolabel.textColor = UIColor.white
        radiolabel.text = "珠江经济台"
        backgroundView.addSubview(radiolabel)
        radiolabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp.centerX)
            make.top.equalTo(label.snp.bottom).offset(8)
        }
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage.init(named: "btn_stop_nor"), for: UIControlState())
        button.setImage(UIImage.init(named: "btn_playing_nor-0"), for: UIControlState.selected)
        button.addTarget(self, action: #selector(MusicViewController.livePlayAtion(_:)), for: UIControlEvents.touchUpInside)
        liveButton = button
        backgroundView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp.centerX)
            make.top.equalTo(radiolabel.snp.bottom).offset(8)
        }
        return backgroundView
    }
    
    func setupMusicPlayView() -> UIView {
        let backgroundView = UIView.init(frame: CGRect(x: 0, y: 800, width: LoveqConfig.screenW, height: 200))
        let label1 = UILabel()
        label1.font = UIFont.systemFont(ofSize: 12.0)
        label1.textColor = UIColor.white
        label1.text = "00:00:00"
        beginTimeLabel = label1
        backgroundView.addSubview(label1)
        label1.snp.makeConstraints { (make) in
            make.left.equalTo(backgroundView.snp.left).offset(8)
            make.top.equalTo(backgroundView.snp.top).offset(60)
        }
        let label2 = UILabel()
        label2.font = UIFont.systemFont(ofSize: 12.0)
        label2.textColor = UIColor.white
        label2.text = "00:00:00"
        endTimeLabel = label2
        backgroundView.addSubview(label2)
        label2.snp.makeConstraints { (make) in
            make.right.equalTo(backgroundView.snp.right).offset(-8)
            make.centerY.equalTo(label1.snp.centerY)
        }
        
        musicSlider = MusicSlider.init(frame: CGRect.zero)
        musicSlider.maximumTrackTintColor = UIColor.init(white: 1.0, alpha: 0.3)
        musicSlider.isContinuous = false
        musicSlider.addTarget(self, action: #selector(didChangeMusicSliderUpdateProgressLabelValue(_:)), for: UIControlEvents.touchDragInside
        )
        musicSlider.addTarget(self, action: #selector(didChangeMusicSlider(_:)), for: UIControlEvents.valueChanged
        )

        backgroundView.addSubview(musicSlider)
        musicSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(label1.snp.centerY)
            make.left.equalTo(label1.snp.right).offset(16)
            make.right.equalTo(label2.snp.left).offset(-16)
        }
        
        let button = UIButton.init(type: UIButtonType.custom)
        button.setImage(UIImage.init(named: "btn_stop_nor"), for: UIControlState())
        button.setImage(UIImage.init(named: "btn_playing_nor-0"), for: UIControlState.selected)
        button.addTarget(self, action: #selector(MusicViewController.playAction(_:)), for: UIControlEvents.touchUpInside)
        playButton = button
        backgroundView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.centerX.equalTo(backgroundView.snp.centerX)
            make.top.equalTo(label1.snp.bottom).offset(20)
        }
        
        let PreviousButton = UIButton.init(type: UIButtonType.custom)
        PreviousButton.setImage(UIImage.init(named: "btn_lastsong_nor"), for: UIControlState())
        PreviousButton.addTarget(self, action: #selector(MusicViewController.playPreviousAction(_:)), for: UIControlEvents.touchUpInside)
        backgroundView.addSubview(PreviousButton)
        PreviousButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(button.snp.centerY)
            make.right.equalTo(button.snp.left).offset(-30)
        }
        let nextButton = UIButton.init(type: UIButtonType.custom)
        nextButton.setImage(UIImage.init(named: "btn_nextsong_nor"), for: UIControlState())
        nextButton.addTarget(self, action: #selector(MusicViewController.playNextAction(_:)), for: UIControlEvents.touchUpInside)
        backgroundView.addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(button.snp.centerY)
            make.left.equalTo(button.snp.right).offset(30)
        }
        return backgroundView
    }


    func waterWave(_ waterWave: CFWaterWave!, wave path: UIBezierPath!) {
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.path = path.cgPath
        if waterWave == self.waterWave {
            waterView.layer.mask = maskLayer
        }else{
            waterViewWhite.layer.mask = maskLayer
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMusiclist()
        if musiclistFilesArray.count == 0 {
            playerState = 0
        }
    }
    
    
    func leftClick() {
        LoveqClient.sharedInstance.drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
    }
    
    func rightClick() {
        LoveqClient.sharedInstance.drawerController?.toggleRightDrawerSide(animated: true, completion: nil)
    }
    
    func setupMusiclist() {
        musicTitlelistFilesArray.removeAll()
        musiclistFilesArray.removeAll()
        let contentOfDir: [String] = try! FileManager.default.contentsOfDirectory(atPath: MZUtility.baseFilePath as String)
        var contentOfDir2: [String] = [String]()
        var contentOfDir3: [URL] = [URL]()
        for str in contentOfDir{
            if (str as NSString).contains(".mp3") {
                
                contentOfDir2.append((str as NSString).substring(to: 10))
                let fileURL  : URL = URL(fileURLWithPath: (MZUtility.baseFilePath as NSString).appendingPathComponent(str as String))
                contentOfDir3.append(fileURL)
            }
        }
        musicTitlelistFilesArray.append(contentsOf: contentOfDir2)
        musiclistFilesArray.append(contentsOf: contentOfDir3)
        
    }
    
    func updateProgramTitleWithIndex(_ index: Int) {
        programTitle.text = musicTitlelistFilesArray[index] + "期"
    }
    
    // MARK: - NSNotification Methods -
    func downloadFinishedNotificationReload(_ notification : Notification) {
        
        musicTitlelistFilesArray.removeAll()
        musiclistFilesArray.removeAll()
        let contentOfDir: [String] = try! FileManager.default.contentsOfDirectory(atPath: MZUtility.baseFilePath as String)
        var contentOfDir2: [String] = [String]()
        var contentOfDir3: [URL] = [URL]()
        for str in contentOfDir{
            if (str as NSString).contains(".mp3") {
                
                contentOfDir2.append((str as NSString).substring(to: 10))
                let fileURL  : URL = URL(fileURLWithPath: (MZUtility.baseFilePath as NSString).appendingPathComponent(str as String))
                contentOfDir3.append(fileURL)
            }
        }
        musicTitlelistFilesArray.append(contentsOf: contentOfDir2)
        musiclistFilesArray.append(contentsOf: contentOfDir3)
    }

    func playMusicWithSomething(_ notification : Notification) {
        
        //暂停播放live
        if (livePlayer != nil) {
            livePlayer!.pause()
            livePlayer = nil
        }
        liveButton.isSelected = false
        
        let index = notification.object as! IndexPath
        playIndex = (index as NSIndexPath).row
        playerState = 1
        setupMusiclist()
        fileURL = musiclistFilesArray[(index as NSIndexPath).row]
        let programTitleWithURL = fileURL.lastPathComponent
        programTitle.text = (programTitleWithURL as NSString).substring(to: 10) + "期"
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
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        if fileURL != nil || musiclistFilesArray.count > 0 {
            
            fileURL = musiclistFilesArray[playIndex!]
            updateProgramTitleWithIndex(playIndex!)
            
            musicPlayer = try! AVAudioPlayer(contentsOf: fileURL)
        }
        musicPlayer.delegate = self
        musicSlider.minimumValue = 0.0
        musicPlayer.prepareToPlay()
    }
    
    func updateSliderValue(){
        if !musicPlayer.isPlaying{
            return
        }
        let time = musicPlayer.currentTime / musicPlayer.duration
        musicSlider.setValue(Float(time), animated: true)
        nowPlayingCenter.nowPlayingInfo = [MPNowPlayingInfoPropertyElapsedPlaybackTime:Int(musicPlayer.currentTime)]
        updateProgressLabelValue()
        if time > 0.9998 {
            playNext()
        }
    }

    //MARK: 更新进度条时间显示
    func updateProgressLabelValue() {
        
        beginTimeLabel.text = Tools.calculateTime(musicPlayer.currentTime)
        endTimeLabel.text = Tools.calculateTime(musicPlayer.duration)
    }


    func didChangeMusicSliderUpdateProgressLabelValue(_ sender: AnyObject) {
        if playerState == 1 && fileURL != nil {
            musicTimer.fireDate = NSDate.distantFuture
            beginTimeLabel.text = Tools.calculateTime(musicPlayer.duration * Double(musicSlider.value))

            drawerContoller?.openDrawerGestureModeMask = OpenDrawerGestureMode.panningNavigationBar
            drawerContoller?.closeDrawerGestureModeMask = CloseDrawerGestureMode.panningNavigationBar
        }
    }

    @IBAction func playAction(_ sender: AnyObject) {
        if playerState == 1 && fileURL != nil {
            if musicPlayer.isPlaying{
                pauseAudio()
            }else{
                if (livePlayer != nil) {
                    livePlayer!.pause()
                    livePlayer = nil
                }
                liveButton.isSelected = false
                playAudio()
            }

        }else{
            if let statu = reviewStatu {
                if !statu {
                    HUD.flash(.labeledError(title: "", subtitle: "向左滑查看已下载的节目\n或右滑选择节目下载"), delay: 1.5)
                }
            }
            
        }
        
    }



    func playAudio(){

        let memoryTime  = UserDefaults.standard.double(forKey: self.programTitle.text!)
        if  memoryTime > 0.0 {
            musicPlayer.currentTime = memoryTime
        }
        playerState = 1
        musicPlayer.play()
        playButton.isSelected = true
        startTimer()
        nowPlayingCenter.nowPlayingInfo = [MPMediaItemPropertyTitle:programTitle.text,MPMediaItemPropertyPlaybackDuration:Int(musicPlayer.duration),MPNowPlayingInfoPropertyPlaybackRate:(1)]
    }
    
    func pauseAudio() {
        musicPlayer.pause()
        playButton.isSelected = false
        
        let userDefaults = UserDefaults.standard
        userDefaults.set((musicPlayer.currentTime), forKey: (programTitle.text)!)
    }
    
    func playPrevious() {
        if playIndex == 0 {
            HUD.flash(.labeledError(title: "", subtitle: "已经是第一首了"), delay: 1.5)
        }else{
            playIndex = playIndex! - 1
            prepareAudio()
            playAudio()
        }
    }
    func playNext() {
        
        if playIndex == musiclistFilesArray.count - 1 {
            if UIApplication.shared.applicationState != UIApplicationState.background{
                HUD.flash(.labeledError(title: "", subtitle: "已经是最后一首了"), delay: 1.5)
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
             musicTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MusicViewController.updateSliderValue), userInfo: nil, repeats: true)
            musicTimer.fire()
        }
    }
    
    
    //线控
    func remoteControl() {
        if playerState == 1 && fileURL != nil {
            if musicPlayer.isPlaying{
                pauseAudio()
            }else{
                playAudio()
            }
        }
    }
    @IBAction func didChangeMusicSlider(_ sender: AnyObject) {

        if playerState == 1 && fileURL != nil {
            musicTimer.fireDate = NSDate.init() as Date
            musicPlayer.currentTime = musicPlayer.duration * Double(musicSlider.value)
            drawerContoller?.openDrawerGestureModeMask = OpenDrawerGestureMode.all
            drawerContoller?.closeDrawerGestureModeMask = CloseDrawerGestureMode.all
        }
    }

    
    @IBAction func playPreviousAction(_ sender: UIButton) {
        if playerState == 1 && fileURL != nil {
            playPrevious()
        }else{
            if let statu = reviewStatu {
                if !statu {
                    HUD.flash(.labeledError(title: "", subtitle: "前往全部节目下载节目"), delay: 1.5)
                }
            }
        }
    }
    @IBAction func playNextAction(_ sender: UIButton) {
        if playerState == 1 && fileURL != nil {
            playNext()
        }else{
            if let statu = reviewStatu {
                if !statu {
                    HUD.flash(.labeledError(title: "", subtitle: "前往全部节目下载节目"), delay: 1.5)
                }
            }
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        let userDefaults = UserDefaults.standard
        userDefaults.set((musicPlayer.currentTime), forKey: (programTitle.text)!)
    }
    //电话中断恢复播放
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {

        if (flags == Int(AVAudioSessionInterruptionOptions.shouldResume.rawValue)) {
            playAudio()
        }
       
    }
    
    @IBAction func changePlayModel(_ sender: UISegmentedControl) {
        var statu: Bool
        if sender.selectedSegmentIndex == 0{
            statu = false
            programTitle.isHidden = true
        }else{
            statu = true
            programTitle.isHidden = false
        }
        animationForView(newmusicPlayView, statu: !statu)
        
        animationForView(newlivePlayView, statu: statu)
        newmusicPlayView.frame.origin.y = !statu ? musicViewAndLiveViewY : CGFloat(LoveqConfig.screenH - newmusicPlayView.frame.size.height * 0.5)
        newlivePlayView.frame.origin.y = statu ? musicViewAndLiveViewY : CGFloat(LoveqConfig.screenH - newmusicPlayView.frame.size.height * 0.5)
        newlivePlayView.isUserInteractionEnabled = true

    }
    func livePlayAtion(_ sender: UIButton) {
        livePlayer = AVPlayer(url: URL(string: "http://ctt.rgd.com.cn:8000/fm974")!)
        do {
            //keep alive audio at background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)

        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        if sender.isSelected {
            sender.isSelected = false
            livePlayer!.pause()
        }else{
            sender.isSelected = true
            livePlayer!.play()
        }
        if playerState == 1 && fileURL != nil {
            if musicPlayer.isPlaying{
                pauseAudio()
            }
        }
        
    }

    func animationForView(_ view: UIView, statu: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            let musicPlayViewAnimation = POPSpringAnimation.init(propertyNamed: kPOPLayerPositionY)
            musicPlayViewAnimation?.toValue = statu ? self.musicViewAndLiveViewY :  LoveqConfig.screenH - self.newmusicPlayView.frame.size.height * 0.5
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

protocol MusicViewControllerDelegate {
    func updatePlaybackIndicatorOfVisisbleCells()
}

