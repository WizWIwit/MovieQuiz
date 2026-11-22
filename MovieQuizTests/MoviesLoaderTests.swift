//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by WizWI on 08.11.2026.
//

import XCTest
@testable import MovieQuiz

struct StubNetworkClient: NetworkRouting {
    
    enum TestError: Error {
        case test
    }
    
    let emulateError: Bool
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
    
    private var expectedResponse: Data {
        """
        {
           "errorMessage": "",
           "items": [
                {
                    "fullTitle": "Prey (2022)",
                    "imDbRating": 7.2,
                    "image": "https://media-amazon.com",
                    "title": "Prey"
                }
           ]
        }
        """.data(using: .utf8) ?? Data()
    }
}

final class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 1)
                expectation.fulfill()
            case .failure:
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
