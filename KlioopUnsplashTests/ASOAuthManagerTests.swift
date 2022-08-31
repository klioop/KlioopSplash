//
//  ASOAuthManagerTests.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/08/31.
//

import XCTest
import AuthenticationServices

struct Token {
    let accessToken: String
}

class ASOAuthManager {
    var session: ASWebAuthenticationSession?
    
    var context: ASWebAuthenticationPresentationContextProviding?
    
    init(context: ASWebAuthenticationPresentationContextProviding?) {
        self.context = context
    }
    
    var result: Result<Token, Error>? = nil
    
    enum Error: Swift.Error {
        case authenticationError
    }
    
    func loadToken(completion: @escaping (Result<Token, Error>) -> Void) {
        session?.presentationContextProvider = context
        session?.start()
        completion(result)
    }
    
    func exchangeToken(with callbackURL: URL?, error: Swift.Error?) {
        guard error != nil, let url = callbackURL else { return failure() }
        
//        let query = URLComponents(string: url.absoluteString)?.queryItems
//        let tokenString = query?.filter { $0.name == "token" }.first?.value
//        completion(.success(Token(accessToken: tokenString!)))
    }
    
    private func failure() {
        result = .failure(Error.authenticationError)
    }
}

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
    
    func test_exchangeToken_deliversError() {
        let sut = makeSUT()
        
        sut.exchangeToken(with: nil, error: anyNSError())
        
        XCTAssertThrowsError(try sut.result?.get())
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
