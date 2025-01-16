import Foundation
import OSLog

class MoviesViewModel {
    var nowPlayingMovies: [Movie] = []
    var popularMovies: [Movie] = []
    var searchResults: [Movie] = []
    var isLoading = false
    var error: Error?
    private(set) var selectedMovie: Movie?
    private(set) var isLoadingDetails = false
    private(set) var detailsError: Error?
    
    // Pagination state
    private var nowPlayingPage = 1
    private var popularPage = 1
    private var hasMoreNowPlaying = true
    private var hasMorePopular = true
    private var isLoadingMore = false
    
    private let movieService = MovieService()
    private let logger = Logger(subsystem: "com.tmdb.app", category: "MoviesViewModel")
    
    func fetchNowPlaying(loadMore: Bool = false, completion: @escaping () -> Void) {
        guard !isLoading, !isLoadingMore, (loadMore ? hasMoreNowPlaying : true) else {
            completion()
            return
        }
        
        if loadMore {
            isLoadingMore = true
        } else {
            isLoading = true
            nowPlayingPage = 1
        }
        
        Task {
            do {
                let response = try await movieService.fetchNowPlaying(page: nowPlayingPage)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if loadMore {
                        self.nowPlayingMovies.append(contentsOf: response.results)
                    } else {
                        self.nowPlayingMovies = response.results
                    }
                    
                    if let totalPages = response.totalPages {
                        self.hasMoreNowPlaying = self.nowPlayingPage < totalPages
                        if self.hasMoreNowPlaying {
                            self.nowPlayingPage += 1
                        }
                    }
                    self.error = nil
                    self.isLoading = false
                    self.isLoadingMore = false
                    completion()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.error = error
                    self.logger.error("Failed to fetch now playing movies: \(error.localizedDescription)")
                    self.isLoading = false
                    self.isLoadingMore = false
                    completion()
                }
            }
        }
    }
    
    func fetchPopular(loadMore: Bool = false, completion: @escaping () -> Void) {
        guard !isLoading, !isLoadingMore, (loadMore ? hasMorePopular : true) else {
            completion()
            return
        }
        
        if loadMore {
            isLoadingMore = true
        } else {
            isLoading = true
            popularPage = 1
        }
        
        Task {
            do {
                let response = try await movieService.fetchPopular(page: popularPage)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if loadMore {
                        self.popularMovies.append(contentsOf: response.results)
                        print("Added \(response.results.count) more popular movies. Total: \(self.popularMovies.count)")
                    } else {
                        self.popularMovies = response.results
                        print("Set \(response.results.count) popular movies")
                    }
                    
                    if let totalPages = response.totalPages {
                        self.hasMorePopular = self.popularPage < totalPages
                        if self.hasMorePopular {
                            self.popularPage += 1
                        }
                    }
                    self.error = nil
                    self.isLoading = false
                    self.isLoadingMore = false
                    completion()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    print("Error fetching popular movies: \(error.localizedDescription)")
                    self.error = error
                    self.isLoading = false
                    self.isLoadingMore = false
                    completion()
                }
            }
        }
    }
    
    func searchMovies(query: String, completion: @escaping () -> Void) {
        guard !query.isEmpty else {
            searchResults = []
            completion()
            return
        }
        
        Task {
            do {
                let response = try await movieService.searchMovies(query: query)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.searchResults = response.results
                    self.error = nil
                    completion()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.error = error
                    self.logger.error("Failed to search movies: \(error.localizedDescription)")
                    completion()
                }
            }
        }
    }
    
    func fetchMovieDetails(id: Int, completion: @escaping () -> Void) {
        Task {
            isLoadingDetails = true
            detailsError = nil
            do {
                selectedMovie = try await movieService.fetchMovieDetails(id: id)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isLoadingDetails = false
                    completion()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.detailsError = error
                    self.logger.error("Failed to fetch movie details: \(error.localizedDescription)")
                    self.isLoadingDetails = false
                    completion()
                }
            }
        }
    }
}
