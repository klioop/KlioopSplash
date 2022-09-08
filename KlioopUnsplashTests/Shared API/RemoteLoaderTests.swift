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
    
    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        client.perform(request) { result in
            if case let .failure(error) = result {
                completion(.failure(error))
            }
        }
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
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_deliversErrorOnFail() {
        let (sut, client) = makeSUT()
        let error = anyNSError()
        
        var receivedError: Error?
        sut.load() {
            if case let .failure(error) = $0 {
                receivedError = error
            }
        }
                        
        client.completeLoading(with: error)
        
        XCTAssertEqual(receivedError as? NSError, error)
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
        private var completions = [(HTTPClient.Result) -> Void]()
        
        var requestedURLs: [URL] {
            requestedRequests.map { $0.url! }
        }
        
        func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) {
            requestedRequests.append(request)
            completions.append(completion)
        }
        
        func completeLoading(at index: Int = 0, with error: Error) {
            completions[index](.failure(error))
        }
    }
    
    private func anyRequest(url: URL = anyURL()) -> URLRequest {
        URLRequest(url: url)
    }
}
