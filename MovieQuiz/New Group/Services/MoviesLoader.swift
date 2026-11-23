//
//  MoviesLoader.swift
//  MovieQuiz
//
//

import Foundation

// MARK: Protocol
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

// MARK: Loader
struct MoviesLoader: MoviesLoading {
    
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: URL фильма
    private var mostPopularMoviesUrl: URL {
        // Тут заменил ссылку из прктикума своей, подкинул джейсона из imdb на гист и ссылкой сюда
        guard let url = URL(string: "https://gist.githubusercontent.com/WizWIwit/18fd7b60b78468ae03c0ed6dfd38ade8/raw/82d1efabc0e25495acedecb8539ad7c0d6bff271/movies.json") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    // MARK: Public методы
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        // Режим изоляции для UI-тестов
        if ProcessInfo.processInfo.arguments.contains("-UITest") {
            let mockJSON = """
            {
               "errorMessage": "",
               "items": [
                    {
                        "fullTitle": "The Godfather",
                        "imDbRating": 9.2,
                        "image": "mock_1",
                        "title": "The Godfather"
                    },
                    {
                        "fullTitle": "The Dark Knight",
                        "imDbRating": 9.0,
                        "image": "mock_2",
                        "title": "The Dark Knight"
                    }
               ]
            }
            """.data(using: .utf8) ?? Data()
            
            if let decoded = try? JSONDecoder().decode(MostPopularMovies.self, from: mockJSON) {
                handler(.success(decoded))
            }
            return
        }

        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

