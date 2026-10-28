//
//  StatisticService.swift
//  MovieQuiz
//
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    // Ключи для UserDefaults
    private enum Keys: String {
        case correct
        case total
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Реализация свойств протокола
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = userDefaults.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = userDefaults.integer(forKey: Keys.bestGameTotal.rawValue)
            
            // ИСПРАВЛЕНИЕ: Если даты в базе нет (первый запуск), возвращаем "1970"
            // Если возвращать Date(), то при первой игре условие сравнения будет некорректным.
            let date = userDefaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date(timeIntervalSince1970: 0)
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            userDefaults.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            userDefaults.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            userDefaults.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue)
        let totalAmount = userDefaults.integer(forKey: Keys.total.rawValue)
        
        guard totalAmount > 0 else { return 0.0 }
        
        // Переводим в проценты
        return (Double(totalCorrect) / Double(totalAmount)) * 100
    }
    
    // MARK: - Сохранение результатов раунда
    
    func store(correct count: Int, total amount: Int) {
        // Увеличиваем счетчик игр
        gamesCount += 1
        
        // Копим общее число правильных ответов и вопросов
        let currentTotalCorrect = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let currentTotalAmount = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        
        userDefaults.set(currentTotalCorrect, forKey: Keys.correct.rawValue)
        userDefaults.set(currentTotalAmount, forKey: Keys.total.rawValue)
        
        // Получаем текущий рекорд из UserDefaults
        let currentBestGame = bestGame
        let newResult = GameResult(correct: count, total: amount, date: Date())
        
        // ИСПРАВЛЕНИЕ: Проверяем, первая ли это игра. Если игр еще не было (дата равна 1970),
        // сохраняем результат безоговорочно. Иначе — сравниваем с прошлым рекордом.
        if currentBestGame.date == Date(timeIntervalSince1970: 0) {
            bestGame = newResult
        } else if newResult > currentBestGame {
            bestGame = newResult
        }
    }
}
//Финальная версия
