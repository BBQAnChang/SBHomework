//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation

public protocol Request {
    associatedtype Response: Decodable

    var timeoutInterval: TimeInterval { get }
    var baseURL: String { get }
    var method: NetworkMethod { get }
    var body: NetworkBody? { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    var header: [String: String] { get }

    func parse(_ response: Any) -> Response
}

public protocol SBNetworkClient {
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}
