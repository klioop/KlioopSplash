//
//  ASOAuthManager.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation
import AuthenticationServices

public struct Token {
    public let accessToken: String
}

public class ASOAuthManager {
    public var session: ASWebAuthenticationSession?
    
    public var context: ASWebAuthenticationPresentationContextProviding?
    
    public init(context: ASWebAuthenticationPresentationContextProviding?) {
        self.context = context
    }
    
    private lazy var result: Result<Token, Error> = .failure(.authenticationError)
    
    public enum Error: Swift.Error {
        case authenticationError
    }
    
    public func loadToken(completion: @escaping (Result<Token, Error>) -> Void) {
        session?.presentationContextProvider = context
        session?.start()
        completion(result)
    }
    
    public func exchangeToken(from callbackURL: URL?, error: Swift.Error?) {
        guard error == nil, let url = callbackURL else { return failure() }
        
        let query = URLComponents(string: url.absoluteString)?.queryItems
        let tokenString = query?.filter { $0.name == "token" }.first?.value
        token(from: tokenString!)
    }
    
    private func failure() {
        result = .failure(Error.authenticationError)
    }
    
    private func token(from tokenString: String) {
        result = .success(Token(accessToken: tokenString))
    }
}
