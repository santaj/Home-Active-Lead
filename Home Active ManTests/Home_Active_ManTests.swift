//
//  Home_Active_ManTests.swift
//  Home Active ManTests
//
//  Created by Josef Santamaria on 2020-11-24.
//

import XCTest

class RemoteWorkoutLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedURL: URL?
}

class Home_Active_ManTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteWorkoutLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_loadDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteWorkoutLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
