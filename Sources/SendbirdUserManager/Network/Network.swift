//
//  Network.swift
//
//
//  Created by 박종상 on 8/4/24.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingError
}

public final class Network: SBNetworkClient {
    private let session = URLSession.shared
    
    public func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        guard var urlComponents = URLComponents(string: "\(request.baseURL)\(request.path)") else {
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }

        let queryItems = request.parameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            completionHandler(.failure(NetworkError.invalidURL))
            return
        }

        var requset = URLRequest(url: url)
        requset.httpMethod = request.method.rawValue
        requset.timeoutInterval = request.timeoutInterval
        requset.setValue(request.body?.contentType, forHTTPHeaderField: NetworkBody.headerField)
        requset.httpBody = request.body?.data

        request.header.forEach { requset.addValue($1, forHTTPHeaderField: $0) }

        let task = session.dataTask(with: requset) { data, _, error in
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
