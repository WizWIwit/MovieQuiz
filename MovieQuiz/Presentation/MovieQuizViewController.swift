import UIKit

// MARK: - Вью-модель экрана вопроса
struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// MARK: - Вью-модель экрана результатов
struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

// MARK: - исходные данные
struct QuizQuestion {
    let image: String
    let text: String = "Рейтинг этого фильма больше чем 6?"
    let correctAnswer: Bool
}

// MARK: - Контроллер экрана
final class MovieQuizViewController: UIViewController {
    
    // MARK: - аутлеты
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    // MARK: - Состояние игры
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    // MARK: - Жизненный цикл экрана
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Старт первого вопроса
        showCurrentQuestion()
    }
    
    // MARK: - Нажатия кнопок для юзера
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
    
    // MARK: - Внутренние функции
    
    // Логика перехода к следующему вопросу или финал
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            
            // текст с результатом раунда
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)"
            
            // вью-модель для Результата
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            
            // Показываем алерт
            show(quiz: viewModel)
            
        } else {
            
            // Если вопросы еще есть — переключаем индекс вперед
            currentQuestionIndex += 1
            
            // Находим следующий моковый вопрос, конвертируем его и отображаем на экране
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    // Метод показа результатов раунда квиза (создание и показ системного алерта)
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Метод, который делает рамку картинки зелёной или красной
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }
    
    // Метод первоначального запуска логики показа вопроса
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
    }
    
    // Метод вывода на экран готовых данных из вью-модели вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Метод конвертации мокового вопроса во вью-модель для экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.image) ?? UIImage()
        let questionStep = "\(currentQuestionIndex + 1)/\(questions.count)"
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: questionStep
        )
    }
    
    // MARK: - Массив вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", correctAnswer: true),
        QuizQuestion(image: "The Avengers", correctAnswer: true),
        QuizQuestion(image: "Deadpool", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", correctAnswer: true),
        QuizQuestion(image: "Old", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", correctAnswer: false),
        QuizQuestion(image: "Tesla", correctAnswer: false),
        QuizQuestion(image: "Vivarium", correctAnswer: false)
    ]
}
