//
//  AlertPresenter.swift
//  MovieQuiz
//
//

import UIKit

/// Класс, отвечающий за отображение алертов в приложении
final class AlertPresenter {
    
    // Слабая ссылка на контроллер для избежания утечек памяти (retain cycles)
    private weak var delegate: UIViewController?
    
    // Передаем контроллер при инициализации
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    /// Метод для отображения алерта на основе переданной модели
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            // Вызываем блок кода замыкания (перезапуск игры)
            model.completion()
        }
        
        alert.addAction(action)
        
        // Показываем алерт на экране текущего контроллера
        delegate?.present(alert, animated: true, completion: nil)
    }
}
