//
//  MainViewControllerDelegate.swift
//  oround
//
//  Created by thinoo on 2021/12/21.
//

import Foundation
import WebKit

extension MainViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == messageHandlerName {
            if let dics: [String: Any] = message.body as? Dictionary, let action = dics["action"] as? String {
                
                let webAction = WebAction(rawValue: action)
                switch webAction {
                case .changeStatusBarColor:
                    if let color = dics["bgColor"] as? String, let isDarkIcon = dics["isDarkIcon"] as? Bool {
                        self.statusBarView?.backgroundColor = UIColor(hexString: color)
                        if isDarkIcon == true {
                            statusBarStyle = .default
                        } else {
                            statusBarStyle = .lightContent
                        }
                        setNeedsStatusBarAppearanceUpdate()
                    }
                case .goBack:
                    self.popVC()
                default:
                    print("Undefined action: \(String(describing: webAction))")
                }
            }
        }
    }
}
