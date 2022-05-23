//
//  AddMembersVC.swift
//  app
//
//  Created by 신이삭 on 2021/06/25.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import TextFieldEffects
import Alamofire
import SwiftyJSON

enum VCType {
    case add    // 등록 페이지
    case detail   // 상세 페이지
}


class AddMembersVC: BaseVC {
    
    @IBOutlet weak var addImgBtn: UIButton!
    @IBOutlet weak var memName: HoshiTextField!
    @IBOutlet weak var memAge: UIDatePicker!
    @IBOutlet weak var memMaleBtn: UIButton!
    @IBOutlet weak var memFemaleBtn: UIButton!
    @IBOutlet weak var memPnum: HoshiTextField!
    @IBOutlet weak var memEtc: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var etcTxtView: UITextView!
    @IBOutlet weak var etcWrapView: UIView!
    @IBOutlet weak var userImg: UIImageView!
    
    @IBOutlet weak var stdStartDate: UIDatePicker!
    @IBOutlet weak var stdEndDate: UIDatePicker!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var bottomView1: UIView!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var bottomView3: UIView!
    
    let picker = UIImagePickerController()
    var selectImg:Data?
    var sex:String = "M"
    var etcTxt:String = ""
    var addBtnState:Bool = false {
        didSet {
            self.addBtn.isUserInteractionEnabled = addBtnState
            self.updateBtn.isUserInteractionEnabled = addBtnState
            if addBtnState == false {
                self.addBtn.backgroundColor = .darkGray
                self.bottomView1.backgroundColor = .darkGray
                
                self.updateBtn.backgroundColor = .darkGray
                self.bottomView2.backgroundColor = .darkGray
            }else {
                self.addBtn.backgroundColor = COLOR_PURPLE
                self.bottomView1.backgroundColor = COLOR_PURPLE
                
                self.updateBtn.backgroundColor = COLOR_PURPLE
                self.bottomView2.backgroundColor = COLOR_PURPLE
            }
        }
    }
    
    var stdList:JSON = JSON()
    
    var vcType:VCType = .add
    var stdIdx:String?
    
    var prevImg:Data?
    var prevImgUrl:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()
        
        if vcType == .detail {
            self.updateBtn.isHidden = false
            self.deleteBtn.isHidden = false
            self.addBtn.isHidden = true
            
            self.bottomView1.isHidden = true
            self.bottomView2.isHidden = false
            self.bottomView3.isHidden = false
            
            getStdListData()
        }else {
            self.updateBtn.isHidden = true
            self.deleteBtn.isHidden = true
            self.addBtn.isHidden = false
            
            self.bottomView1.isHidden = false
            self.bottomView2.isHidden = true
            self.bottomView3.isHidden = true
        }
        
        //delegate Set
        memName.delegate = self
        memPnum.delegate = self
        memEtc.delegate = self
        self.picker.delegate = self
        
        self.memMaleBtn.layer.cornerRadius = 12
        self.memFemaleBtn.layer.cornerRadius = 12
        
        // 참고사항 텍스트뷰 레이아웃 set
        self.etcWrapView.layer.borderWidth = 1
        self.etcWrapView.layer.borderColor = COLOR_MINT.cgColor
        self.etcWrapView.layer.cornerRadius = 12
        
        self.etcTxtView.text = "기타 참고사항을 입력해주세요."
        self.etcTxtView.textColor = UIColor(hex: "9A9A9A")
        
        self.addBtnState = false
        
        self.memMaleBtn.backgroundColor = COLOR_PURPLE
        self.memFemaleBtn.backgroundColor = .darkGray
        
