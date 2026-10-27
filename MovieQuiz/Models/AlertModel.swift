//
//  AlertModel.swift
//  MovieQuiz
//

import Foundation

/// Модель данных для передачи в AlertPresenter
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void // Замыкание без параметров для действия по кнопке
}
