//
//  API.swift
//  
//
//  Created by 박종상 on 8/6/24.
//

import Foundation

public protocol Request {
    associatedtype Response: Decodable

    var timeoutInterval: TimeInterval { get }
    var method: NetworkMethod { get }
    var body: NetworkBody? { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    var header: [String: String] { get }

    func parse(_ data: Data) throws -> Response
    func error(_ data: Data) throws -> APIErrorResponse
}

public extension Request {
    var timeoutInterval: TimeInterval { 10.0 }
    var body: NetworkBody? { nil }
    var parameters: [String: Any] { [:] }
    var header: [String: String] { [:] }

    func error(_ data: Data) throws -> APIErrorResponse {
        return try JSONDecoder().decode(APIErrorResponse.self, from: data)
    }
}

enum API { }
