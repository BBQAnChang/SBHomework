//
//  APIErrorResponse.swift
//
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

public struct APIErrorResponse: Codable {
    let message: String
    let code: Int
    let error: Bool
}
