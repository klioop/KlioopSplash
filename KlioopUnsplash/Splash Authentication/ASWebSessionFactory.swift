//
//  ASWebSessionFactory.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/09/04.
//

import Foundation
import AuthenticationServices

public final class ASWebSessionFactory {
    private let authURL: URL
    private let scheme: String
    private let context: ASWebAuthenticationPresentationContextProviding
    
    public init(authURL: URL, scheme: String, context: ASWebAuthenticationPresentationContextProviding) {
        self.authURL = authURL
        self.scheme = scheme
        self.context = context
    }
    
    func asWebSession(completion: @escaping (URL?, Error?) -> Void) -> ASWebAuthenticationSession {
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme, completionHandler: completion)
        session.presentationContextProvider = context
        return session
    }
}
