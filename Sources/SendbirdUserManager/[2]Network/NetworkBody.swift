//
//  NetworkBody.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

public enum NetworkBody {
    case json(object: Codable)
    case url(parameters: [String: Any])

    public static let headerField: String = "Content-Type"

    var contentType: String {
        switch self {
        case .json: return "application/json"
        case .url: return "application/x-www-form-urlencoded"
        }
    }

    var data: Data? {
        switch self {
        case let .json(codable):
            return try? JSONEncoder().encode(codable)
        case let .url(parameters):
            return parameters.data
        }
    }
}
