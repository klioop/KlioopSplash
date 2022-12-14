//
//  RemoteLoaderTests.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/09/08.
//

import XCTest
import KlioopUnsplash

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
        
        expect(sut, toCompletedWith: failure(with: .connectivity), when: {
            client.completeLoading(with: anyNSError())
        })
    }
    
    func test_load_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })

        expect(sut, toCompletedWith: failure(with: .invalidData), when: {
            client.completeLoadingSuccessfully(with: response())
        })
    }
    
    func test_load_deliversResourceOnSuccess() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { _, _ in
            "a resource"
        })

        expect(sut, toCompletedWith: .success(resource), when: {
            client.completeLoadingSuccessfully(with: response())
        })
    }
    
    func test_load_deliversNothingAfterSUTInstanceHasBeenDeallocated() {
        let client = ClientSpy()
        var sut: SUT? = .init(request: anyRequest(), client: client, mapper: { _, _ in "any" })
        
        var receivedResult: Result<String, Error>?
        sut?.load { receivedResult = $0 }
        
        sut = nil
        client.completeLoading(with: anyNSError())
        
        XCTAssertNil(receivedResult)
    }

    // MARK: - Helpers
    
    typealias SUT = RemoteLoader<String>
    
    private func makeSUT(
        request: URLRequest = URLRequest(url: anyURL()),
        mapper: @escaping SUT.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: SUT, client: ClientSpy) {
        let client = ClientSpy()
        let sut = RemoteLoader(request: request, client: client, mapper: mapper)
        trackMemoryLeak(client)
        trackMemoryLeak(sut)
        return (sut, client)
    }
    
    private func failure(with error: SUT.Error) -> Result<String, SUT.Error> {
        .failure(error)
    }
    
    private func expect(_ sut: SUT, toCompletedWith expectedResult: Result<String, SUT.Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
                
            case let (.failure(receivedError as SUT.Error), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
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
        
        func completeLoadingSuccessfully(at index: Int = 0, with response: (Data, HTTPURLResponse)) {
            completions[index](.success(response))
        }
    }
    
    private func anyRequest(url: URL = anyURL()) -> URLRequest {
        URLRequest(url: url)
    }
    
    private func response(with data: Data = Data("any".utf8)) -> (data: Data, response: HTTPURLResponse) {
        (data, anyHTTPURLResponse())
    }
    
    private func anyHTTPURLResponse(with code: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
    }
}
