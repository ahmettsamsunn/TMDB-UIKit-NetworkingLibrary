//
//  URL+Extension.swift
//  TMDB
//
//  Created by Ahmet Samsun on 16.01.2025.
//

import Foundation

extension URL {
    enum TMDBImageSize: String {
        case w200 = "w200"
        case w500 = "w500"
        case original = "original"
    }
    
    static func tmdbImage(path: String?, size: TMDBImageSize = .w500) -> URL? {
        guard let path = path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)\(path)")
    }
}
