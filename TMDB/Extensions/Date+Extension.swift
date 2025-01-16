import Foundation

extension Date {
    static let movieDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    static func formatMovieDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = movieDateFormatter.date(from: dateString) else {
            return "Release date unavailable"
        }
        return displayDateFormatter.string(from: date)
    }
}
