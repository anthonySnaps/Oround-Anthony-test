//
//  ViewController.swift
//  oround
//
//  Created by thepsyentist on 12/12/21
//

import UIKit
import WebKit
//import Promises
import AppTrackingTransparency
import AdSupport

class MainViewController: UIViewController,
                          WKNavigationDelegate,
                          WKUIDelegate {
    
    // View
    var mainWebView: WKWebView!
    var popupWebView: WKWebView?
    let popupViewContentController = WKUserContentController()
    

    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x:30,
                                            y:45,
                                            width:50,
                                            height:50))
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
//        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named:"x2"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        // Create an indicator.
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: view.frame.maxX/2, y: view.frame.maxY/2, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.red
        // Also show the indicator even when the animation is stopped.
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.white
        // Start animation.
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
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
        
//        // 1.
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
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
        
        // Ask Tracking Permission
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    print("Authorized")
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    print("Denied")
                case .notDetermined:
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
    
    /**********
     * Setup UI
     */
    func setupLayout() {
        let url = URL(string: "https://www.oround.com")!
        mainWebView.load(URLRequest(url: url))
        mainWebView.allowsBackForwardNavigationGestures = true
        mainWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    }
    
    @objc func timerFired() {
        popupWebView?.layer.opacity = 1.0
        activityIndicator.stopAnimating()
    }

    /**********
     * Alert
     */
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Oround", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**********
     * Confirm
     */
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "test", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    /**********
     * Popup
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures)
    -> WKWebView? {
        let userController = WKUserContentController()
        userController.add(self, name: "oround")
        userController.add(self, name: "setting")
        configuration.userContentController = userController
        configuration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        
        popupWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView?.navigationDelegate = self
        popupWebView?.uiDelegate = self
        popupWebView?.addSubview(button)
        popupWebView?.addSubview(activityIndicator)
    
        
        debugPrint("FRAME : \(button.frame)")
        view.addSubview(popupWebView!)
        return popupWebView!
    }
    
    func webView(_ webView:WKWebView, didFinish navigation:WKNavigation!) {
//        timer.invalidate()
        popupWebView?.layer.opacity = 1.0
        activityIndicator.stopAnimating()
    }

  
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        print("@@@  decidePolicyFor navigationAction")
        guard let requestURL = navigationAction.request.url else {return}
        let url = requestURL.absoluteString
        let hostAddress = navigationAction.request.url?.host
        // To connnect app store
        if hostAddress == "itunes.apple.com" {
            if UIApplication.shared.canOpenURL(requestURL) {
                UIApplication.shared.open(requestURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
#if DEBUG
        print("=====>url = \(url), host = \(hostAddress?.description ?? "")")
        
#endif
        popupWebView?.layer.opacity = 0.8
        activityIndicator.startAnimating()
        var timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
        let url_elements = url.components(separatedBy: ":")
        if url_elements[0].contains("http") == false &&
            url_elements[0].contains("https") == false {
            
            if UIApplication.shared.canOpenURL(requestURL) {
                UIApplication.shared.open(requestURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            } else {
                // 만약  Info.plist의 white list에 등록되지 않은 앱 스키마가 있는 경우를 위해 사용, 신용카드 결제화면등을 위해 필요, 해당 결제앱 스키마 호출
                if url.contains("about:blank") == true {
                    print("@@@ Browser can't be opened, about:blank !! @@@")
                }else{
                    print("@@@ Browser can't be opened, but Scheme try to call !! @@@")
                    UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
                }
                
            }
            
            decisionHandler(.cancel)
            return
            
        }
        decisionHandler(.allow)
        
    }
    
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
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



extension MainViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if ( message.name=="oround" ) {
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
        } else if ( message.name=="setting" ) {
            let vc = SettingModalViewController()
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        }
    }
}

