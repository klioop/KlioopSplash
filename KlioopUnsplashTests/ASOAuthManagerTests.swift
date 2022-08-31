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
}

class ASOAuthManagerTests: XCTestCase {
    
    func test_init_doesNotStartAuthenticationSession() {
        let session = ASWebAuthenticationSessionSPY(url: URL(string: "any")!, callbackURLScheme: nil) { _, _ in }
        _ = ASOAuthManager(session: session)
        
        XCTAssertEqual(session.startCount, 0)
    }
    
    private class ASWebAuthenticationSessionSPY: ASWebAuthenticationSession {
        private(set) var startCount = 0
        
        override func start() -> Bool {
            super.start()
            startCount += 1
            return true
        }
    }
}
