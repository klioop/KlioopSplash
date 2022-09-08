//
//  XCTestCase+TrackMemoryLeak.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/09/01.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should be deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
