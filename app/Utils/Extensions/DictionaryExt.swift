//
//  DictionaryExt.swift
//  app
//
//  Created by 신이삭 on 2021/08/05.
//  Copyright © 2021 isac. All rights reserved.
//
import Foundation

extension Dictionary where Key: Equatable {
    func findValue(from key: Key) -> Value? {
        return self.first(where: { $0.key == key })?.value
    }
    
    func findKey(from key: Key) -> Key? {
        return self.first(where: { $0.key == key })?.key
    }
}
