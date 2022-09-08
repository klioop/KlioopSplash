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
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs, [])
    }
    
    func test_load_requestsForAGivenURLRequest() {
        let url = URL(string: "http://a-given-url.io")!
        let (sut, client) = makeSUT(request: anyRequest(url: url))
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(request: URLRequest = URLRequest(url: anyURL()), file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteLoader, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteLoader(request: request, client: client)
        trackMemoryLeak(client)
        trackMemoryLeak(sut)
        return (sut, client)
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
