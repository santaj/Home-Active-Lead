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
        
        sut.load() {_ in}
        
        XCTAssertEqual(client.requestedURLCount, [url])
    }
    
    func test_init_requestDataTwiceFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() {_ in}
        sut.load() {_ in}
        
        XCTAssertEqual(client.requestedURLCount, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteExerciseLoader.Error]()
        sut.load() { capturedError.append($0) }
        
        let error = NSError(domain: "Test", code: 0)
        client.complete(with: error)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }

    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteExerciseLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteExerciseLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        
        var requestedURLCount = [URL]()
        private var messages = [(url: URL, completion: (Error) -> Void)]()
            
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            messages.append((url, completion))
            requestedURLCount.append(url)
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error)
        }
    }

}
