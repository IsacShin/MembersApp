//
//  StringExt.swift
//  app
//
//  Created by 신이삭 on 2021/03/02.
//  Copyright © 2021 isac. All rights reserved.
//

import Foundation

extension String {
    func trimSpaceLine() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
