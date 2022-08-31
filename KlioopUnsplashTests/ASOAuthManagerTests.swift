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
    
    func test_loadToken_providesTheContextToTheSession() {
        let (sut, session) = makeSUT(context: ContextMock())
        
        sut.loadToken { _ in }
        
        XCTAssertNotNil(session.presentationContextProvider)
    }
    
    func test_loadToken_startsTheASSession() {
        let (sut, session) = makeSUT()
        
        sut.loadToken { _ in }
        
        XCTAssertEqual(session.startCount, 1)
    }
    
    func test_loadToken_deliversError() {
        let (sut, _) = makeSUT()
        
        sut.exchangeToken(from: anyURL(), error: anyNSError())
        
        var receivedError: Error?
        sut.loadToken { result in
            if case let .failure(error) = result {
                receivedError = error
            }
        }
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_loadToken_deliversToken() {
        let (sut, _) = makeSUT()
        let token = "a-token"
        let callbackURL = URL(string: "https://auth?token=\(token)")!

        sut.exchangeToken(from: callbackURL, error: nil)
        
        var receivedToken: Token?
        sut.loadToken { result in
            receivedToken = try? result.get()
        }

        XCTAssertEqual(receivedToken?.accessToken, token)
    }
    
    private func makeSUT(
        context: ASWebAuthenticationPresentationContextProviding? = nil
    ) -> (sut: ASOAuthManager, session: ASWebAuthenticationSessionMock) {
        let session = ASWebAuthenticationSessionMock()
        let sut = ASOAuthManager(context: context)
        sut.session = session
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
