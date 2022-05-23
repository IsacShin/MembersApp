//
//  NetworkManager.swift
//  app
//
//  Created by isac on 2021/01/27.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import WebKit
import Alamofire
import SwiftyJSON

let DOMAIN                  = "http://220.79.178.228:8080"

let TEST_API_URL            = "https://httpbin.org/get"
let STUDENT_LIST_URL        = DOMAIN + "/getStudentList.do"
let IMG_UPLOAD              = DOMAIN + "/upload2.do"
let INSERT_STUDENT          = DOMAIN + "/inserStudent.do"
let DELETE_STUDENT          = DOMAIN + "/removeStudent.do"
let UPDATE_STUDENT          = DOMAIN + "/updateStudent.do"
let INSERT_QNA              = DOMAIN + "/qna/insert.do"

class CommonHttp:NSObject {
    static let shared = CommonHttp()
    private override init() {
        // 저장돼있는 HTTP 쿠키 제거
        if let cookieStorage = AF.session.configuration.httpCookieStorage, let cookies = cookieStorage.cookies {
            for cookie in cookies {
                cookieStorage.deleteCookie(cookie)
            }
        }
    }
    
    var wvTemp: WKWebView?  // 쿠키 저장용 임시 웹뷰
    
    /// 앱에서 사용 할 User-Agent
    var userAgent = ""
        
    /// HTTP Headers
    var httpHeaders: HTTPHeaders {
        let config = URLSessionConfiguration.af.default
        config.headers.update(name: "User-Agent", value: self.userAgent)
        //config.headers.update(name: "Content-Type", value: "application/json")
        
        return config.headers
    }
    
    let commonProcessPool = WKProcessPool()
    
