//
//  XCTestCase+MemoryLeakTrackingHelper.swift
//  Home Active ManTests
//
//  Created by Josef Santamaria on 2020-12-17.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dealocated, potentional memory leak", file: file, line: line)
        }
    }
}
