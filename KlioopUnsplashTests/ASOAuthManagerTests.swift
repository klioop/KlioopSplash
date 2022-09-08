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
        
        let receivedError = resultError(with: sut, with: anyNSError())
        
        XCTAssertNotNil(receivedError)
    }
    
    func test_loadToken_deliversToken() {
        let token = "a-token"
        let callbackURL = URL(string: "https://auth?token=\(token)")!
        let sut = makeSUT(url: callbackURL)
    
        let receivedToken = resultToken(with: sut, for: callbackURL)
        
        XCTAssertEqual(receivedToken?.accessToken, token)
    }
    
    private func makeSUT(
        url: URL = anyURL(),
        scheme: String = "a scheme",
        context: ASWebAuthenticationPresentationContextProviding = ContextMock()
    ) -> ASOAuthManager {
        let factory = ASWebSessionFactory(authURL: url, scheme: scheme, context: context)
        let sut = ASOAuthManager(factory: factory)
        trackMemoryLeak(sut)
        return sut
    }
    
    private func result(with sut: ASOAuthManager, for url: URL?, with error: Error?) -> Result<Token, Error> {
        let exp = expectation(description: "wait for completion")
        
        var receivedResult: Result<Token, Error>!
        sut.exchangeToken { result in
            receivedResult = result
            exp.fulfill()
        }(url, error)
        
        waitForExpectations(timeout: 1.0)
        
        return receivedResult
    }
    
    private func resultToken(with sut: ASOAuthManager, for url: URL) -> Token? {
        try? result(with: sut, for: url, with: nil).get()
    }
    
    private func resultError(with sut: ASOAuthManager, with error: Error, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let receivedResult = result(with: sut, for: nil, with: error)
        
        switch receivedResult {
        case let .failure(error):
            return error
            
        default:
            XCTFail("Expected failure but got \(receivedResult) instead", file: file, line: line)
            return nil
        }
    }
    
    private class ContextMock: NSObject, ASWebAuthenticationPresentationContextProviding {
        func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
            NSWindow()
        }
    }
}
