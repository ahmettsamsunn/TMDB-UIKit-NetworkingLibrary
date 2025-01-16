import Foundation
import NetworkingLibrary
import OSLog

actor MovieService {
    private let networking: Networking
    private let logger = Logger(subsystem: "com.tmdb.app", category: "MovieService")
    
    init() {
        self.networking = Networking(
            requestAdapters: [TMDBAuthAdapter()],
            responseParser: ResponseParser()
        )
    }
    
    func fetchNowPlaying(page: Int = 1) async throws -> MovieResponse {
        logger.debug("Fetching now playing movies for page: \(page)")
        let result = await networking.executeRequest(
            request: TMDBEndpoint.nowPlaying(page: page),
            responseType: MovieResponse.self
        )
        
        switch result {
        case .success(let wrapper):
            logger.debug("Successfully fetched \(wrapper.response.results.count) now playing movies")
            return wrapper.response
        case .failure(let error):
            logger.error("Failed to fetch now playing movies: \(error)")
            throw error
        }
    }
    
    func fetchPopular(page: Int = 1) async throws -> MovieResponse {
        logger.debug("Fetching popular movies for page: \(page)")
        let result = await networking.executeRequest(
            request: TMDBEndpoint.popular(page: page),
            responseType: MovieResponse.self
        )
        
        switch result {
        case .success(let wrapper):
            logger.debug("Successfully fetched popular movies - Count: \(wrapper.response.results.count), Page: \(wrapper.response.page ?? 0), Total Pages: \(wrapper.response.totalPages ?? 0)")
            if wrapper.response.results.isEmpty {
                logger.warning("Popular movies response is empty")
            }
            return wrapper.response
        case .failure(let error):
            logger.error("Failed to fetch popular movies: \(error.localizedDescription)")
            throw error
        }
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> MovieResponse {
        logger.debug("Searching movies with query: \(query), page: \(page)")
        let result = await networking.executeRequest(
            request: TMDBEndpoint.search(query: query, page: page),
            responseType: MovieResponse.self
        )
        
        switch result {
        case .success(let wrapper):
            logger.debug("Successfully fetched \(wrapper.response.results.count) search results")
            return wrapper.response
        case .failure(let error):
            logger.error("Failed to search movies: \(error)")
            throw error
        }
    }
    
    func fetchMovieDetails(id: Int) async throws -> Movie {
        logger.debug("Fetching details for movie: \(id)")
        let result = await networking.executeRequest(
            request: TMDBEndpoint.movieDetails(id: id),
            responseType: Movie.self
        )
        
        switch result {
        case .success(let wrapper):
            logger.debug("Successfully fetched details for movie: \(wrapper.response.title)")
            return wrapper.response
        case .failure(let error):
            logger.error("Failed to fetch movie details: \(error)")
            throw error
        }
    }
}
