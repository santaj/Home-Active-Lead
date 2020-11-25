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


class Home_Active_ManTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_init_loadDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }

    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteWorkoutLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteWorkoutLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?
            
        func get(from url: URL) {
            requestedURL = url
        }
    }

}
