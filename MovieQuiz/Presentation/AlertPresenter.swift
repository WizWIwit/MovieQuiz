//
//  AlertPresenter.swift
//  MovieQuiz
//
//

import UIKit

/// Класс, отвечающий за отображение алертов в приложении
final class AlertPresenter {
    
    // Слабая ссылка на контроллер для избежания утечек памяти
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
            // перезапуск игры
            model.completion()
        }
        
        alert.addAction(action)
        
        // Показ алерта на экране контроллера
        delegate?.present(alert, animated: true, completion: nil)
    }
}
