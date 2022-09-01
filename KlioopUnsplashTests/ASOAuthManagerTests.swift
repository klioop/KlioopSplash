//
//  ASOAuthManagerTests.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/08/31.
//

import XCTest
import AuthenticationServices
import KlioopUnsplash

class ASOAuthManagerTests: XCTestCase {
    
    func test_loadToken_deliversError() {
        let sut = makeSUT()
        
        expect(sut, toCompletedWith: .failure(anyNSError()), with: anyNSError())
    }
    
    func test_loadToken_deliversToken() {
        let token = "a-token"
        let callbackURL = URL(string: "https://auth?token=\(token)")!
        let sut = makeSUT(url: callbackURL)
        
        expect(sut, toCompletedWith: .success(Token(accessToken: token)), for: callbackURL)
    }
    
    private func makeSUT(
        url: URL = URL(string: "any")!,
        scheme: String = "a scheme",
        context: ASWebAuthenticationPresentationContextProviding = ContextMock()
    ) -> ASOAuthManager {
        let sut = ASOAuthManager(authURL: url, scheme: scheme, context: context)
        trackMemoryLeak(sut)
        return sut
    }
    
    private func expect(_ sut: ASOAuthManager, toCompletedWith expectedResult: OAuthManager.Result, for url: URL? = nil, with error: Error? = nil, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        let completion = sut.exchangeToken { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError), .failure):
                XCTAssertNotNil(receivedError, file: file, line: line)
                
            case let (.success(receivedToken), .success(expectedToken)):
                XCTAssertEqual(receivedToken.accessToken, expectedToken.accessToken, file: file, line: line)
                
            default:
                XCTFail("Expected \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        completion(url, error)
        
        waitForExpectations(timeout: 1.0)
    }
    
    private func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class ContextMock: NSObject, ASWebAuthenticationPresentationContextProviding {
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            NSWindow()
        }
    }
}
