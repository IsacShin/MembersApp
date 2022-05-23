//
//  ScheduleVC.swift
//  app
//
//  Created by 신이삭 on 2021/05/31.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class ScheduleVC: BaseVC {

    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .none
            self.tableView.bounces = false
            self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        }
    }
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var currentDateLabel: UILabel!
    var parentVC:CalendarVC!
    var currentDateStr = ""
    var dateList:[[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentDateLabel.text = self.formatter.string(from: Date())
        
        self.emptyView.isHidden = true
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
    }
    
    deinit {
        self.tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let contentSize = self.tableView.contentSize.height
        print(contentSize)
    }
    
    
}

extension ScheduleVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.dateList.count > 0 {
            self.tableView.isHidden = false
            self.emptyView.isHidden = true
        }else {
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
        }
        
        return self.dateList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as? ScheduleCell  else {
            fatalError("The dequeued cell is not an instance of ScheduleCell")
        }
                
        let row = indexPath.row
        cell.selectionStyle = .none
        cell.timeTxt.text = ""
        cell.userScheduleTxt.text = ""
        
        if let timeTxt = self.dateList[row]["time"] {
            cell.timeTxt.text = timeTxt
        }
        
        if let scheduleTxt = self.dateList[row]["txt"] {
            cell.userScheduleTxt.text = scheduleTxt
        }
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            CommonAlert.showAlertType2(vc: self, title: "", message: "해당 일정을 삭제하시겠습니까?", cancelTitle: "취소", completeTitle: "확인") {
                
            } _: {
                if var scheduleDates = UDF.dictionary(forKey: "scheduleDates") as? [String : [[String:String]]]{
                    for (key,_) in scheduleDates {
                        if key == self.currentDateStr {
                            if let arr = scheduleDates[key] {
                                var sortDateList = arr.sorted(by: {self.timeFormatter.date(from: $0["starttime"]!)!.compare(self.timeFormatter.date(from: $1["starttime"]!)!) == .orderedAscending})
                                sortDateList.remove(at: indexPath.row)
                                scheduleDates[key] = sortDateList
                                scheduleDates.updateValue(sortDateList, forKey: key)
                                UDF.setValue(scheduleDates, forKey: "scheduleDates")
                                
                                self.dateList = sortDateList
                                tableView.reloadData()
                                self.parentVC.calendar.reloadData()
                                return
                            }
                        }
                        
                    }
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "삭제"
    }
    
}


class ScheduleCell:UITableViewCell {
    @IBOutlet weak var timeTxt: UILabel!
    @IBOutlet weak var userScheduleTxt: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        self.bgView.layer.borderWidth = 1
        self.bgView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.bgView.layer.cornerRadius = 12
    }
    
    
}
