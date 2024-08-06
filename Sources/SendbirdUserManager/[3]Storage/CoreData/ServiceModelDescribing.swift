//
//  ServiceModelDescribing.swift
//  
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

// 빈 프로토콜이지만 타입 체킹을 위해 만들어 놓음. 필요시 필드를 채워 넣을 수 있음
protocol ServiceModelDescribing {
    var id: String { get }
}
