//
//  MoviesLoader.swift
//  MovieQuiz
//
//

import Foundation

// MARK: - Protocol
protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

// MARK: - Loader
struct MoviesLoader: MoviesLoading {
    
    private let networkClient = NetworkClient()
    
    // MARK: - URL фильма
    private var mostPopularMoviesUrl: URL {
        
        // Тут заменил ссылку из прктикума своей, подкинул джейсона из imdb на гист и ссылкой сюда
        guard let url = URL(string: "https://gist.githubusercontent.com/WizWIwit/18fd7b60b78468ae03c0ed6dfd38ade8/raw/82d1efabc0e25495acedecb8539ad7c0d6bff271/movies.json") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    // MARK: - Public Methods
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        
        // сетевой запрос через созданный NetworkClient
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    
                    // распакоука полученных из сети данных в модель данных
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    
                    // Обработка ошибок JSON
                    handler(.failure(error))
                }
            case .failure(let error):
                
                // Обработка ошибок сети/таймаута
                handler(.failure(error))
            }
        }
    }
}
