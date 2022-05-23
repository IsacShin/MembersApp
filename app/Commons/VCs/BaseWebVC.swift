//
//  BaseWebVC.swift
//  app
//
//  Created by isac on 2021/01/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

enum modalType {
    case base    // 기본 상세anim
    case modal   // 모달 뷰anim
}

class BaseWebVC: UIViewController {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var headerView: UIView! {
        didSet {
            if self.webViewType == .modal {
                self.headerView.isHidden = true
                self.headerView.snp.makeConstraints { m in
                    m.height.equalTo(0)
                }
            }else {
                self.headerView.isHidden = false
                self.headerView.snp.makeConstraints { m in
                    m.height.equalTo(49)
                }
            }
        }
    }
    
    // 변수 : 컴포넌트
    var webView: WKWebView!
    
    var mbilUrl: String?
    var titleStr:String?
    
    var footerView: FooterView?
    var isNeedLoading: Bool = true
    
    var footerInset: CGFloat {
        let FooterHeight: CGFloat = 60
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = (window?.safeAreaInsets.bottom) ?? 0
            return bottomPadding + FooterHeight
        } else {
            return bottomLayoutGuide.length + FooterHeight
        }
    }
    
    var webViewType:modalType = .base {
        didSet {
            if webViewType == .modal {
                self.initFooterView()
            }
        }
    }
    
    var dimView: UIView!
        
    @IBOutlet weak var titleLbl: UILabel!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWebview()
        self.requestWebView(mbilUrl ?? "")
        if let title = self.titleStr {
            self.titleLbl.text = title
        }
        
    }
    
    deinit {
        self.webView?.stopLoading()
        self.webView.navigationDelegate = nil
        self.webView.uiDelegate = nil
        self.webView.scrollView.delegate = nil
        self.webView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if LoadingBarVC.isLoading {
            LoadingBarVC.stopLoading()
        }
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default //.default for black style
    }
    
    override func viewDidAppear(_ animated: Bool) {
  
        self.navigationController?.hero.isEnabled = false
        self.webView.reload()
        
        if webViewType == .modal {
            // 스와이프 백 막기
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    func initFooterView() {
        self.footerView = FooterCloseView.initView(self.view, handler: {
            self.closeVC()
        })
    }

    /// 웹뷰 생성
    func createWebview() {
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.selectionGranularity = .character
        
        let controller = WKUserContentController()
        controller.add(self, name: "callbackHandler")
        
        config.userContentController = controller
        config.applicationNameForUserAgent = CHTP.userAgent
        config.processPool = CHTP.commonProcessPool
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        
        self.webView = WKWebView.init(frame: self.containerView.frame, configuration: config)
        self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.webView.backgroundColor = .white
        self.webView.scrollView.backgroundColor = .white
        
        self.webView.uiDelegate          = self
        self.webView.navigationDelegate  = self
        self.webView.scrollView.delegate = self
        
        if #available(iOS 11.0, *) {
            self.webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        self.containerView.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.containerView)
        }
    }
    
    // 웹뷰 요청
    func requestWebView(_ urlStr:String) {
        if let value = URL(string:urlStr) {
            var request = URLRequest(url: value, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
            
//            let currentAppVer = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
//            request.setValue(currentAppVer, forHTTPHeaderField: "appVer")
//
//            if UserInfo.isLogin {
//                // 헤더 설정
//                let mbrno: String  = UserDefaults.standard.string(forKey: "mbrNo") ?? ""
//                let tknVal: String = UserDefaults.standard.string(forKey: "tknVal") ?? ""
//
//                request.setValue(mbrno, forHTTPHeaderField: "mbrNo")
//                request.setValue(tknVal, forHTTPHeaderField: "accessToken")
//            }

            self.webView.load(request)
        }
    }
    
    func openUrl(_ urlString: String, _ handler:(() -> Void)? = nil) {
        
        if urlString.hasPrefix("kakaolink") {
            guard let url = URL(string: urlString) else {
                return //be safe
            }
            print("url : \(url)")
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { (result) in
                    handler?()
                }
                
            } else {
                UIApplication.shared.openURL(url)
                handler?()
            }
        } else {
            // 퍼센트 인코딩
            var percentEncoding = CharacterSet.urlQueryAllowed
            percentEncoding.insert(charactersIn: "#")
            
            if let encodingUrl = urlString.addingPercentEncoding(withAllowedCharacters: percentEncoding) {
                guard let url = URL(string: encodingUrl) else {
                    return //be safe
                }
                print("url : \(url)")
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:]) { (result) in
                        handler?()
                    }
                    
                } else {
                    UIApplication.shared.openURL(url)
                    handler?()
                }
            }
        }
    }
    
    func commonProtocol(baseUrl: String, requestUrl: String, mainWebView: WKWebView?, refreshCompletion: (() -> Void)?) -> Bool {
        
        let stringURL = requestUrl.components(separatedBy: ":::")
        
        print("PROTOCOL : \(requestUrl)")
        
        if stringURL.count > 0 && stringURL[0].lowercased() == "ToApp".lowercased() {
            guard stringURL.count > 1 else {
                return false
            }
            let functionType = stringURL[1].lowercased()
            if functionType == "AppViewMove".lowercased() {
                guard stringURL.count > 2 else {
                    return false
                }
                let functionName = stringURL[2].lowercased()
                
                // 내부 이동 toapp:::AppViewMove:::SubView:::(Title):::(FullURL)
                if functionName == "TitleSubView".lowercased() {
                    guard stringURL.count > 4 else {
                        return true
                    }
                    let urlStr = stringURL[4]
                    if !urlStr.isEmpty {
                        self.navigationController?.hero.isEnabled = false
                                                
                        return true
                    }
                }
                    
                
            }
        }
        
        else if requestUrl.contains("itunes.apple.com") || requestUrl.contains("phobos.apple.com") {
                        
            openUrl(requestUrl)
            return true
        } else if requestUrl.starts(with: "http") || requestUrl.starts(with: "https") || requestUrl.starts(with: "about")  {
            return false
            
        } else {
            openUrl(requestUrl)
            return true
        }
        return false
    }
    
    func closeVC() {
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        
        navigationController?.view.layer.add(transition, forKey:kCATransition)
        let _ = navigationController?.popViewController(animated: false)
    }
    
}

