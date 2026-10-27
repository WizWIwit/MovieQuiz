//
//  GameResult.swift
//  MovieQuiz
//
//

import Foundation

struct GameResult: Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (lhs: GameResult, rhs: GameResult) -> Bool {
        return lhs.correct < rhs.correct
    }
}

