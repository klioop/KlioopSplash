//
//  ASOAuthManager.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation
import AuthenticationServices

public final class ASOAuthManager: OAuthManager {
    private let authURL: URL
    private let scheme: String
    private let context: ASWebAuthenticationPresentationContextProviding
    
    public init(authURL: URL, scheme: String, context: ASWebAuthenticationPresentationContextProviding) {
        self.authURL = authURL
        self.scheme = scheme
        self.context = context
    }
    
    public enum Error: Swift.Error {
        case authenticationError
    }
    
    public func loadToken(completion: @escaping (OAuthManager.Result) -> Void) {
        let session = session(completion: completion)
        session.presentationContextProvider = context
        session.start()
    }
    
    public func exchangeToken(completion: @escaping (OAuthManager.Result) -> Void) -> (URL?, Swift.Error?) -> Void {
        return { callbackURL, error in
            guard error == nil, let url = callbackURL else { return completion(.failure(Error.authenticationError)) }
        
            let token = TokenExtractor.extractToken(from: url)
            completion(.success(token))
        }
    }
    
    private func session(completion: @escaping (OAuthManager.Result) -> Void) -> ASWebAuthenticationSession {
        ASWebAuthenticationSession(
           url: authURL,
           callbackURLScheme: scheme,
           completionHandler: exchangeToken {
               completion($0)
       })
    }
}
