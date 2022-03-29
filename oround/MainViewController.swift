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
#if DEBUG
    let url = URL(string: "https://dev.oround.com")!
#else
    let url = URL(string: "https://www.oround.com")!
#endif
    
    lazy var button: UIButton = {
        let button = UIButton(frame: CGRect(x:view.frame.maxX-80,
                                            y:40,
                                            width:60,
                                            height:60))
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
    var isDarkContentBackground = false // <1>

    func statusBarEnterLightBackground() { // <2>
        isDarkContentBackground = false
        setNeedsStatusBarAppearanceUpdate()
    }

    func statusBarEnterDarkBackground() { // <3>
        isDarkContentBackground = true
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isDarkContentBackground { // <5>
            return .lightContent
        } else {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .lightContent
            }
        }
    }
    
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .darkContent
//    }
    // LoadView
    override func loadView() {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.applicationNameForUserAgent = "+OIOS/1.0.0 Safari/600.2.5"
//        if let userAgent = configuration.applicationNameForUserAgent  {
//            configuration.applicationNameForUserAgent =  userAgent + "+OIOS"
//        }
        
        
        mainWebView = WKWebView(frame:CGRect(x:0, y:0, width:UIScreen.main.bounds.maxX, height:UIScreen.main.bounds.maxY-20), configuration: configuration)
        mainWebView.navigationDelegate = self
        mainWebView.uiDelegate = self
        
        
        view = UIView()
        view.frame = UIScreen.main.bounds
        view.backgroundColor = .white
        
//        mainWebView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.maxX, height:UIScreen.main.bounds.maxY-20)
        
        view.addSubview(mainWebView)
        
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
//            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

            
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = .white
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
#if DEBUG
#else
        checkVersion()
#endif
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

        mainWebView.load(URLRequest(url: url))
        mainWebView.allowsBackForwardNavigationGestures = true
        mainWebView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
    }
    
    @objc func timerFired() {
        popupWebView?.layer.opacity = 1.0
        activityIndicator.stopAnimating()
    }

    func checkVersion() {

        let gAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let gAppBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "0"
        print("Version", gAppVersion, gAppBuild)
        
        let session = URLSession.shared
#if DEBUG
        guard let requestURL = URL(string: "https://dev-api.oround.com/api/v1/app-version") else { return }
#else
        guard let requestURL = URL(string: "https://api.oround.com/api/v1/app-version") else { return }
#endif
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let task = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) -> Void in

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode

            if(statusCode == 200)
            {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    
                    let jsonObject = jsonResponse as! NSDictionary
                    if let iosMajorVersion = jsonObject["iosMajorVersion"] {
                    if let iosMinorVersion = jsonObject["iosMinorVersion"] {
                    if let iosPatchVersion = jsonObject["iosPatchVersion"] {
                        
                        let compareResult = gAppVersion.compare("\(iosMajorVersion).\(iosMinorVersion).\(iosPatchVersion)", options: .numeric)
                        print(">>>\(compareResult.rawValue) ==> \(iosMajorVersion).\(iosMinorVersion).\(iosPatchVersion)")
                        if (compareResult.rawValue < 0) {
                            self.showUpdateModal()
                        }
                    }}}
                }
                catch let error
                {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func showUpdateModal() {
        
        let alertController = UIAlertController(title: "업데이트 알림".localized(),
                                                message: "새로운 버전이 출시되었습니다.\n업데이트 후 이용해 주시기 바랍니다.".localized(), preferredStyle: .alert)

        let okAction = UIAlertAction(title: "업데이트".localized(), style: .default) { _ in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1596427790"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: {success in
                        exit(0)
                    })
                } else {
                    UIApplication.shared.openURL(url)
                    exit(0)
                }
            }
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }

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
        let alertController = UIAlertController(title: "OROUND", message: message, preferredStyle: .alert)
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
//        configuration.applicationNameForUserAgent = "Version/8.0.2 Safari/600.2.5"
        configuration.applicationNameForUserAgent = "+OIOS/1.0.0 Safari/600.2.5"
        
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
        if url.contains("https://appleid.apple.com") == false {
            popupWebView?.layer.opacity = 1.0
        } else {
            popupWebView?.layer.opacity = 0.7
        }
        activityIndicator.startAnimating()
        var timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: false)
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
            // 나이스 인증은 result, key로 값이 리턴됨
            if let result = bodyString["result"] {
                if (result=="success") {
                    guard let key = bodyString["key"] else {return}
                    debugPrint("RECEIVED KEY **************\(key)")
                    mainWebView.evaluateJavaScript(
                        "window.postMessage({\"result\":\"success\", \"token\":\"\(key)\"});"
                        , completionHandler: nil)
                    if let popupWebView = self.popupWebView {
                        popupWebView.removeFromSuperview()
                    }
                } else {
                    mainWebView.evaluateJavaScript(
                        "window.postMessage({\"result\":\"fail\"});"
                        , completionHandler: nil)
                    if let popupWebView = self.popupWebView {
                        popupWebView.removeFromSuperview()
                    }
                }
            }
        } else if ( message.name=="setting" ) {
            let vc = SettingModalViewController()
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        }
    }
}


extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

}


extension String {
    
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
    
}
