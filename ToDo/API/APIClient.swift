//
//  APIClient.swift
//  ToDo
//
//  Created by Antonio da Silva on 24/07/2017.
//  Copyright © 2017 TNTStudios. All rights reserved.
//

import Foundation

class APIClient {
    
    lazy var session: SessionProtocol = URLSession.shared
    
    func loginUser(withName userName: String, password: String, completion: @escaping (Token?, Error?) -> Void) {
        
        let allowedCharacters = CharacterSet(charactersIn: "/%&=?$#+-~@<>|\\*,.()[]{}^!").inverted
        
        guard let encodedUserName = userName.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            fatalError()
        }
        
        guard let encodedPassword = password.addingPercentEncoding(withAllowedCharacters: allowedCharacters) else {
            fatalError()
        }
        
        let query = "username=\(encodedUserName)&password=\(encodedPassword)"
        guard let url = URL(string: "https://awesometodos.com/login?\(query)") else {
            fatalError()
        }
        
        session.dataTask(with: url) { (data, response, error) in
            
        }
    }
    
}

protocol SessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> URLSessionDataTask
}

extension URLSession: SessionProtocol {
    
}
