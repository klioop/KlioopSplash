//
//  TokenExtractor.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation

struct TokenExtractor {
    static func extractToken(from url: URL) -> Token {
        let query = URLComponents(string: url.absoluteString)?.queryItems
        let tokenString = query?.filter { $0.name == "token" }.first?.value
        return Token(accessToken: tokenString!)
    }
}
