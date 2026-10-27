import UIKit

// MARK: - Контроллер экрана
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
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
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol = StatisticService()

    
    // Фабрика вопросов
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    
    // Переменная для нового презентера алертов
    private var alertPresenter: AlertPresenter?
    
    // MARK: - LC экрана
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Связываем фабрику с контроллером
        questionFactory.setup(delegate: self)
        
        // Инициализируем презентер алертов, передавая self в качестве делегата
        alertPresenter = AlertPresenter(delegate: self)
        
        showCurrentQuestion()
    }
    
    // MARK: - действия
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = currentQuestion.correctAnswer == false
        showAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = currentQuestion.correctAnswer == true
        showAnswerResult(isCorrect: isCorrect)
    }
    
    // MARK: - приватные методы
    
    private func changeButtonsState(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showAnswerResult(isCorrect: Bool) {
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
        questionFactory.requestNextQuestion()
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        changeButtonsState(isEnabled: true)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(named: model.imageName) ?? UIImage()
        let questionStep = "\(currentQuestionIndex + 1)/10"
        
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: questionStep
        )
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == 10 - 1 {

            // Сохраняем результаты игры в UserDefaults через сервис
            statisticService.store(correct: correctAnswers, total: 10)

            // Получаем актуальные данные из сервиса для текста алерта
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)

            // Форматируем дату рекорда в привычный вид
            let dateText = bestGame.date.dateTimeString

            // Формирууем многострочный текс по макету из задания
            let statsText = """
            Ваш результат: \(correctAnswers)/10
            Количество сыгранных игр: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateText))
            Средняя точность: \(totalAccuracy)%
            """

            // Передаем текст во вью-модель алерта
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: statsText, // здесь вся статистика за все игры
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            showCurrentQuestion()
        }
    }
    
    // Метод переписан под использование AlertPresenter
    private func show(quiz result: QuizResultsViewModel) {
        // 1. Создаем структуру данных AlertModel
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            
            // сброс параметров и запуск игры заново при нажатии на кнопку
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }
        
        // Передаем модель в презентер для отрисовки на экране
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
