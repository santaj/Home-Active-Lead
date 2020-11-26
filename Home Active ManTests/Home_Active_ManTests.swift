//
//  Home_Active_ManTests.swift
//  Home Active ManTests
//
//  Created by Josef Santamaria on 2020-11-24.
//

import XCTest
import Home_Active_Man


class Home_Active_ManTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLCount.isEmpty)
    }
    
    func test_init_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLCount, [url])
    }
    
    func test_init_requestDataTwiceFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLCount, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedError: RemoteExerciseLoader.Error?
        sut.load() { error in capturedError = error }
        
        XCTAssertEqual(capturedError, .connectivity)
    }

    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteExerciseLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteExerciseLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLCount = [URL]()
        var error: Error?
            
        func get(from url: URL, completion: (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLCount.append(url)
        }
    }

}
