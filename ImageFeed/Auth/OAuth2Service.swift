//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Moxa on 17/03/26.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(responseBody.accessToken))
                } catch {
                    print("[OAuth2Service]: Error decoding OAuthTokenResponseBody - \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[OAuth2Service]: Network Error - \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}


