//
//  ASOAuthManager.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation
import AuthenticationServices

public final class ASOAuthManager: OAuthManager {
    private let sessionFactory: ASWebSessionFactory
    
    public init(factory: ASWebSessionFactory) {
        self.sessionFactory = factory
    }
    
    public enum Error: Swift.Error {
        case authenticationError
    }
    
    public func loadToken(completion: @escaping (OAuthManager.Result) -> Void) {
        let session = sessionFactory.asWebSession(completion: exchangeToken(completion: completion))
        session.start()
    }
    
    public func exchangeToken(completion: @escaping (OAuthManager.Result) -> Void) -> (URL?, Swift.Error?) -> Void {
        return { callbackURL, error in
            guard
                error == nil,
                let url = callbackURL
            else { return completion(.failure(Error.authenticationError)) }
            
            completion(.success(TokenExtractor.extractToken(from: url)))
        }
    }
}
