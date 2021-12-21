//
//  OroundPageContol.swift
//  oround
//
//  Created by thinoo on 2021/12/20.
//

import Foundation


class IndicatorView: UIView {
    let x = 30
    let y = 30
    var count = 0
    var current = 0
    weak var activeImage:UIImage!
    weak var inactiveImage:UIImage!
    var imageViews: [UIImageView] = []
    
    
    override init(frame:CGRect) {
        super.init(frame:frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setCount(count:Int) {
        self.count = count
        self.setupLayout()
        self.setCurrent(current:0)
    }
    func setCurrent(current:Int) {
        self.current = current
        
        for i in (0...self.count-1) {
            if (i==current) {
                imageViews[i].image = UIImage(named:"dot_on")
            } else {
                imageViews[i].image = UIImage(named:"dot_off")
            }
        }
    }
    
    func setupLayout() {
        debugPrint("current \(self.frame.maxX)")
        let marginLeft = Int(CGFloat(self.frame.maxX) - CGFloat(self.count*12))/2;
        for i in (0...self.count-1) {
            let imageView = UIImageView(image:activeImage);
            imageView.frame = CGRect(x: marginLeft + i*12, y:0, width:10, height:10)
            debugPrint("current \(imageView.frame)")
            self.addSubview(imageView)
            imageViews.append(imageView)
        }
    }
}

