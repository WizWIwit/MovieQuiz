//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//

import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    func setup(delegate: QuestionFactoryDelegate)
    func requestNextQuestion()
}
