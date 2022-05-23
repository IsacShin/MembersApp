//
//  DateExt.swift
//  app
//
//  Created by 신이삭 on 2021/05/28.
//  Copyright © 2021 isac. All rights reserved.
//

import UIKit

extension Date {
    
    /// 요일 반환
    func getWeekDay() -> String {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let units: Set<Calendar.Component> = [.weekday]
        var comps = calendar.dateComponents(units, from: self)
        
        if let value = comps.weekday {
            switch value {
            case 1:
                return "일"
            case 2:
                return "월"
            case 3:
                return "화"
            case 4:
                return "수"
            case 5:
                return "목"
            case 6:
                return "금"
            case 7:
                return "토"
            default:
                return "일"
            }
        }
        return "일"
    }
    
    /// 스트링 변환 : 날짜 포멧
    func toString(format:String, am:String? = nil, pm:String? = nil)-> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        dateFormatter.dateFormat = format
        
        if let amSymbol = am {
            dateFormatter.amSymbol = amSymbol
        }
        if let pmSymbol = pm {
            dateFormatter.pmSymbol = pmSymbol
        }
            
        return dateFormatter.string(from: self)
    }
    
    func toDate(dateStr:String) -> Date? { //"yyyy.MM.dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: dateStr) {
            return date
        } else {
            return nil
        }
    }

    // 날짜 변환 : 날짜 포멧
    func toDateKoreaTime()-> Date {
        
        var today = Date()
        let format = "yyyyMMddHHmmss"
        let date = self.toString(format:format)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: -9 * 60 * 60)
        if let value = formatter.date(from:date) {
            today = value
        }
        
        return today
    }
    
    ////////////// Day 계산 //////////////
    // 이전 일
    func prevDay() -> Date {
        return nextDay(-1)
    }
    // 이전 일
    func prevDay(_ num:Int) -> Date {
        return nextDay(-num)
    }
    // 다음 일
    func nextDay() -> Date {
        return nextDay(1)
    }
    // 다음 일
    func nextDay(_ num:Int) -> Date {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let units: Set<Calendar.Component> = [.day, .month, .year]
        var comps = calendar.dateComponents(units, from: self)
        comps.day = comps.day!+num
        
        return calendar.date(from: comps)!
    }
    
    // 특정 '분' 추가
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

}
