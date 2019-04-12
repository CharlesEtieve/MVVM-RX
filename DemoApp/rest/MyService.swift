//
//  MyService.swift
//  v-labs
//
//  Created by Charles Etieve on 01/03/2019.
//  Copyright © 2019 Charles Etieve. All rights reserved.
//

import Foundation
import Moya

enum MyService {
    case readUsers
    case readPostForUser(userId: String)
    case readAlbumForUser(userId: String)
    case readPhotoForAlbum(albumId: String)
    case readCommentForPost(postId: String)
}

extension MyService: TargetType {
    var baseURL: URL { return URL(string: "https://jsonplaceholder.typicode.com")! }
    var path: String {
        switch self {
        case .readUsers:
            return "/users"
        case .readPostForUser:
            return "/posts"
        case .readAlbumForUser:
            return "/albums"
        case .readPhotoForAlbum:
            return "/photos"
        case .readCommentForPost:
            return "/comments"
        }
    }
    var method: Moya.Method {
        switch self {
        case .readUsers:
            return .get
        case .readPostForUser:
            return .get
        case .readAlbumForUser:
            return .get
        case .readPhotoForAlbum:
            return .get
        case .readCommentForPost:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .readUsers:
            return .requestPlain
        case .readPostForUser(let userId):
            return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.queryString)
        case .readAlbumForUser(let userId):
            return .requestParameters(parameters: ["userId": userId], encoding: URLEncoding.queryString)
        case .readPhotoForAlbum(let albumId) :
            return .requestParameters(parameters: ["albumId": albumId], encoding: URLEncoding.queryString)
        case .readCommentForPost(let postId) :
            return .requestParameters(parameters: ["postId": postId], encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        switch self {
        case .readUsers:
            guard let url = Bundle.main.url(forResource: "users", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .readPostForUser:
            guard let url = Bundle.main.url(forResource: "postsUser1", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .readAlbumForUser:
            guard let url = Bundle.main.url(forResource: "albumsUser1", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .readPhotoForAlbum:
            guard let url = Bundle.main.url(forResource: "photosAlbum1", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        case .readCommentForPost:
            guard let url = Bundle.main.url(forResource: "commentsPost1", withExtension: "json"),
                let data = try? Data(contentsOf: url) else {
                    return Data()
            }
            return data
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
