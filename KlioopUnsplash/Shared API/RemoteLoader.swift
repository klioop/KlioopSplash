//
//  RemoteLoader.swift
//  KlioopUnsplash
//
//  Created by klioop on 2022/09/08.
//

import Foundation

public final class RemoteLoader<Resource> {
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    private let request: URLRequest
    private let client: HTTPClient
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(request: URLRequest, client: HTTPClient, mapper: @escaping Mapper) {
        self.request = request
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result<Resource, Swift.Error>) -> Void) {
        client.perform(request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(self.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result<Resource, Swift.Error> {
        Result {
            do {
                return try mapper(data, response)
            } catch {
                throw Error.invalidData
            }
        }
    }
}
