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
        
        let mockURLSession = MockURLSession()
        
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
    
}

extension APIClientTests {
    class MockURLSession: SessionProtocol {
        var url: URL?
        func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            self.url = url
            return URLSession.shared.dataTask(with: url)
        }
    }
}