        memName.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        memPnum.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            if memName.text != "" && memPnum.text != "" {
                self.addBtnState = true
            }else {
                self.addBtnState = false
            }
        }
    }
    
    deinit {
        self.memName.removeObserver(self, forKeyPath: "text")
        self.memPnum.removeObserver(self, forKeyPath: "text")
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        //옵져버 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    
    func deleteStdReq() {
        var param = [String:Int]()
        
        if let idx = self.stdIdx {
            param = [
                "std_idx" : Int(idx)!
            ]
        }
        
        CHTP.deleteStudent(param: param, vc: self) { result in
            if result["resultCode"].int == 200 {
                self.navigationController?.popViewController(animated: true)
            }else {
                CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                    
                }
            }
        } failure: { err, _ in
            CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                print(err)
            }
        }

    }
    
    func setDetailInfo() {
        
        if let stdImg = self.stdList[0]["student_img"].string {
            self.prevImgUrl = stdImg
            let url = URL(string: stdImg)
            if let data = try? Data(contentsOf: url!) {
                let putImage = UIImage(data: data)!.jpegData(compressionQuality: 0.1)
                self.selectImg = putImage
                self.prevImg = putImage
            }
            self.userImg.kf.setImage(with: URL(string: stdImg))
        }
        
        if let stdName = self.stdList[0]["student_name"].string {
            self.memName.text = stdName
        }
        
        if let stdPnum = self.stdList[0]["student_phone_num"].string {
            self.memPnum.text = stdPnum
        }
        
        if let stdSex = self.stdList[0]["student_sex"].string {
            if stdSex == "M" {
                self.memMaleBtn.backgroundColor = COLOR_PURPLE
                self.memFemaleBtn.backgroundColor = .darkGray
            }else {
                self.memMaleBtn.backgroundColor = .darkGray
                self.memFemaleBtn.backgroundColor = COLOR_PURPLE
            }
        }
        
        if let stdBrith = self.stdList[0]["student_birth"].string {
            
            let dateTime = self.formatter.date(from: stdBrith)
            if let date = dateTime {
                self.memAge.setDate(date, animated: true)
            }
        }
        
        if let stdStdate = self.stdList[0]["student_start_date"].string {
            let dateTime = self.formatter.date(from: stdStdate)
            if let date = dateTime {
                self.stdStartDate.setDate(date, animated: true)
            }
        }
        
        if let stdEnddate = self.stdList[0]["student_end_date"].string {
            let dateTime = self.formatter.date(from: stdEnddate)
            if let date = dateTime {
                self.stdEndDate.setDate(date, animated: true)
            }
        }
        
        if let stdEtc = self.stdList[0]["student_note"].string {
            self.etcTxt = stdEtc
            self.etcTxtView.text = stdEtc
        }
        
    }
    
    // 키보드 팝업 처리
    @objc func keyboardWillShow(_ sender: Notification) {

        self.view.frame.origin.y = -265

        
    }
    
    // 키보드 숨김 처리
    @objc func keyboardWillHide(_ sender: Notification) {

        self.view.frame.origin.y = 0
    }
    
    @objc func openGallary() {
        self.picker.allowsEditing = true
        self.picker.sourceType = .photoLibrary
        
        self.present(self.picker, animated: false, completion: nil)
    }
    
    @objc func openCamera() {
        self.picker.allowsEditing = true
        self.picker.sourceType = .camera
        
        self.present(self.picker, animated: false, completion: nil)
    }
    
    @objc func showAlert() {
        let alert = UIAlertController(title: "사진", message: "유형을 선택해주세요", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "카메라", style: .default, handler: { (action) in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "갤러리", style: .default, handler: { (action) in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(alert,animated: true,completion: nil)
        
    }
    
    func validDate(startDate:Date, endDate:Date) -> Bool{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        if let daysString = formatter.string(from: startDate, to: endDate) {
            print("\(daysString)만큼 차이납니다.")
            let day = daysString.components(separatedBy: " day")[0]
            if Int(day)! >= 0 {
                return true
            }else {
                return false
            }
        }

        return false
    }
    
    func stdReqNetwork() {
        dismissKeyboard()
        
        if !validDate(startDate: self.stdStartDate.date, endDate: self.stdEndDate.date) {
            CommonAlert.showAlertType1(vc: self, message: "수강기간 날짜를 확인해주세요.", completeTitle: "확인") {}
            return
        }
        
        if let img = self.selectImg {
            if let prevImg = self.prevImg {
                if prevImg == img { // 이미지 재등록 방지
                    if self.vcType == .add {
                        self.reqInsertStd(prevImgUrl) {
                            
                            CommonAlert.showAlertType1(vc: self, message: "수강생이 등록되었습니다.") {
                               
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                    }else {
                        self.reqUpdateStd(prevImgUrl) {
                            
                            CommonAlert.showAlertType1(vc: self, message: "수강생 정보가 수정되었습니다.") {
                               
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                    }
                }else {
                    self.imageUpload(img: img) { imgUrl -> Void in
                        if self.vcType == .add {
                            self.reqInsertStd(imgUrl) {
                                
                                CommonAlert.showAlertType1(vc: self, message: "수강생이 등록되었습니다.") {
                                   
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            }
                        }else {
                            self.reqUpdateStd(imgUrl) {
                                
                                CommonAlert.showAlertType1(vc: self, message: "수강생 정보가 수정되었습니다.") {
                                   
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            }
                        }
                    }
                }
            }else {
                self.imageUpload(img: img) { imgUrl -> Void in
                    if self.vcType == .add {
                        self.reqInsertStd(imgUrl) {
                            
                            CommonAlert.showAlertType1(vc: self, message: "수강생이 등록되었습니다.") {
                               
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                    }else {
                        self.reqUpdateStd(imgUrl) {
                            
                            CommonAlert.showAlertType1(vc: self, message: "수강생 정보가 수정되었습니다.") {
                               
                                self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                    }
                }
            }
            
        }else {
            self.reqInsertStd() {
                CommonAlert.showAlertType1(vc: self, message: "수강생이 등록되었습니다.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func imageUpload(img:Data!, completion:((String?)->Void?)?) {
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(img, withName: "file0", fileName: "file0.jpg", mimeType: "image/jpeg")
        }, to: IMG_UPLOAD)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                if let hadler = completion {
                    hadler(json["fileUrls"][0].string)
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
    
    // 성별 체크
    @IBAction func sexBtnPressed(_ sender: Any) {
        if let btn = sender as? UIButton {
            if btn == self.memMaleBtn {
                self.memMaleBtn.backgroundColor = COLOR_PURPLE
                self.memFemaleBtn.backgroundColor = .darkGray
                self.sex = "M"
            }else {
                self.memFemaleBtn.backgroundColor = COLOR_PURPLE
                self.memMaleBtn.backgroundColor = .darkGray
                self.sex = "F"
            }
        }
    }
    
    
    // 이미지 등록 버튼
    @IBAction func addImgBtnPressed(_ sender: Any) {
        showAlert()
    }
    
    // 등록하기
    @IBAction func addBtnPressed(_ sender: Any) {
        
        self.stdReqNetwork()
    }
    
    
    @IBAction func updateBtnPressed(_ sender: Any) {
        self.stdReqNetwork()
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        dismissKeyboard()
        CommonAlert.showAlertType2(vc: self, title: "수강생 정보를 삭제합니다.", cancelTitle: "취소", completeTitle: "확인") {
            
        } _: {
            self.deleteStdReq()
        }

    }
    
    // back버튼
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

// 데이터 요청
extension AddMembersVC {
    
    // 수강생 목록 조회
    func getStdListData() {
        
        var param = [String:String]()
        
        if let idx = self.stdIdx {
            param = [
                "std_member_idx" : uuidStr,
                "std_idx" : idx
            ]
        }
        
        CHTP.getStudentList(param: param, vc: self) { result in
            self.stdList = result["studentList"]
            
            if self.stdList.count > 0 {
                self.setDetailInfo()
            }
        } failure: { err, _ in
            CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                print(err)
            }
        }

    }
    
    //수강생 등록 요청
    func reqInsertStd(_ img:String? = nil, completion:(()->Void?)?) {
        
        var param = [
            "std_name" : self.memName.text ?? "",
            "std_birth" : self.formatter.string(from: self.memAge.date),
            "std_sex"   : self.sex,
            "std_phone_num" : self.memPnum.text ?? "",
            "std_start_date" : self.formatter.string(from: self.stdStartDate.date),
            "std_end_date"  : self.formatter.string(from: self.stdEndDate.date),
            "std_note"      : self.etcTxt,
            "std_member_idx" : uuidStr
            
        ]
        
        if let img = img {
            param.updateValue(img, forKey: "std_img")
        }
        
        CHTP.insertStudent(param: param, vc: self) { result in
            if let resultCode = result["resultCode"].int {
                if resultCode == 200 {
                   completion?()
                }
            }
        } failure: { err, _ in
            CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                print(err)
            }
        }

    }
    
    //수정생 수정 요청
    func reqUpdateStd(_ img:String? = nil, completion:(()->Void?)?) {
        
        guard let idx = self.stdIdx else {
            return
        }
        
        var param = [
            "std_idx"   : idx,
            "std_name" : self.memName.text ?? "",
            "std_birth" : self.formatter.string(from: self.memAge.date),
            "std_sex"   : self.sex,
            "std_phone_num" : self.memPnum.text ?? "",
            "std_start_date" : self.formatter.string(from: self.stdStartDate.date),
            "std_end_date"  : self.formatter.string(from: self.stdEndDate.date),
            "std_note"      : self.etcTxt,
            "std_member_idx" : uuidStr
        ]
        
        if let img = img {
            param.updateValue(img, forKey: "std_img")
        }
        
        CHTP.updateStudent(param: param, vc: self) { result in
            if let resultCode = result["resultCode"].int {
                if resultCode == 200 {
                   completion?()
                }else {
                    CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                        
                    }
                }
            }
        } failure: { err, _ in
            CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                print(err)
            }
        }

    }
}

extension AddMembersVC:UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.memAge.isUserInteractionEnabled = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.memAge.isUserInteractionEnabled = true
    }
}

extension AddMembersVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //이미지 선택시 처리 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(image)
            self.userImg.image = image
            let putImage = image.jpegData(compressionQuality: 0.1)
            self.selectImg = putImage
        }
        
        self.dismiss(animated: true) {}
        
    }
}

extension AddMembersVC:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
       
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension AddMembersVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.etcTxt = textView.text
    }
    
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(hex: "9A9A9A") {
            if self.etcTxt == "" {
                textView.text = nil
                textView.textColor = UIColor.black
                self.etcTxt = textView.text
            }
        }
        
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if self.etcTxt == "" {
                textView.text = "기타 참고사항을 입력해주세요."
                textView.textColor = UIColor(hex: "9A9A9A")
                self.etcTxt = ""
            }
        }
    }
    
    

}
