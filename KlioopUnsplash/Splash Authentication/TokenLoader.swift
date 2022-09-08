//
//  TokenLoader.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/08/31.
//

import Foundation

public protocol TokenLoader {
    typealias Result = Swift.Result<Token, Swift.Error>
    
    func loadToken(completion: @escaping (Result) -> Void)
}
