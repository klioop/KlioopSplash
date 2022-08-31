//
//  OAuthManager.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation

public protocol OAuthManager {
    typealias Result = Swift.Result<Token, Swift.Error>
    
    func loadToken(completion: @escaping (Result) -> Void)
}
