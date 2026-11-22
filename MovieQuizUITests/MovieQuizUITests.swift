//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//



import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launchArguments = ["-UITest"]
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        XCTAssertFalse(app.alerts.element.exists, "На экране появился алерт ошибки сети!")
        
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 10), "Первый постер не появился на экране")
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.isEnabled, "Кнопка Yes заблокирована")
        yesButton.tap()
        
        sleep(7)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        XCTAssertTrue(firstPoster.waitForExistence(timeout: 10))
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.isEnabled)
        noButton.tap()
        
        sleep(7)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts.element
        
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(app.alerts.element.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
