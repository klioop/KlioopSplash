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
    
    func test_init() {
        let sut = makeSUT()
        
        XCTAssertNil(sut.session)
    }
    
    func test_loadToken_startsTheASSession() {
        let sut = makeSUT()
        let session = ASWebAuthenticationSessionMock()
        sut.session = session
        
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
    ) -> ASOAuthManager {
        let sut = ASOAuthManager(context: context)
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
