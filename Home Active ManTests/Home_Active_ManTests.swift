//
//  Home_Active_ManTests.swift
//  Home Active ManTests
//
//  Created by Josef Santamaria on 2020-11-24.
//

import XCTest

class RemoteWorkoutLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class Home_Active_ManTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let _ = RemoteWorkoutLoader()
        
        XCTAssertNil(client.requestedURL)
    }

}
