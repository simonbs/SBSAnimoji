//
//  YouTubeClient.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 08/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import Foundation

enum YouTubeClientError: Error {
    case invalidURL
    case networkingError(Error)
    case jsonSerializationError(Error)
    case decodingError(DecodingError)
    case unknownError
}

class YouTubeClient {
    private let baseURL = URL(string: "https://www.googleapis.com/youtube/v3")!
    private let key: String
    
    init(key: String) {
        self.key = key
    }
    
    func search(query: String, completion: @escaping (Result<YouTubeSearchResultsContainer, YouTubeClientError>) -> Void) -> URLSessionTask? {
        let params = [
            "key": key,
            "part": "snippet",
            "type": "video",
            "maxResults": "50",
            "q": query
        ]
        return getRequest(path: "search", parameters: params, completion: completion)
    }    
}

private extension YouTubeClient {
    private func getRequest<T: Codable>(path: String, parameters: [String: String], completion: @escaping (Result<T, YouTubeClientError>) -> Void) -> URLSessionTask? {
        let baseURLWithPath = baseURL.appendingPathComponent(path)
        var comps = URLComponents(url: baseURLWithPath, resolvingAgainstBaseURL: true)
        comps?.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        guard let url = comps?.url else { return nil }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let value = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.value(value))
                    }
                } catch let error as DecodingError {
                    DispatchQueue.main.async {
                        completion(.error(YouTubeClientError.decodingError(error)))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.error(YouTubeClientError.jsonSerializationError(error)))
                    }
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    completion(.error(YouTubeClientError.networkingError(error)))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.error(YouTubeClientError.unknownError))
                }
            }
        }
        task.resume()
        return task
    }
}
