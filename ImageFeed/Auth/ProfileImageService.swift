//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Moxa on 23/03/26.
//

import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
}

enum ProfileImageServiceError: Error {
    case invalidRequest
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            self?.task = nil
            
            switch result {
            case .success(let userResult):
                guard let avatarURL = userResult.profileImage?.small else {
                    print("[ProfileImageService]: 'small' URL not found in response")
                    completion(.failure(NetworkError.decodingError(NSError(domain: "MissingImageURL", code: 0, userInfo: nil))))
                    return
                }
                
                self?.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
            case .failure(let error):
                print("[ProfileImageService]: Network Error - \(error)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func clearAvatar() {
        avatarURL = nil
    }
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let url = URL(string: Constants.defaultBaseURLString + "/users/\(username)"),
            let token = OAuth2TokenStorage.shared.token
        else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
