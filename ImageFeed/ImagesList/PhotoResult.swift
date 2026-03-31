import Foundation

struct UrlsResult: Codable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct LikeResult: Codable {
    let photo: PhotoResult
}
