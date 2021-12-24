//
//  WelcomeController.swift
//  oround
//
//  Created by thepsyentist on 2021/12/18.
//

import Foundation
import UIKit
import SnapKit
import Foundation

// Access Shared Defaults Object
let userDefaults = UserDefaults.standard

// Create and Write Array of Strings


struct WelcomePageViewModel {
    let scale: CGFloat
    let textTitle: String
    let textSubTitle: String
    let imageMain: UIImage
    
    static func makeData() -> [WelcomePageViewModel] {
        var viewModels = [WelcomePageViewModel]()
        viewModels.append(contentsOf: [
            WelcomePageViewModel(
                scale:0.7,
                textTitle: "힙한 당신과 크리에이티브를 위한",
                textSubTitle: "매일 업데이트되는 유니크한 상품!",
                imageMain: UIImage(named:"or_01")!
            ),
            WelcomePageViewModel(
                scale:0.6,
                textTitle: "크리에이터 캐릭터 굿즈를 갖고 싶어",
                textSubTitle: "",
                imageMain: UIImage(named:"or_02")!
            ),
            WelcomePageViewModel(
                scale:0.5,
                textTitle: "크리에이터 캐릭터 굿즈를 갖고 싶어",
                textSubTitle: "",
                imageMain: UIImage(named:"or_03")!
            ),
            WelcomePageViewModel(
                scale:0.5,
                textTitle: "크리에이터 캐릭터 굿즈를 갖고 싶어",
                textSubTitle: "",
                imageMain: UIImage(named:"or_04")!
            ),
            WelcomePageViewModel(
                scale:0.6,
                textTitle: "크리에이터 캐릭터 굿즈를 갖고 싶어",
                textSubTitle: "",
                imageMain: UIImage(named:"or_05")!
            ),
            WelcomePageViewModel(
                scale:0.7,
                textTitle: "크리에이터 캐릭터 굿즈를 갖고 싶어",
                textSubTitle: "",
                imageMain: UIImage(named:"or_06")!
            )
        ])
        return viewModels
    }
}

func UIColorFromHex(rgb:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgb & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgb & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgb & 0xFF)/256.0

    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}

class WelcomeViewController: UIViewController, UIScrollViewDelegate {

    
//    let container = UIView()
    let pageSize = 5
    var pageDataList = WelcomePageViewModel.makeData()
    

    lazy var indicatorView: IndicatorView = {
        let indicatorView = IndicatorView(frame: CGRect(x:0, y:self.view.frame.maxY-100, width:self.view.frame.maxX, height:50))
        indicatorView.setCount(count:pageSize)
        return indicatorView
    }()
    
    lazy var scrollView: UIScrollView = {
        // Create a UIScrollView.
        let scrollView = UIScrollView(frame: self.view.frame)
        scrollView.showsHorizontalScrollIndicator = true;
        scrollView.showsVerticalScrollIndicator = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: CGFloat(pageSize) * self.view.frame.maxX, height: 30)
        return scrollView
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.frame.maxX*4,
                                            y: self.view.frame.maxY-55,
                                            width: self.view.frame.maxX,
                                            height: 55))
        button.backgroundColor = UIColorFromHex(rgb:0xFF4C4C, alpha: 1.0)
        button.setTitle("오라운드 시작하기", for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    
    func setupLayout() {
        self.view.backgroundColor = .white
        
        // Get the vertical and horizontal sizes of the view.
        let width = self.view.frame.maxX,
            height = self.view.frame.maxY
        
        // Add Images
        for i in 0 ..< pageSize {
            let image = pageDataList[i].imageMain
            let imageWidth = image.size.width*pageDataList[i].scale
            let imageHeight = image.size.height*pageDataList[i].scale
            let imageView = UIImageView(image: image)
            let marginLeft = (width - imageWidth) / 2
            let marginTop = (height - imageHeight) / 2 - 20
            debugPrint("\(i) : \(width) - \(image.size.width)")
            
            imageView.frame = CGRect(x: CGFloat(i) * width + marginLeft,
                                     y: marginTop ,
                                     width: imageWidth,
                                     height: imageHeight);
            scrollView.addSubview(imageView)
            
            if (i==4) {
                scrollView.addSubview(button)
            }
        }
        
        // Add UIScrollView, UIPageControl on view
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.indicatorView)
    }
    
    override func viewDidLoad() {
        if (userDefaults.bool(forKey: "welcomed")==true) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window!.rootViewController = MainViewController()
            }
            return;
        }
        super.viewDidLoad()
        setupLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // When the number of scrolls is one page worth.
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            // Switch the location of the page.
            indicatorView.setCurrent(current: Int(scrollView.contentOffset.x / scrollView.frame.maxX))
        }
    }
    @objc private func buttonPressed(sender: UIButton) {
        dismiss(animated: true) {
            userDefaults.set(true, forKey: "welcomed")
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window!.rootViewController = MainViewController()
            }
        }
    }
}
