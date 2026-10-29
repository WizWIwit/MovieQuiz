//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//

import Foundation

// MARK: - Делегат для уведомления контроллера о событиях фабрики
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()                  // успешная загрузка фильмов
    func didFailToLoadData(with error: Error)     // ошибка загрузки
}

// MARK: - Протокол фабрики вопросов
protocol QuestionFactoryProtocol: AnyObject {
    func setup(delegate: QuestionFactoryDelegate)
    func requestNextQuestion()
    func loadData() //  первичная загрузка данных из сети
}

