//
//  ASOAuthManagerTests.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/08/31.
//

import XCTest
import AuthenticationServices

class ASOAuthManager {
    let session: ASWebAuthenticationSession
    
    init(session: ASWebAuthenticationSession) {
        self.session = session
    }
    
    func loadToken() {
        session.start()
    }
}

class ASOAuthManagerTests: XCTestCase {
    
    func test_init_doesNotStartAuthenticationSession() {
        let (_, session) = makeSUT()
        
        XCTAssertEqual(session.startCount, 0)
    }
    
    func test_loadToken_startsTheSession() {
        let (sut, session) = makeSUT()
        
        sut.loadToken()
        sut.loadToken()
        
        XCTAssertEqual(session.startCount, 2)
    }
    
    private func makeSUT(
        url: URL = URL(string: "https://any-url.com")!,
        scheme: String? = nil,
        completion: @escaping (URL?, Error?) -> Void = { _, _ in }
    ) -> (sut: ASOAuthManager, session: ASWebAuthenticationSessionSPY) {
        let session = ASWebAuthenticationSessionSPY(url: url, callbackURLScheme: scheme, completionHandler: completion)
        let sut = ASOAuthManager(session: session)
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
    
    private class ASWebAuthenticationSessionSPY: ASWebAuthenticationSession {
        private(set) var startCount = 0
        
        override func start() -> Bool {
            startCount += 1
            return true
        }
    }
}
