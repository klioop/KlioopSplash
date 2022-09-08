//
//  ASOAuthManager.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation
import AuthenticationServices

public final class ASOAuthManager: TokenLoader {
    private let authURL: URL
    private let scheme: String?
    private let context: ASWebAuthenticationPresentationContextProviding
    
    public init(authURL: URL, scheme: String?, context: ASWebAuthenticationPresentationContextProviding) {
        self.authURL = authURL
        self.scheme = scheme
        self.context = context
    }
    
    public enum Error: Swift.Error {
        case failedToAuthenticate
    }
    
    public func loadToken(completion: @escaping (TokenLoader.Result) -> Void) {
        let session = asWebSession(completion: completion)
        session.start()
    }
    
    public func exchangeToken(completion: @escaping (TokenLoader.Result) -> Void) -> (URL?, Swift.Error?) -> Void {
        return { callbackURL, error in
            guard
                error == nil,
                let url = callbackURL
            else { return completion(.failure(Error.failedToAuthenticate)) }
            
            completion(.success(TokenExtractor.extractToken(from: url)))
        }
    }
    
    private func asWebSession(completion: @escaping (TokenLoader.Result) -> Void) -> ASWebAuthenticationSession {
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme, completionHandler: self.exchangeToken(completion: completion))
        session.presentationContextProvider = context
        return session
    }
}
