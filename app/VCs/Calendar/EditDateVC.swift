//
//  EditVC.swift
//  app
//
//  Created by 신이삭 on 2021/07/05.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class EditDateVC: BaseVC {

    @IBOutlet weak var etcWrapView: UIView!
    @IBOutlet weak var scheduleTxt: UITextView!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var startTime: UIDatePicker!
    @IBOutlet weak var endTime: UIDatePicker!
    @IBOutlet weak var addBtn: UIButton!
    
    var parentVC:UIViewController?
    var scheduletxt:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboard()
        
        self.view.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        // 참고사항 텍스트뷰 레이아웃 set
        self.etcWrapView.layer.borderWidth = 1
        self.etcWrapView.layer.borderColor = COLOR_MINT.cgColor
        self.etcWrapView.layer.cornerRadius = 12
        
        self.scheduleTxt.text = "일정을 입력해주세요."
        self.scheduleTxt.textColor = UIColor(hex: "9A9A9A")
        
        self.scheduleTxt.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showAnim()
    }
    
    
    func showAnim() {
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
            self.view.alpha = 1
        }
    }
    
    func hideAnim() {
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 0
        } completion: { finished in
            self.dismiss(animated: false) {

            }
        }

    }

    @IBAction func closeBtnPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.35) {
            self.dismissKeyboard()
        } completion: { finished in
            self.hideAnim()
        }

    }
    @IBAction func addBtnPressed(_ sender: Any) {
        self.dismissKeyboard()
        if scheduletxt != "" {
            
            if self.intervalTime(end: endTime.date, start: startTime.date) < 0 {
                CommonAlert.showAlertType1(vc: self, title: "", message: "종료시간은 시작시간 이후로 설정가능합니다.", completeTitle: "확인", nil)
                
                return
            }
            
            if let parentVC = self.parentVC as? CalendarVC {
                let addDate = self.formatter.string(from: self.startDate.date)
                let addDateTime = "\(self.timeFormatter.string(from: self.startTime.date)) ~ \(self.timeFormatter.string(from: self.endTime.date))"
                
                if var scheduleDates = UDF.dictionary(forKey: "scheduleDates") as? [String : [[String:String]]]{
                    if var dateArr = scheduleDates.findValue(from: addDate) {
                        let addDic = [
                            "starttime" : self.timeFormatter.string(from: self.startTime.date),
                            "time" : addDateTime,
                            "txt"  : self.scheduletxt
                        ]
                        
                        dateArr.append(addDic)
                        scheduleDates.updateValue(dateArr, forKey: addDate)
                        UDF.setValue(scheduleDates, forKey: "scheduleDates")
                    }else {
                        let addDic = [
                            "starttime" : self.timeFormatter.string(from: self.startTime.date),
                            "time" : addDateTime,
                            "txt"  : self.scheduletxt
                        ]
                        scheduleDates.updateValue([addDic], forKey: addDate)
                        UDF.setValue(scheduleDates, forKey: "scheduleDates")
                    }
                }else {
                    if var dateArr = parentVC.scheduleDates.findValue(from: addDate) {
                        let addDic = [
                            "starttime" : self.timeFormatter.string(from: self.startTime.date),
                            "time" : addDateTime,
                            "txt"  : self.scheduletxt
                        ]
                        
                        dateArr.append(addDic)
                        parentVC.scheduleDates.updateValue(dateArr, forKey: addDate)
                        UDF.setValue(parentVC.scheduleDates, forKey: "scheduleDates")
                    }else {
                        let addDic = [
                            "starttime" : self.timeFormatter.string(from: self.startTime.date),
                            "time" : addDateTime,
                            "txt"  : self.scheduletxt
                        ]
                        parentVC.scheduleDates.updateValue([addDic], forKey: addDate)
                        UDF.setValue(parentVC.scheduleDates, forKey: "scheduleDates")
                    }
                }
     
                CommonAlert.showAlertType1(vc: self, title: "", message: "일정이 등록되었습니다.", completeTitle: "확인") {
                    parentVC.calendar.reloadData()
                    if let fpc = parentVC.fpc.contentViewController as? ScheduleVC {
                        let dateStr = self.formatter.string(from: self.startDate.date)
                        if let vc = fpc as? ScheduleVC {
                            vc.currentDateStr = dateStr
                            if let scheduleDates = UDF.dictionary(forKey: "scheduleDates") as? [String : [[String:String]]]{
                                for (key,value) in scheduleDates {
                                    if key == dateStr {
                                        let sortDateList = value.sorted(by: {self.timeFormatter.date(from: $0["starttime"]!)!.compare(self.timeFormatter.date(from: $1["starttime"]!)!) == .orderedAscending})
                                        vc.dateList = sortDateList
                                        vc.tableView.reloadData()
                                        self.hideAnim()
                                        return
                                    }
                                }
                                fpc.tableView.reloadData()
                            }
                            
                        }
                        
                    }
                    
                    self.hideAnim()
                }
                
            }
        }else {
            CommonAlert.showAlertType1(vc: self, title: "", message: "일정을 입력해주세요.", completeTitle: "확인", nil)
        }
        
    }
}

extension EditDateVC:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.scheduletxt = textView.text
    }
    
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor(hex: "9A9A9A") {
            if self.scheduletxt == "" {
                textView.text = nil
                textView.textColor = UIColor.black
                self.scheduletxt = textView.text
            }
        }
        
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if self.scheduletxt == "" {
                textView.text = "일정을 입력해주세요."
                textView.textColor = UIColor(hex: "9A9A9A")
                self.scheduletxt = ""
            }
        }
    }
    
    

}
