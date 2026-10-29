import UIKit

// MARK: - Контроллер экрана
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - аутлеты
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // аутлеты для управления кнопками
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    // MARK: - свойства
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private let statisticService: StatisticServiceProtocol = StatisticService()
    private let questionsAmount: Int = 10

    //  фабрика через ленивую переменную, передаём MoviesLoader и self в качестве делегата
    private lazy var questionFactory: QuestionFactoryProtocol = {
        let factory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        return factory
    }()
    
    // Переменная для нового презентера алертов
    private var alertPresenter: AlertPresenter?
    
    // MARK: - LC экрана
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // инициализация презентера алертов, передаём self в качестве делегата
        alertPresenter = AlertPresenter(delegate: self)
        
        // Скругление углов для плаката фильма
                imageView.layer.cornerRadius = 20
        
        // при старте приложения врубаем крутилку, включаем и загружаем данные из сети
        showLoadingIndicator()
        questionFactory.loadData()
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
    
    //   переписано под работу с типом Data в QuizQuestion
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let movieImage = UIImage(data: model.image) ?? UIImage()
        let questionStep = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        
        return QuizStepViewModel(
            image: movieImage,
            question: model.text,
            questionNumber: questionStep
        )
    }
    
    private func showNextQuestionOrResults() {
           // Проверяем, закончился ли раунд (сыграно ли 10 вопросов)
           if currentQuestionIndex == questionsAmount - 1 {
               
               // перенос расчета статистики и показа алерта в Главный поток
               DispatchQueue.main.async { [weak self] in
                   guard let self = self else { return }
                   
                   // Сохраняем результаты игры в UserDefaults через сервис
                   self.statisticService.store(correct: self.correctAnswers, total: self.questionsAmount)

                   // Получаем актуальные данные из сервиса для текста алерта
                   let gamesCount = self.statisticService.gamesCount
                   let bestGame = self.statisticService.bestGame
                   let totalAccuracy = String(format: "%.2f", self.statisticService.totalAccuracy)

                   // Форматируем дату рекорда
                   let dateText = bestGame.date.dateTimeString

                   // Формируем многострочный текст по макету
                   let statsText = """
                   Ваш результат: \(self.correctAnswers)/\(self.questionsAmount)
                   Количество сыгранных игр: \(gamesCount)
                   Рекорд: \(bestGame.correct)/\(bestGame.total) (\(dateText))
                   Средняя точность: \(totalAccuracy)%
                   """

                   // Передаем текст во вью-модель алерта
                   let viewModel = QuizResultsViewModel(
                       title: "Этот раунд окончен!",
                       text: statsText,
                       buttonText: "Давай еще раз"
                   )
                   
                   // Показываем финальный алерт раунда
                   self.show(quiz: viewModel)
               }
           } else {
               // Если игра продолжается, увеличиваем индекс и запрашиваем следующий вопрос
               currentQuestionIndex += 1
               showCurrentQuestion()
           }
       }
    
    // переписано под использование AlertPresenter
    private func show(quiz result: QuizResultsViewModel) {
        
        // структура данных AlertModel
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            
            // сброс параметров и запуск игры заново при нажатии на кнопку
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            // Снова включаем крутилку перед началом новой игры
            self.showLoadingIndicator()
            self.questionFactory.requestNextQuestion()
        }
        
        // Передаем модель в презентер для отрисовки на экране
        alertPresenter?.showAlert(model: alertModel)
    }
    
    // Включение анимации индикатора загрузки крутилки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // Выключение анимации индикатора загрузки крутилки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // Показ ошибки сети с возможностью повторной загрузки
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Не-а, чёт сломалось",
            message: message,
            buttonText: "Ну пожавуста"
        ) { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.showLoadingIndicator()
            self.questionFactory.loadData() // Перезапускаем сетевой запрос
        }
        
        alertPresenter?.showAlert(model: model)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else { return }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // скрываем индикатор загрузки, как только пришёл вопрос с картинкой
                self.hideLoadingIndicator()
                
                self.show(quiz: viewModel)
            }
        }
    
    // Фильмы загрузились с сервера?
    func didLoadDataFromServer() {
        hideLoadingIndicator() // Прячем крутилку
        questionFactory.requestNextQuestion() // Запрашиваем самый первый вопрос раунда
    }
    
    // Если ошибка сети при попытке стянуть данные
    func didFailToLoadData(with error: Error) {
        // вызов функции показа ошибки сети
        showNetworkError(message: error.localizedDescription)
    }
}
