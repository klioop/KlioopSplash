//
//  ASOAuthManager.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation
import AuthenticationServices

public final class ASOAuthManager: OAuthManager {
    public var session: ASWebAuthenticationSession?
    
    public let context: ASWebAuthenticationPresentationContextProviding
    
    public init(context: ASWebAuthenticationPresentationContextProviding) {
        self.context = context
    }
    
    private lazy var result: OAuthManager.Result = .failure(Error.authenticationError)
    
    public enum Error: Swift.Error {
        case authenticationError
    }
    
    public func loadToken(completion: @escaping (OAuthManager.Result) -> Void) {
        session?.presentationContextProvider = context
        session?.start()
        completion(result)
    }
    
    public func exchangeToken(from callbackURL: URL?, error: Swift.Error?) {
        guard error == nil, let url = callbackURL else { return failure() }
        
        success(with: TokenExtractor.extractToken(from: url))
    }
    
    private func failure() {
        result = .failure(Error.authenticationError)
    }
    
    private func success(with token: Token) {
        result = .success(token)
    }
}
