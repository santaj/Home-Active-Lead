//
//  Home_Active_ManTests.swift
//  Home Active ManTests
//
//  Created by Josef Santamaria on 2020-11-24.
//

import XCTest

class RemoteWorkoutLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
        
    func get(from url: URL) {
        requestedURL = url
    }
}

class Home_Active_ManTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-url.com")!
        _ = RemoteWorkoutLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_loadDataFromURL() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://a-given-url.com")!
        let sut = RemoteWorkoutLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

}
