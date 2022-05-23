//
//  MembersVC.swift
//  app
//
//  Created by 신이삭 on 2021/06/13.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher
import ViewAnimator

class MembersVC: BaseVC {

    @IBOutlet weak var backRoundView: UIView!
    @IBOutlet weak var scrollTopBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emptyView: UIView!
    
    var stdList:JSON = JSON()
    
    let fromAnimation = [AnimationType.vector((CGVector(dx: 0, dy: 30)))]
    let zoomAnimation = [AnimationType.zoom(scale: 0.2)]
    let rotateAnimation = [AnimationType.rotate(angle: CGFloat.pi/6)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyView.isHidden = false
        self.scrollTopBtn.isHidden = true
        
        //set roundView
        backRoundView.clipsToBounds = true
        backRoundView.layer.cornerRadius = 0
        backRoundView.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMaxYCorner, .layerMaxXMaxYCorner)

        self.backRoundView.backgroundColor = COLOR_PURPLE
        self.backViewHeight.constant = SCREEN_HEIGHT / 2.5
        setCollectionView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getStdListData()
    }
    
    func getStdListData() {
        let param = [
            "std_member_idx" : uuidStr
        ]
        CHTP.getStudentList(param: param, vc: self) { result in
            self.stdList = result["studentList"]
            
            if self.stdList.count > 0 {
                if self.memberVcInitAnim == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
                        self.collectionView?.reloadData()
                        self.collectionView?.performBatchUpdates({
                            UIView.animate(views: self.collectionView!.orderedVisibleCells,
                                           animations: self.zoomAnimation, completion: {
                                            self.memberVcInitAnim = true
                                           })
                        }, completion: nil)
                    }
                }else {
                    self.collectionView.reloadData()
                }
            }else {
                self.collectionView.reloadData()
            }
        } failure: { err, _ in
            CommonAlert.showAlertType1(vc: self, message: "다시 시도해주세요", completeTitle: "확인") {
                print(err)
            }
        }

    }
    
    func setCollectionView() {
        let columnCount: CGFloat = 2    // 한 줄당 노출하고 싶은 아이템 Column
        let margin: CGFloat      = 20*2 // 좌우 여백
        let space: CGFloat       = 20    // 아이템 사이 간격
        let itemSize: CGFloat    = (self.view.frame.width - margin - (space * (columnCount-1))) / columnCount
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize                = CGSize(width: itemSize, height: 305)
        layout.scrollDirection         = .vertical
        layout.minimumLineSpacing      = space
        layout.minimumInteritemSpacing = space
        layout.sectionInset            = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.sectionHeadersPinToVisibleBounds = true
            
        self.collectionView.bounces = false
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 90, right: 20)
        self.collectionView.collectionViewLayout = layout
        self.collectionView.register(UINib(nibName: "MemberCell", bundle: nil), forCellWithReuseIdentifier: "MemberCell")
   
    }
    
    @IBAction func scrollTopBtnPressed(_ sender: Any) {
        self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredVertically, animated: true)
        self.scrollTopBtn.isHidden = true
    }
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
        CommonNav.moveAddMembersVC()
    }
}


extension MembersVC:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if stdList.count > 0 {
            self.emptyView.isHidden = true
            self.scrollTopBtn.isHidden = false
        }else {
            self.emptyView.isHidden = false
            self.scrollTopBtn.isHidden = true
        }
        
        return stdList.count
    }
    
    /// 섹션 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// 섹션 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: 60)
    }
    
    /// 섹션 :
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var header: SectionHeaderView?
        
        if kind == UICollectionView.elementKindSectionHeader {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? SectionHeaderView
            header?.backgroundColor = .clear
            header?.handler = {
                CommonNav.moveAddMembersVC()
            }
            header?.title.text = "수강회원 목록"
        }
        
        return header!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as? MemberCell else {
            fatalError("The dequeued cell is not an instance of MemberCell")
        }
        
        let columnCount: CGFloat = 2    // 한 줄당 노출하고 싶은 아이템 Column
        let margin: CGFloat      = 20*2 // 좌우 여백
        let space: CGFloat       = 20    // 아이템 사이 간격
        let itemSize: CGFloat    = (self.view.frame.width - margin - (space * (columnCount-1))) / columnCount
        
        cell.stdImg.image = nil
        
        if let imgUrlStr = stdList[indexPath.row]["student_img"].string {
            if let url = URL(string: imgUrlStr) {
                cell.stdImg.kf.setImage(with: url, placeholder: .none, options: .none, completionHandler:  { result in
                    switch result {
                    case .success(let value):
                        cell.stdImg.image = self.resizeTopAlignedToFill(originImg: value.image, newWidth: itemSize)
                        cell.layoutIfNeeded()
                    case .failure(let err):
                        print("Error: \(err)")
                    }
                })
            }
        }
        
        if let idx = stdList[indexPath.row]["student_idx"].int {
            cell.stdIdx = idx
        }
        
        cell.stdName.text = stdList[indexPath.row]["student_name"].string ?? ""
        cell.stdPnum.text = "HP\n\(stdList[indexPath.row]["student_phone_num"].string ?? "")"
        cell.stdTerm.text = "수강기간\n\(stdList[indexPath.row]["student_start_date"].string ?? " ")\n ~ \(stdList[indexPath.row]["student_end_date"].string ?? " ")"
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MemberCell else {
            fatalError("The dequeued cell is not an instance of MemberCell")
        }
        
        if let idx = cell.stdIdx {
            CommonNav.moveAddMembersVC(.detail, "\(idx)")
        }
    }
}

class SectionHeaderView: UICollectionReusableView {
        
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    var handler:(() -> Void?)?
    
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
        if let handler = handler {
            handler()
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension MembersVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let vc = self.parent as? MainVC else {
            return
        }
        if(velocity.y > 0) {
            self.scrollTopBtn.isHidden = false
            //vc.animHideFooter()
        }else{
            self.scrollTopBtn.isHidden = true
            //vc.animShowFooter()
        }
    }
}
