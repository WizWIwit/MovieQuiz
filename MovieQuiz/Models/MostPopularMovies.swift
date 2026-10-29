//
//  MostPopularMovies.swift
//  MovieQuiz
//
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String? // на случай null от сервера
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let image: URL
    
    // меняем тип String на Double, для соответствия JSON
    let ratingRaw: Double
    
    // перекидывает Double в String для фабрики вопросов
    var rating: String {
        return String(ratingRaw)
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case image
        case ratingRaw = "imDbRating" // числовой ключ imDbRating
    }
}
