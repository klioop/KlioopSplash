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
    private let completion: (URL?, Error?) -> Void
    
    public init(authURL: URL, scheme: String, context: ASWebAuthenticationPresentationContextProviding, completion: @escaping (URL?, Error?) -> Void = { _, _ in }) {
        self.authURL = authURL
        self.scheme = scheme
        self.context = context
        self.completion = completion
    }
    
    func asWebSession() -> ASWebAuthenticationSession {
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme, completionHandler: completion)
        session.presentationContextProvider = context
        return session
    }
}
