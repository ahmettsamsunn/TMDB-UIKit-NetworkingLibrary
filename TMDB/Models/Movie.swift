import Foundation

struct Movie: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double?
    let releaseDate: String?
    let backdropPath: String?
    let originalLanguage: String?
    let voteCount: Int?
    var posterURL: URL? {
        return URL.tmdbImage(path: posterPath, size: .w500)
    }
    
    var backdropURL: URL? {
        return URL.tmdbImage(path: backdropPath, size: .original)
    }
    
    var formattedRating: String {
        if let rating = voteAverage {
            return String(format: "%.1f", rating)
        }
        return "N/A"
    }
    
    var formattedReleaseDate: String {
        return Date.formatMovieDate(releaseDate)
    }
    
}

struct MovieResponse: Codable {
    let page: Int?
    let results: [Movie]
    let totalPages: Int?
    let totalResults: Int?
    let dates: MovieResponseDates?
}

struct MovieResponseDates: Codable {
    let maximum: String
    let minimum: String
}
