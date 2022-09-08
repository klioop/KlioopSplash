//
//  HTTPClient.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/09/08.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func perform(_ request: URLRequest, completion: @escaping (Result) -> Void)
}
