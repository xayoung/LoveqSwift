//
//  MusicSlider.swift
//  Loveq
//
//  Created by xayoung on 16/5/21.
//  Copyright © 2016年 xayoung. All rights reserved.
//

import UIKit

class MusicSlider: UISlider {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
    }
    func setup() {
        let thumbImage = UIImage.init(named: "music_slider_circle")
        self.minimumTrackTintColor = UIColor.white
        self.setThumbImage(thumbImage, for: UIControlState.highlighted)
        self.setThumbImage(thumbImage, for: UIControlState())
        
    }
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var newRect = CGRect.init()
        newRect.origin.x = rect.origin.x - 10
        newRect.origin.y = rect.origin.y + 2
        newRect.size.width = rect.size.width + 20
        return super.thumbRect(forBounds: bounds, trackRect: newRect, value: value).insetBy(dx: 10, dy: 10)
    }

}
