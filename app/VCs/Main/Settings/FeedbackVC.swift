//
//  FeedbackVC.swift
//  app
//
//  Created by 신이삭 on 2021/09/03.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FeedbackVC: BaseVC {
    
    // 제목관련
    @IBOutlet weak var titlePlaceholder: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    // 사진첨부 관련
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var imagePlaceholder: UILabel!
     
    // 내용관련
    @IBOutlet weak var commentPlaceholder: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    let picker = UIImagePickerController()
    var etcTxt:String = ""
    var selectImg:Data?
    
    var addBtnState:Bool = false {
        didSet {
            self.addBtn.isUserInteractionEnabled = addBtnState
            if addBtnState == false {
                self.addBtn.backgroundColor = .lightGray
                self.bottomView.backgroundColor = .lightGray
                
            }else {
                self.addBtn.backgroundColor = .darkGray
                self.bottomView.backgroundColor = .darkGray
                
             
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addBtnState = false
        hideKeyboard()
        
        picker.delegate = self
        
        titleTextField.delegate = self
        commentTextView.delegate = self
        
        self.titleTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        titleTextField.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        commentTextView.addObserver(self, forKeyPath: "text", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            if titleTextField.text != "" && commentTextView.text != "" {
                self.addBtnState = true
            }else {
                self.addBtnState = false
            }
        }
    }
    
    deinit {
        self.titleTextField.removeObserver(self, forKeyPath: "text")
        self.commentTextView.removeObserver(self, forKeyPath: "text")
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        //옵져버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    
    // 키보드 팝업 처리
    @objc func keyboardWillShow(_ sender: Notification) {

        //self.view.frame.origin.y = -265

    }
    
    // 키보드 숨김 처리
    @objc func keyboardWillHide(_ sender: Notification) {

        //self.view.frame.origin.y = 0
    }
    
    // 뒤로가기
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // 이미지 버튼 클릭 시
    @IBAction func imageBtnPressed(_ sender: Any) {
        openGallary()
    }
    
    // 등록하기
    @IBAction func sendBtnPressed(_ sender: Any) {
        if let img = selectImg {
            self.imageUpload(img: img) { result -> Void in
                if result == "Y" {
                    CommonAlert.showAlertType1(vc: self, title: "", message: "피드백이 등록되었습니다.", completeTitle: "확인") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }

        }
    }
    
    @objc func openGallary() {
        self.picker.allowsEditing = true
        self.picker.sourceType = .photoLibrary
        
        self.present(self.picker, animated: false, completion: nil)
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if titleTextField.text == "" {
            titlePlaceholder.isHidden = false
        }else {
            titlePlaceholder.isHidden = true
        }
    }
    
}

extension FeedbackVC:UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension FeedbackVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            commentPlaceholder.isHidden = false
        }else {
            commentPlaceholder.isHidden = true
        }
    }
    
    

}

extension FeedbackVC {
    func imageUpload(img:Data!, completion:((String?)->Void?)?) {
    
        let parameters: [String : Any] = [
            "qna_title": titleTextField.text?.trimSpaceLine() ?? "",
            "qna_comment": commentTextView.text.trimSpaceLine() ?? "",
            "member_idx": uuidStr
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
            }
            multipartFormData.append(img, withName: "file0", fileName: "file0.jpg", mimeType: "image/jpeg")
        }, to: INSERT_QNA)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                if let hadler = completion {
                    hadler(json["result"].string)
                }
                
            case .failure(let error):
                if let code = error.responseCode {
                    if code == 500 {
                        CommonAlert.showAlertType1(vc: self, message: "서비스가 지연되고있습니다. 다시 시도해주세요.") {}
                        return
                    }
                }
            }
        }
    }
}

extension FeedbackVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //이미지 선택시 처리 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(image)
            self.imageBtn.setImage(image, for: .normal)
            let putImage = image.jpegData(compressionQuality: 0.1)
            self.selectImg = putImage
            self.imagePlaceholder.text = "이미지가 첨부 되있습니다."
        }
        
        self.dismiss(animated: true) {}
        
    }
}
