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
//import SwiftRefresher
import NVActivityIndicatorView
private let reuseIdentifier = "CellID"

class ProgrammeCollectionViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var dataSource = Array<AnyObject>()
    var activityIndicatorView: NVActivityIndicatorView?
    fileprivate var _collectionView: UICollectionView!
    fileprivate var collectionView: UICollectionView{
        get{
            if (_collectionView != nil){
                return _collectionView!
            }
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: LoveqConfig.screenW * 0.25, height: 120)
            let paddingY: CGFloat = 20.0
            let paddingX: CGFloat = 20.0
            layout.sectionInset = UIEdgeInsetsMake(paddingY, paddingX, paddingY, paddingX)
            layout.minimumLineSpacing = paddingY
            _collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 50, width: LoveqConfig.screenW, height: LoveqConfig.screenH - 50), collectionViewLayout: layout)
            regCollectionViewClass(_collectionView, cell: ProgrammeCollectionCell.self)
            _collectionView.dataSource = self
            _collectionView.delegate = self
            _collectionView.backgroundColor = UIColor.white
            return _collectionView!
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        let refresher = Refresher { [weak self] () -> Void in
//            self?.loadData()
//        }
//        collectionView.srf_addRefresher(refresher)
        self.title = "全部节目"
        view.backgroundColor = UIColor.white
        view.addSubview(collectionView)

        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: NVActivityIndicatorType.ballBeat, color: UIColor.red)
        activityIndicatorView!.center = CGPoint(x: LoveqConfig.screenW * 0.5, y: LoveqConfig.screenH * 0.5)
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

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getCollectionViewCell(collectionView, cell: ProgrammeCollectionCell.self, indexPath: indexPath)
        cell.year?.text = dataSource[(indexPath as NSIndexPath).row] as? String
        cell.backgroundColor = UIColor.white
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProgrammeDetailListViewController()
        vc.year = dataSource[(indexPath as NSIndexPath).row] as? String
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}
