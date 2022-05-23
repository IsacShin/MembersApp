//
//  LoadingBarVC.swift
//  app
//
//  Created by isac on 2020/12/18.
//  Copyright © 2020 isac. All rights reserved.
//

import UIKit

class LoadingBarVC: UIViewController {
    
    // 컴포넌트
    
    
    static var staticSelf:LoadingBarVC?
    static var isLoading = false
    @IBOutlet weak var imageView: UIImageView!
    
    // 로딩바 시작
    static func startLoading(){
        
        if staticSelf == nil {
            let sb = UIStoryboard(name: "LoadingBar", bundle: nil)
            staticSelf = sb.instantiateViewController(withIdentifier: "LoadingBarVC") as? LoadingBarVC
        }
        
        if staticSelf!.view.superview == nil {
            isLoading = true
            UIApplication.shared.keyWindow?.addSubview(staticSelf!.view)
        }
    }
    
    // 로딩바 종료
    static func stopLoading(){
        //sleep(1)
        staticSelf?.view.removeFromSuperview()
        isLoading = false
    }
    
    // 뷰 로드 후 실행
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var images: [UIImage] = []
//        for i in 0 ..< 49 {
//            let imageName = "00_ic_loading_1_000\(i)"
//            images.append(UIImage(named: imageName)!)
//        }
//        
//        self.imageView.animationImages = images
        
        self.imageView.animationDuration = 2.0
        self.imageView.startAnimating()
        
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        
    }
}
