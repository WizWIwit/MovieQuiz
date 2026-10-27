import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    // Слабая ссылка на делегата, предотвращаем утечки памяти
    weak var delegate: QuestionFactoryDelegate?
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(imageName: "The Godfather", correctAnswer: true),
        QuizQuestion(imageName: "The Dark Knight", correctAnswer: true),
        QuizQuestion(imageName: "Kill Bill", correctAnswer: true),
        QuizQuestion(imageName: "The Avengers", correctAnswer: true),
        QuizQuestion(imageName: "Deadpool", correctAnswer: true),
        QuizQuestion(imageName: "The Green Knight", correctAnswer: true),
        QuizQuestion(imageName: "Old", correctAnswer: false),
        QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild", correctAnswer: false),
        QuizQuestion(imageName: "Tesla", correctAnswer: false),
        QuizQuestion(imageName: "Vivarium", correctAnswer: false)
    ]
    
    //  метод настройки делегата из протокола
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
