//
//  ProgrammeCollectionViewController.swift
//  Loveq
//
//  Created by xayoung on 16/6/5.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit
import ObjectMapper
import MZDownloadManager
import Wilddog
import SwiftRefresher
import NVActivityIndicatorView
private let reuseIdentifier = "CellID"

class ProgrammeCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var dataSource = Array<AnyObject>()
    var activityIndicatorView: NVActivityIndicatorView?
    private var _collectionView: UICollectionView!
    private var collectionView: UICollectionView{
        get{
            if (_collectionView != nil){
                return _collectionView!
            }
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSizeMake(LoveqConfig.screenW * 0.25, 120)
            let paddingY: CGFloat = 20.0
            let paddingX: CGFloat = 20.0
            layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX)
            layout.minimumLineSpacing = paddingY
            _collectionView = UICollectionView.init(frame: CGRectMake(0, 50, LoveqConfig.screenW, LoveqConfig.screenH - 50), collectionViewLayout: layout)
            regCollectionViewClass(_collectionView, cell: ProgrammeCollectionCell.self)
            _collectionView.dataSource = self
            _collectionView.delegate = self
            _collectionView.backgroundColor = UIColor.whiteColor()
            return _collectionView!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let refresher = Refresher { [weak self] () -> Void in
            self?.loadData()
        }
        collectionView.srf_addRefresher(refresher)
        self.title = "全部节目"
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(collectionView)

        activityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50), type: NVActivityIndicatorType.BallBeat, color: UIColor.redColor())
        activityIndicatorView!.center = CGPointMake(LoveqConfig.screenW * 0.5, LoveqConfig.screenH * 0.5)
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView!.startAnimating()
        loadData()
    }


    func loadData(){
        self.dataSource.removeAll()

        let ref = Wilddog(url: LoveqConfig.WilddogURL + "index/programIndex")
        ref.observeEventType(.Value, withBlock: { snapshot in
            let dict = snapshot.value as! NSDictionary
            var array = dict.allKeys
            array.sortInPlace{($0 as! String) > ($1 as! String)}
            self.dataSource = array
            self.collectionView.srf_endRefreshing()
            self.activityIndicatorView!.stopAnimating()
            self.collectionView.reloadData()
            }, withCancelBlock: { error in
                print(error.description)
                self.collectionView.srf_endRefreshing()
        })
    }


    // MARK: UICollectionViewDataSource

     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = getCollectionViewCell(collectionView, cell: ProgrammeCollectionCell.self, indexPath: indexPath)
        cell.year?.text = dataSource[indexPath.row] as? String
        cell.backgroundColor = UIColor.whiteColor()
        let ref = Wilddog(url: LoveqConfig.WilddogURL + "index/programIndex/" + (dataSource[indexPath.row] as! String) )
        ref.observeEventType(.Value, withBlock: { snapshot in
            let dict = snapshot.value as! NSDictionary
            let programCount = dict["count"] as! NSString
            if programCount.isEqualToString("0"){
                cell.image?.image = UIImage.init(named: "img_year_2016")
                cell.programCount?.text = "更新中"
            }else{
                cell.image?.image = UIImage.init(named: "img_year_def")
                cell.programCount?.text = "共" + (programCount as String) + "期"
            }
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = ProgrammeDetailListViewController()
        vc.year = dataSource[indexPath.row] as? String
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}
