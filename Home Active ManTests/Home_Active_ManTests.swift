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
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_init_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_init_requestDataTwiceFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in}
        sut.load {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteExerciseLoader.Error]()
        sut.load() { capturedError.append($0) }
        
        let error = NSError(domain: "Test", code: 0)
        client.complete(with: error)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteExerciseLoader.Error]()
        sut.load() { capturedError.append($0) }
        
        client.complete(withStatusCode: 400)
        
        XCTAssertEqual(capturedError, [.invalidData])
    }

    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteExerciseLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteExerciseLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
            
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode: Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: 400,
                httpVersion: nil,
                headerFields: nil)
            messages[index].completion(nil, response)
        }
    }

}
