//
//  StatusVC.swift
//  app
//
//  Created by 신이삭 on 2021/06/13.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

class AlarmVC: BaseVC {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .none
            self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        }
    }
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyView.isHidden = false
        
        
        // 15일 이후 자동 삭제
        if var list = UDF.object(forKey: "pushList") as? [[String : Any]] {
            print(list)
            for (index,item) in list.enumerated() {
                if let date = item["date"] as? String {
                    print(date)
                    if self.compareDays(startDate: date, endDate: Date().toString(format: "YYYY-MM-dd")) > 15 {
                        let newList = list.remove(at: index)
                        print(newList)
                        
                        UDF.setValue(newList, forKey: "pushList")
                    }
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tableView = self.tableView {
            tableView.reloadData()
        }
    }
}

extension AlarmVC:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = UDF.object(forKey: "pushList") as? [[String : Any]] {
            if list.count > 0 {
                self.tableView.isHidden = false
                self.emptyView.isHidden = true
            }else {
                self.tableView.isHidden = true
                self.emptyView.isHidden = false
            }
            
            return list.count
        }else {
            self.tableView.isHidden = true
            self.emptyView.isHidden = false
            
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell  else {
            fatalError("The dequeued cell is not an instance of MessageCell")
        }
                
        let row = indexPath.row
        cell.selectionStyle = .none
        
        if let list = UDF.object(forKey: "pushList") as? [[String : Any]] {
            if let date = list[row]["date"] as? String {
                cell.dateStr.text = date
            }
            
            if let comment = list[row]["comment"] as? String {
                cell.commentStr.text = comment
            }
        }
        
        return cell
    }
    
}


class MessageCell:UITableViewCell {
    @IBOutlet weak var dateStr: UILabel!
    @IBOutlet weak var commentStr: UILabel!
    
}
