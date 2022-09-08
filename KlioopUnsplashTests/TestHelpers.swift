//
//  TestHelpers.swift
//  KlioopUnsplashTests
//
//  Created by klioop on 2022/09/01.
//

import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}
