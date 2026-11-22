import Foundation
import UIKit

class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Зависимости
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Свойства
    private var movies: [MostPopularMovie] = []
    private var isLoadingQuestion = false
    private var uiTestQuestionIndex = 0
    
    // MARK: - Инициализатор
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Публичные методы
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    
                    if self.movies.isEmpty {
                        let emptyError = NSError(domain: "JSONError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Ошибка в отображении списка фильмов, проверьте массив."])
                        self.delegate?.didFailToLoadData(with: emptyError)
                    } else {
                        self.delegate?.didLoadDataFromServer()
                    }
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        guard !isLoadingQuestion else { return }
        isLoadingQuestion = true
        loadQuestionWithRetry(attemptsLeft: 5)
    }
    
    // MARK: - Приватные методы
    private func loadQuestionWithRetry(attemptsLeft: Int) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            if ProcessInfo.processInfo.arguments.contains("-UITest") {
                guard !self.movies.isEmpty else {
                    self.isLoadingQuestion = false
                    return
                }
                let index = self.uiTestQuestionIndex % self.movies.count
                self.uiTestQuestionIndex += 1
                let movie = self.movies[index]
                
                let assetName = movie.image.absoluteString == "mock_1" ? "The Godfather" : "The Dark Knight"
                let imageData = UIImage(named: assetName)?.jpegData(compressionQuality: 1.0) ?? Data()
                
                let rating = Float(movie.rating) ?? 0.0
                let randomRatingThreshold = Int.random(in: 7...9)
                let text = "Рейтинг этого фильма больше чем \(randomRatingThreshold)?"
                let correctAnswer = rating > Float(randomRatingThreshold)
                
                let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
                self.isLoadingQuestion = false
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
                return
            }
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else {
                self.isLoadingQuestion = false
                return
            }
            
            let originalUrlString = movie.image.absoluteString
            var finalImageUrl = movie.image
            
            if let range = originalUrlString.range(of: "._V1_") {
                let baseUrl = originalUrlString[..<range.lowerBound]
                let compressedUrlString = String(baseUrl) + "._V1_UX300_.jpg"
                if let url = URL(string: compressedUrlString) {
                    finalImageUrl = url
                }
            }
            
            URLSession.shared.dataTask(with: finalImageUrl) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    if attemptsLeft > 1 {
                        self.loadQuestionWithRetry(attemptsLeft: attemptsLeft - 1)
                    } else {
                        self.isLoadingQuestion = false
                        DispatchQueue.main.async {
                            self.delegate?.didFailToLoadData(with: error)
                        }
                    }
                    return
                }
                
                guard let imageData = data, !imageData.isEmpty else {
                    if attemptsLeft > 1 {
                        self.loadQuestionWithRetry(attemptsLeft: attemptsLeft - 1)
                    } else {
                        self.isLoadingQuestion = false
                        DispatchQueue.main.async {
                            let customError = NSError(
                                domain: "ImageError",
                                code: 404,
                                userInfo: [NSLocalizedDescriptionKey: "Ошибка, нет изображения "]
                            )
                            self.delegate?.didFailToLoadData(with: customError)
                        }
                    }
                    return
                }
                
                let rating = Float(movie.rating) ?? 0.0
                let randomRatingThreshold = Int.random(in: 7...9)
                let text = "Рейтинг этого фильма больше чем \(randomRatingThreshold)?"
                let correctAnswer = rating > Float(randomRatingThreshold)
                
                let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
                
                self.isLoadingQuestion = false
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }.resume()
        }
    }
}
