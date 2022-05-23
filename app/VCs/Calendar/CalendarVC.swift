//
//  CalendarVC.swift
//  app
//
//  Created by 신이삭 on 2021/05/27.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit
import FloatingPanel
import FSCalendar

class CalendarVC: BaseVC, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: UILabel!
    
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }()
    
    private var currentPage: Date?
    private lazy var today: Date = { return Date() }()
    
    var events:[Date]?
    var scheduleDates:[String:[[String:String]]] = [:]
    var fpc = FloatingPanelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEvents()
        setCalendar()
        createPanel()
    }
    
    private func scrollCurrentPage(isPrev: Bool) {
        let cal = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isPrev ? -1 : 1
        self.currentPage = cal.date(byAdding: dateComponents, to: calendar.currentPage)
        
        self.calendar.setCurrentPage(self.currentPage!, animated: true)
        
    }


    func setCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        
        self.calendarHeight.constant = UIScreen.main.bounds.height/2 - SAFEAREA_TOP

        self.headerLabel.text = self.monthFormatter.string(from: calendar.currentPage)
                
        // 캘린더 글자색 변경
        calendar.appearance.selectionColor = .systemBlue
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .orange
        calendar.appearance.subtitleTodayColor = .orange
        calendar.appearance.eventDefaultColor = .systemBlue
        calendar.appearance.todaySelectionColor = .systemBlue
        // 캘린더 헤더 변경
        calendar.headerHeight = 60
        calendar.calendarHeaderView.isHidden = true

        // 캘린더 언어 변경
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        // 요일색상 지정
        for item in calendar.calendarWeekdayView.weekdayLabels {
            if item.text == "일" {
                item.textColor = .red
            }else if item.text == "토" {
                item.textColor = .blue
            }else {
                item.textColor = .black
            }
        }
        
    }
    
    func createPanel() {
        
        // Create a new appearance.
        let appearance = SurfaceAppearance()

        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        //appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 12.0
        appearance.backgroundColor = .clear

        // Set the new appearance
        fpc.surfaceView.appearance = appearance
        
        
        fpc.delegate = self
        fpc.layout = MyFloatingPanelLayout()
        
        // 핸들바 커스텀
        let _ = CustomGrabberHandleView.initView(fpc.surfaceView) {
            if self.fpc.state == .full {
                self.fpc.move(to: .half, animated: true)
            }else {
                self.fpc.move(to: .full, animated: true)
            }
        }
        fpc.surfaceView.grabberHandle.isHidden = true
        
        guard let vc = Utils.getVC(storyBoard: "Calendar", controller: "ScheduleVC") as? ScheduleVC else {
            return
        }
        
        vc.parentVC = self
        fpc.backdropView.isHidden = true
        fpc.set(contentViewController: vc)
        fpc.addPanel(toParent: self)
        
        setLoadDate(date: Date())
        
    }
    
    func setUpEvents() {
        
        let xmas = formatter.date(from: "2021.06.25")
        events = [xmas!]
    }
    
    func setLoadDate(date:Date) {
        let dateStr = formatter.string(from: date)
        if let vc = self.fpc.contentViewController as? ScheduleVC {
            vc.currentDateLabel.text = dateStr
            vc.currentDateStr = dateStr
            if let scheduleDates = UDF.dictionary(forKey: "scheduleDates") as? [String : [[String:String]]]{
                for (key,value) in scheduleDates {
                    if key == dateStr {
                        let sortDateList = value.sorted(by: {self.timeFormatter.date(from: $0["starttime"]!)!.compare(self.timeFormatter.date(from: $1["starttime"]!)!) == .orderedAscending})
                        vc.dateList = sortDateList
                        vc.tableView.reloadData()
                        return
                    }
                }
            }
            
            vc.dateList = []
            vc.tableView.reloadData()
        }
    }
    
}

extension CalendarVC {
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        CommonNav.moveEditDateVC(parentVC: self)
    }

    @IBAction func nextBtnPressed(_ sender: Any) {
        scrollCurrentPage(isPrev: false)

    }
    
    @IBAction func prevBtnPressed(_ sender: Any) {
        scrollCurrentPage(isPrev: true)

    }
}


// FloatingPanel Delegate
extension CalendarVC:FloatingPanelControllerDelegate, FloatingPanelBehavior {
    // 이동범위 제한
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        if vc.isAttracting == false {
            let loc = vc.surfaceLocation
            let minY = vc.surfaceLocation(for: .tip).y
            let maxY = SAFEAREA_TOP
            vc.surfaceLocation = CGPoint(x: loc.x, y: min(max(loc.y, maxY), minY))
        }
    }
    
    //고무밴드 효과
    func allowsRubberBanding(for edge: UIRectEdge) -> Bool {
        return false
    }

}

class MyFloatingPanelLayout: FloatingPanelLayout {
    let fullInset: CGFloat = SAFEAREA_TOP
    var halfInset: CGFloat = UIDevice.current.hasNotch ? UIScreen.main.bounds.height/2 - 27 : UIScreen.main.bounds.height/2
    var tipInset: CGFloat = UIDevice.current.hasNotch ? UIScreen.main.bounds.height/2 - 27 : UIScreen.main.bounds.height/2

    var initialState: FloatingPanelState {
        return .half
    }
    var position: FloatingPanelPosition {
        return .bottom
    }
    var referenceGuide: FloatingPanelLayoutReferenceGuide {
        return .superview
    }
    var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: fullInset, edge: .top, referenceGuide: referenceGuide),
            .half: FloatingPanelLayoutAnchor(absoluteInset: halfInset, edge: .bottom, referenceGuide: referenceGuide),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: halfInset, edge: .bottom, referenceGuide: referenceGuide),
        ]
    }
}


// FSCalendar Delegate
extension CalendarVC:FSCalendarDelegate,FSCalendarDataSource {
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        self.headerLabel.text = self.monthFormatter.string(from: calendar.currentPage)
        
    }
    
    // 달력 이벤트 요일 표시
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateStr = self.formatter.string(from: date)
        if let scheduleDates = UDF.dictionary(forKey: "scheduleDates") as? [String : [[String:String]]]{
            if scheduleDates.keys.contains(dateStr) {
                if let arr = scheduleDates[dateStr] {
                    if arr.count > 0 {
                        return 1
                    }else {
                        return 0
                    }
                }else {
                    return 0
                }
            }else {
                return 0
            }
        }else {
            return 0
        }
    }
    
    // 날짜 선택시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        setLoadDate(date: date)
    }
    
    // 날짜 밑 글자 새김
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        switch formatter.string(from: date) {
        case formatter.string(from: Date()):
            return "오늘"
        default:
            return nil
        }
    }
    
}
