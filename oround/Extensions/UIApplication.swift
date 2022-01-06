//
//  UIApplication.swift
//  oround
//
//  Created by thinoo on 2021/12/23.
//
import UIKit

extension UIApplication {
    struct Constants {
        static let CFBundleShortVersionString = "CFBundleShortVersionString"
    }
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

}