// MARK: - Touch Event

extension BaseWebVC {
    @IBAction func backBtnPressed(_ sender: Any) {
        if webViewType == .modal {
            self.closeVC()
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - WKNavigationDelegate

extension BaseWebVC: WKNavigationDelegate {
    
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LoadingBarVC.startLoading()
    }
    
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let baseUrl     = webView.url?.absoluteString ?? ""
        let requestUrl  = navigationAction.request.url?.absoluteString ?? ""
        
        print("\(baseUrl) && \(requestUrl)")
        
        if self.commonProtocol(baseUrl: baseUrl,
                               requestUrl: requestUrl, mainWebView: self.webView, refreshCompletion: {
                                if let urlString = self.webView?.url?.absoluteString {
                                    self.requestWebView(urlString)
                                }
        }) {
            decisionHandler(.cancel)
            return
        }
        
        if requestUrl.contains("app://") {
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.moveScheme(scheme: requestUrl)
            
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingBarVC.stopLoading()
    }
    
    @available(iOS 8.0, *)
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        LoadingBarVC.stopLoading()
    }
}


// MARK: - UIScrollViewDelegate
extension BaseWebVC: UIScrollViewDelegate {
    
    // 푸터 효과
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
        if(velocity.y > 0) {
            self.footerView?.hideFooter()
        }else{
            self.footerView?.showFooter()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}


// MARK: - WKScriptMessageHandler
extension BaseWebVC: WKScriptMessageHandler {
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        print("\(message)")
        
    }
    
}

// MARK: - WKUIDelegate
extension BaseWebVC: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        
        if self.isNeedLoading {
            LoadingBarVC.stopLoading()
        }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { (action) in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            if self.isViewLoaded && (self.view.window != nil) {
                self.present(alertController, animated: true, completion: nil)
            }else {
                completionHandler()
            }
            
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        
        if self.isNeedLoading {
            LoadingBarVC.stopLoading()
        }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 새탭 열리는 부분 확장
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if let controller = UIStoryboard(name: "Base", bundle: nil).instantiateViewController(withIdentifier: "BaseWebVC") as? BaseWebVC {
            let urlStr = navigationAction.request.url?.absoluteString ?? ""

            CommonNav.moveBaseWebVC(urlStr)



            return controller.webView
        }
        
    
        
        return WKWebView(frame: view.bounds, configuration: configuration)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
