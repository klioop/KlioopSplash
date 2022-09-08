//
//  RemoteLoaderTests.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/09/08.
//

import XCTest

protocol HTTPClient {
    typealias Result = Swift.Result<Void, Error>
    
    func perform(_ request: URLRequest, completion: @escaping (Result) -> Void)
}

final class RemoteLoader {
    private let request: URLRequest
    private let client: HTTPClient
    
    init(request: URLRequest, client: HTTPClient) {
        self.request = request
        self.client = client
    }
    
    func load() {
        client.perform(request) { _ in }
    }
}

class RemoteLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestForURL() {
        let client = ClientSpy()
        _ = RemoteLoader(request: anyRequest(), client: client)
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsForAGivenURLRequest() {
        let client = ClientSpy()
        let url = URL(string: "http://a-given-url.io")!
        let sut = RemoteLoader(request: anyRequest(url: url), client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    private class ClientSpy: HTTPClient {
        private var requestedRequests = [URLRequest]()
        
        var requestedURLs: [URL] {
            requestedRequests.map { $0.url! }
        }
        
        func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedRequests.append(request)
        }
    }
    
    private func anyRequest(url: URL = anyURL()) -> URLRequest {
        URLRequest(url: url)
    }
}
