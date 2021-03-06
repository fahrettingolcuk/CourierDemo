//
//  Request.swift
//  courierdemo
//
//  Created by Fahreddin Gölcük on 26.11.2021.
//

import Foundation

public func Request<T: Decodable>(with url: String, httpMethod: HTTPMethod = .get, body: [String: Any] = [:], urlParameter: String = "", completion: @escaping (Result<T, NetworkError>) -> Void) {
    guard let url = URL(string: httpMethod == .get ? url + urlParameter : url) else {
        completion(.failure(.urlError))
        return
    }
    let request = NSMutableURLRequest(url: url)
    if ( httpMethod == .post ) {
        do {
               request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        } catch let error {
               print(error.localizedDescription)
        }
    }
    request.httpMethod = httpMethod.rawValue
    URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
        if let error = error {
            completion(.failure(NetworkError.networkError(error)))
        }
        guard let data = data else {
            completion(.failure(.dataNotFound))
            return
        }

        do {
            let result = try JSONDecoder().decode(T.self, from: data)
            completion(.success(result))
        } catch {
            completion(.failure(.networkError(error)))
        }
        
    }.resume()
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case head = "HEAD"
    case patch = "PATCH"
}
