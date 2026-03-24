//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Moxa on 22/03/26.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
                
                switch result {
                case .success(let profileResult):
                    guard let self = self else { return }
                    let profile = self.convert(profileResult)
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService]: Network Error - \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func convert(_ profileResult: ProfileResult) -> Profile {
        let firstName = profileResult.firstName ?? ""
        let lastName = profileResult.lastName ?? ""
        let name = [firstName, lastName].filter { !$0.isEmpty }.joined(separator: " ")
        let loginName = "@\(profileResult.username)"
        let bio = profileResult.bio ?? ""
        
        return Profile(
            username: profileResult.username,
            name: name,
            loginName: loginName,
            bio: bio
        )
    }
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURLString + "/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
