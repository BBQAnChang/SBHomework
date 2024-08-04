//
//  Network.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

public enum NetworkError: Error {
    case noAppId
    case noApiToken
    case invalidURL
    case requestFailed
    case decodingError
}

public final class Network: SBNetworkClient {
    public var appId: String?
    public var apiToken: String?

    private let session = URLSession.shared

    private var baseURL: String {
        guard let appId else { return "" }
        return "https://api-\(appId).sendbird.com/v3/"
    }

    // https://sendbird.com/docs/chat/platform-api/v3/prepare-to-use-api#2-authentication 참조
    private var deafaultHeader: [String: String] {
        guard let apiToken else { return [:] }
        return ["Api-Token": apiToken]
    }

    public func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        guard appId != nil else {
            completionHandler(.failure(NetworkError.noAppId))
            return
        }

        guard apiToken != nil else {
            completionHandler(.failure(NetworkError.noApiToken))
            return
        }

        guard var urlComponents = URLComponents(string: "\(baseURL)\(request.path)") else {
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }

        let queryItems = request.parameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeoutInterval
        urlRequest.setValue(request.body?.contentType, forHTTPHeaderField: NetworkBody.headerField)
        urlRequest.httpBody = request.body?.data

        deafaultHeader.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }
        request.header.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }

        let task = session.dataTask(with: urlRequest) { data, _, error in
            if let error {
                completionHandler(.failure(error))
                return
            }

            guard let data = data else {
                completionHandler(.failure(NetworkError.requestFailed))
                return
            }

            do {
                let response = try JSONDecoder().decode(R.Response.self, from: data)
                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
    }
}
