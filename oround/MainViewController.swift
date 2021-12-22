//
//  ViewController.swift
//  oround
//
//  Created by thepsyentist on 12/12/21
//

import UIKit
import WebKit
//import Promises

class MainViewController: UIViewController,
                          WKNavigationDelegate,
                          WKUIDelegate {
    
    // Viewx
    var mainWebView: WKWebView!
    var popupWebView: WKWebView?
    let popupViewContentController = WKUserContentController()
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x:100,
                                            y:self.view.frame.maxX - 60,
                                            width:50,
                                            height:50))
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        button.setImage(UIImage(named:"x"), for: .normal)// 이미지 넣기
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.semanticContentAttribute = .forceRightToLeft //<- 중요
        
        button.imageEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 15) //<- 중요
        return button
    }()
    
    
    // LoadView
    override func loadView() {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        mainWebView = WKWebView()
        mainWebView.navigationDelegate = self
        mainWebView.uiDelegate = self
        
        view = mainWebView

        // 1.
        if #available(iOS 13.0, *) {

            let margin = view.layoutMarginsGuide
            let statusbarView = UIView()
            statusbarView.backgroundColor = .white
            statusbarView.frame = CGRect.zero
            view.addSubview(statusbarView)
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
   
            NSLayoutConstraint.activate([
                statusbarView.topAnchor.constraint(equalTo: view.topAnchor),
                statusbarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
                statusbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                statusbarView.bottomAnchor.constraint(equalTo: margin.topAnchor)
            ])
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = .white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        popupWebView?.addSubview(button)
    }
    
    // Setup
    func setupLayout() {
        let url = URL(string: "https://www.oround.com")!
        mainWebView.load(URLRequest(url: url))
        mainWebView.allowsBackForwardNavigationGestures = true
        mainWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    }
    
    /**
     * POPUP Window
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures)
    -> WKWebView? {
        let userController = WKUserContentController()
        userController.add(self, name: "oround")
        configuration.userContentController = userController
        configuration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        
        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView?.navigationDelegate = self
        popupWebView?.uiDelegate = self
        
        view.addSubview(popupWebView!)
        return popupWebView!
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupWebView {
            webView.removeFromSuperview()
            popupWebView = nil
        }
    }
    
    
    @objc private func buttonPressed(sender: UIButton) {
        dismiss(animated: true) {
            debugPrint("buttonTime")
            if let popupWebView = self.popupWebView {
                popupWebView.removeFromSuperview()
            }
            
        }
    }
}


//var jsonStringToDictionary: [String: AnyObject]? {
//    if let data = data(using: String.Encoding.utf8) {
//        do {
//            return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
//
//        } catch let error as NSError {
//            print(error)
//        }
//    }
//    return nil
//}



extension MainViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let bodyString = message.body as? [String: String] else { return }
        
        if let token = bodyString["token"] {
            debugPrint("RECEIVED**************\(token)")
            mainWebView.evaluateJavaScript(
                "window.postMessage({\"token\":\"\(token)\"});"
                , completionHandler: nil)
            if let popupWebView = self.popupWebView {
                popupWebView.removeFromSuperview()
            }
        }
        
        
    }
}
class JsonItem: NSObject {
    var token = ""
    var value = ""
}


