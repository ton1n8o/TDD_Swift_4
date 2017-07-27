//
//  APIClientTests.swift
//  ToDoTests
//
//  Created by Antonio da Silva on 24/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import XCTest
@testable import ToDo

class APIClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_Login_UsesExpectedURL() {
        let sut = APIClient()
        
        let mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        
        sut.session = mockURLSession
        
        let completion = {
            (token: Token?, error: Error?) in
        }
        
        sut.loginUser(withName: "dasdöm", password: "%&34", completion: completion)
        
        guard let url = mockURLSession.url else {
            XCTFail(); return
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "/%&=?$#+-~@<>|\\*,.()[]{}^!").inverted
        
        guard let expectedUserName = "dasdöm".addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            fatalError()
        }

        guard let expectedPassword = "%&34".addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            fatalError()
        }
        
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        XCTAssertEqual(urlComponents?.host, "awesometodos.com")
        XCTAssertEqual(urlComponents?.path, "/login")
        
        XCTAssertEqual(urlComponents?.percentEncodedQuery, "username=\(expectedUserName)&password=\(expectedPassword)")
        
        // another possible test
//        let qiName = URLQueryItem(name: "username", value: expectedUserName)
//        let qiPassword = URLQueryItem(name: "password", value: expectedPassword)
        
//        XCTAssertTrue(urlComponents?.queryItems?.contains(qiPassword) ?? false)
//        XCTAssertTrue(urlComponents?.queryItems?.contains(qiName) ?? false)
        
    }
    
    func test_Login_WhenSuccessfill_CreatesToken() {
        let sut = APIClient()
        let jsonData = "{\"token\": \"1234567890\"}".data(using: .utf8)
        let mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: nil)
        
        sut.session = mockURLSession
        
        let tokenExpectation = expectation(description: "Token")
        var catchedToken: Token? = nil
        sut.loginUser(withName: "Foo", password: "Bar") { (token, error) in
            catchedToken = token
            tokenExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertEqual(catchedToken?.id, "1234567890")
        }
    }
    
    func test_Login_WhenJSONIsInvalid_ReturnsError() {
        let sut = APIClient()
        
        let mockURLSession = MockURLSession(data: Data(), urlResponse: nil, error: nil)
        
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        sut.loginUser(withName: "Foo", password: "Bar") { (token, error) in
            catchedError = error
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
    func test_Login_WhenDataIsNil_ReturnsError() {
        let sut = APIClient()
        
        let mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        sut.loginUser(withName: "Foo", password: "Bar") { (token, error) in
            catchedError = error
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
    func test_Login_WhenResponseHasError_ReturnsError() {
        let sut = APIClient()
        let error = NSError(domain: "SomeError", code: 1234, userInfo: nil)
        let jsonData = "{\"token\": \"1234567890\"}".data(using: .utf8)
        let mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: error)
        
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        sut.loginUser(withName: "Foo", password: "Bar") { (token, error) in
            catchedError = error
            errorExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
}

extension APIClientTests {
    class MockURLSession: SessionProtocol {
        var url: URL?
        private let dataTask: MockTask
        
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            dataTask = MockTask(data: data, urlResponse: urlResponse, error: error)
        }
        
        func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.url = url
            dataTask.completionHandler = completionHandler
            return dataTask
        }
    }
    
    class MockTask: URLSessionDataTask {
        
        private let data: Data?
        private let urlResponse: URLResponse?
        private let responseError: Error?
        
        typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
        var completionHandler: CompletionHandler?
        
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            self.data = data
            self.urlResponse = urlResponse
            self.responseError = error
        }
        
        override func resume() {
            DispatchQueue.main.async {
                self.completionHandler?(self.data, self.urlResponse, self.responseError)
            }
        }
    }
}
