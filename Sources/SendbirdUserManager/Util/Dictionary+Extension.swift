//
//  Dictionary+Extension.swift
//  
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

extension Dictionary {
    var data: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
}
