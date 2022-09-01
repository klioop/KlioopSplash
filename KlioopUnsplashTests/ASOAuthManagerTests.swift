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
        let (sut, _) = makeSUT()
        
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
        let (sut, _) = makeSUT(url: callbackURL)
        
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
    ) -> (sut: ASOAuthManager, session: ASWebAuthenticationSessionMock) {
        let session = ASWebAuthenticationSessionMock()
        let sut = ASOAuthManager(authURL: url, scheme: scheme, context: context)
        trackMemoryLeak(session)
        trackMemoryLeak(sut)
        return (sut, session)
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
    
    private class ASWebAuthenticationSessionMock: ASWebAuthenticationSession {
        var startCount = 0
        
        override func start() -> Bool {
            startCount += 1
            return true
        }
        
        convenience init() {
            self.init(url: URL(string: "http://any-url.com")!, callbackURLScheme: nil) { _, _ in }
        }
    }
}
