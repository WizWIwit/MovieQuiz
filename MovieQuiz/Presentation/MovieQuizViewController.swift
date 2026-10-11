import UIKit

// MARK: - Вью-модели и модели данных (Сделаны private)

private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

private struct QuizQuestion {
    let imageName: String // Переименовано с image на imageName по рекомендации
    let text: String = "Рейтинг этого фильма больше чем 6?"
    let correctAnswer: Bool
}

// MARK: - Контроллер экрана
final class MovieQuizViewController: UIViewController {
    
    // MARK: - аутлеты
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // аутлеты для управления кнопками
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - свойства
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    // MARK: - LC экрана
    override func viewDidLoad() {
        super.viewDidLoad()
        showCurrentQuestion()
    }
    
    // MARK: - действия
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = currentQuestion.correctAnswer == false
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = currentQuestion.correctAnswer == true
        showAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - приватные методы
    
    // Метод блокировки кнопок (то что было "Для размышлений")
    private func changeButtonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        // Мгновенно выключаем кнопки при ответе блокируя спам кнопок
        changeButtonsState(isEnabled: false)
        
        if isCorrect { correctAnswers += 1 }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        // кнопки включаются только при показе свежих данных нового вопроса
        changeButtonsState(isEnabled: true)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.imageName) ?? UIImage()
        let questionStep = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: questionStep
        )
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - МОКи
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
}