    private func setCookies(_ cookies: [HTTPCookie], complete: @escaping (() -> Void)) {
        let webVC = UIStoryboard(name: "Base", bundle: nil).instantiateViewController(withIdentifier: "BaseWebVC") as? BaseWebVC
        if let webView = webVC?.webView { // 웹뷰가 생성된 경우
            self.wvTemp = webView
        } else { // 웹뷰 생성 전이면 임시 웹뷰 생성
            let config = WKWebViewConfiguration()
            config.processPool = CHTP.commonProcessPool //여러 웹뷰가 존재 할시 쿠키 동기화
            config.preferences.javaScriptEnabled = true
            config.preferences.javaScriptCanOpenWindowsAutomatically = false
            config.selectionGranularity = .character

            self.wvTemp = WKWebView(frame: .zero, configuration: config)
        }
        
        if #available(iOS 11, *) { // iOS 11 이상 쿠키 동기화

            let iCookieCount = cookies.count
            if iCookieCount == 0 { // 쿠키가 없으면 종료
                complete()
            } else { // 쿠키가 있으면 해당 쿠키를 저장
                var iCompletedCount = 0
                for cookie in cookies {
                    self.wvTemp?.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                        iCompletedCount += 1
                        if iCookieCount == iCompletedCount { // 모든 쿠키 저장 완료
                            complete()
                        }
                    }
                }
            }

        } else { // iOS 11 미만 쿠키 동기화

            for cookie in cookies {
                if let url = URL(string: cookie.domain) {
                    var request = URLRequest(url: url)
                    if let properties = cookie.properties {
                        for property in properties {
                            if let value = property.value as? String {
                                request.addValue(value, forHTTPHeaderField: property.key.rawValue)
                            }
                        }
                    }
                    self.wvTemp?.load(request)
                }
            }
        }
    }
    
    /// 서버 요청 공통 함수
    /// - Parameters:
    ///   - url: 요청 API URL
    ///   - params: 파라미터
    ///   - success: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    private func requestJSON(url: String,
                             method: HTTPMethod = .get,
                             params: Parameters?,
                             showLoading: Bool = true,
                             vc:UIViewController = UIViewController(),
                             success: ((JSON) -> Void)?,
                             failure: ((AFError, JSON?) -> Void)?) {
        if showLoading {
            LoadingBarVC.startLoading()
        }
        
        print("start: " + url)
        
        var paramEncoding: ParameterEncoding
        if method == .post { // post 요청이면 body에 들어가도록 json 인코딩
            paramEncoding = URLEncoding.httpBody
        } else { // 나머지는 쿼리 형식으로 인코딩
            paramEncoding = URLEncoding.default
        }
        
        let headers = self.httpHeaders
       
        AF.request(url, method: method, parameters: params, encoding: paramEncoding, headers: headers)
            { $0.timeoutInterval = 7 }
            .validate()
            .responseJSON { response in
            print("finished: " + url)
            if showLoading {
                LoadingBarVC.stopLoading()
            }
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
               
                success?(json)
            case .failure(let error):
                if let code = error.responseCode {
                    if code == 500 {
                        CommonAlert.showAlertType1(vc: vc, message: "서비스가 지연되고있습니다. 다시 시도해주세요.") {}
                        return
                    }
                }
                failure?(error, nil)
            }
        }
    }
    
    /// 테스트 API 조회
    /// - Parameters:
    ///   - param: 데이터 조회용 파라미터
    ///   - complete: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    func getTestAPI(param: [String: Any]? = nil,
                    vc:UIViewController = UIViewController(),
                    complete: ((JSON) -> Void)?,
                    failure: ((Error, JSON?) -> Void)? = nil) {
        self.requestJSON(url: TEST_API_URL,
                         method: .get,
                         params: param,
                         vc: vc,
                         success: complete,
                         failure: failure)
    
    }
    
    /// 수강생 목록 API 조회
    /// - Parameters:
    ///   - param: 수강생 목록 조회
    ///   - complete: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    func getStudentList(param: [String: Any]? = nil,
                    vc:UIViewController = UIViewController(),
                    complete: ((JSON) -> Void)?,
                    failure: ((Error, JSON?) -> Void)? = nil) {
        self.requestJSON(url: STUDENT_LIST_URL,
                         method: .get,
                         params: param,
                         vc: vc,
                         success: complete,
                         failure: failure)
    
    }
    
    /// 수강생 등록
    /// - Parameters:
    ///   - param: 수강생 등록
    ///   - complete: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    func insertStudent(param: [String: Any]? = nil,
                   vc:UIViewController = UIViewController(),
                   complete: ((JSON) -> Void)?,
                   failure: ((Error, JSON?) -> Void)? = nil) {
        self.requestJSON(url: INSERT_STUDENT,
                         method: .get,
                         params: param,
                         vc: vc,
                         success: complete,
                         failure: failure)
        
    }
    
    /// 수강생 삭제
    /// - Parameters:
    ///   - param: 수강생 삭제
    ///   - complete: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    func deleteStudent(param: [String: Any]? = nil,
                   vc:UIViewController = UIViewController(),
                   complete: ((JSON) -> Void)?,
                   failure: ((Error, JSON?) -> Void)? = nil) {
        self.requestJSON(url: DELETE_STUDENT,
                         method: .post,
                         params: param,
                         vc: vc,
                         success: complete,
                         failure: failure)
        
    }
    
    /// 수강생 수정
    /// - Parameters:
    ///   - param: 수강생 수정
    ///   - complete: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    func updateStudent(param: [String: Any]? = nil,
                   vc:UIViewController = UIViewController(),
                   complete: ((JSON) -> Void)?,
                   failure: ((Error, JSON?) -> Void)? = nil) {
        self.requestJSON(url: UPDATE_STUDENT,
                         method: .get,
                         params: param,
                         vc: vc,
                         success: complete,
                         failure: failure)
        
    }
    /// QNA 등록
    /// - Parameters:
    ///   - param: QNA 등록
    ///   - complete: 성공 시 콜백
    ///   - failure: 실패 시 콜백
    func insertQNA(param: [String: Any]? = nil,
                   vc:UIViewController = UIViewController(),
                   complete: ((JSON) -> Void)?,
                   failure: ((Error, JSON?) -> Void)? = nil) {
        self.requestJSON(url: INSERT_QNA,
                         method: .get,
                         params: param,
                         vc: vc,
                         success: complete,
                         failure: failure)
        
    }
    
}
