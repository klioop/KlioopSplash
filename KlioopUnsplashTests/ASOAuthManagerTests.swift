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
        
        var receivedError: Error?
        let sessionCompletion = sut.exchangeToken { result in
            if case let .failure(error) = result { receivedError = error }
        }
        
        sessionCompletion(anyURL(), anyNSError())
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_loadToken_deliversToken() {
        let token = "a-token"
        let callbackURL = URL(string: "https://auth?token=\(token)")!
        let sut = makeSUT(url: callbackURL)
        
        var receivedToken: Token?
        let sessionCompletion = sut.exchangeToken { result in
            receivedToken = try? result.get()
        }
        
        sessionCompletion(callbackURL, nil)
        
        XCTAssertEqual(receivedToken?.accessToken, token)
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
