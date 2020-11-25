//
//  Home_Active_ManTests.swift
//  Home Active ManTests
//
//  Created by Josef Santamaria on 2020-11-24.
//

import XCTest

class RemoteWorkoutLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
        
    override func get(from url: URL) {
        requestedURL = url
    }
}

class Home_Active_ManTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteWorkoutLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_loadDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteWorkoutLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }

}
