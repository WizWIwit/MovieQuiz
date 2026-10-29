import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    // MARK: - Зависимости
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Свойства
    private var movies: [MostPopularMovie] = []
    
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
        // сетевая загрузка джейсона из гита
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    
                    // Сохраняем полученные фильмы
                    self.movies = mostPopularMovies.items
                    
                    // Если массив пустой, выводим ошибку
                    if self.movies.isEmpty {
                        let emptyError = NSError(domain: "JSONError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Фильмов не привезли, все вопросы к JSON"])
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
        // переход на фоновый поток для выбора фильма
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // случайный индекс из массива загруженных фильмов
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            // попытка достать фильм по этому индексу
            guard let movie = self.movies[safe: index] else { return }
            
            // автозамена и сжатие картинок
            let originalUrlString = movie.image.absoluteString
            var finalImageUrl = movie.image
            
            // замена домена Amazonа на CDN Практикума
            // странное решение возможно, но это решает проблему "could not be found" на уровне сети
            let secureUrlString = originalUrlString.replacingOccurrences(
                of: "https://media-amazon.com",
                with: "https://railway.app"
            )
            
            // Сжимаем картинку
            if let range = secureUrlString.range(of: "._V1_") {
                let baseUrl = secureUrlString[..<range.lowerBound]
                let compressedUrlString = String(baseUrl) + "._V1_UX300_.jpg"
                if let url = URL(string: compressedUrlString) {
                    finalImageUrl = url
                }
            } else if let url = URL(string: secureUrlString) {
                finalImageUrl = url
            }
        
            
            // асинхронный запрос для загрузки картинки
            URLSession.shared.dataTask(with: finalImageUrl) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.delegate?.didFailToLoadData(with: error)
                    }
                    return
                }
                
                guard let imageData = data, !imageData.isEmpty else {
                    DispatchQueue.main.async {
                        let customError = NSError(
                            domain: "ImageError",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "здесь фотосъёмка заперещена, камеру вырубай "]
                        )
                        self.delegate?.didFailToLoadData(with: customError)
                    }
                    return
                }
                
                // получаем реальный рейтинг фильма из модели
                            let rating = Float(movie.rating) ?? 0.0
                            
                            // Генерируем случайный порог (7, 8 или 9 как пример)
                            let randomRatingThreshold = Int.random(in: 7...9)
                            
                            // рандомное число в текст вопроса
                            let text = "Рейтинг этого фильма больше чем \(randomRatingThreshold)?"
                            
                            // сравниваем рейтинг фильма со случайным порогом
                            let correctAnswer = rating > Float(randomRatingThreshold)
                
                let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
                
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            }.resume()
        }
    }
}
