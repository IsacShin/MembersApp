//
//  MemberCell.swift
//  app
//
//  Created by 신이삭 on 2021/06/23.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation
import UIKit

class MemberCell:UICollectionViewCell {
    
    @IBOutlet weak var stdImg: UIImageView!
    @IBOutlet weak var stdName: UILabel!
    @IBOutlet weak var stdPnum: UILabel!
    @IBOutlet weak var stdTerm: UILabel!
    var stdIdx:Int?
    override func awakeFromNib() {
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(hex: "#dcdcdc").cgColor
    }
}
