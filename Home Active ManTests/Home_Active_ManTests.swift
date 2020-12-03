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
        
        expect(sut, toCompleteWith: .failure(.connectivity)) {
            let error = NSError(domain: "Test", code: 0)
            client.complete(with: error)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            
            expect(sut, toCompleteWith: .failure(.invalidData)) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData)) {
            let invalidJSON = Data("invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemOn200HTTPResponsWithEmpyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemWith200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = ExerciseItem(
            id: UUID(),
            frontImage: URL(string: "http://a-url.com")!,
            title: "Ben",
            category: "Legs")
        
        let item1JSON: [String : Any] = [
            "id": item1.id.uuidString,
            "frontImage": item1.frontImage.absoluteString,
            "title": item1.title,
            "category": item1.category
        ]
        let item2 = ExerciseItem(
            id: UUID(),
            frontImage: URL(string: "http://aNother-url.com")!,
            title: "Bröst",
            category: "Överkropp")
        
        let item2JSON: [String : Any] = [
            "id": item2.id.uuidString,
            "frontImage": item2.frontImage.absoluteString,
            "title": item2.title,
            "category": item2.category
        ]
        
        let itemJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            let json = try! JSONSerialization.data(withJSONObject: itemJSON)
            client.complete(withStatusCode: 200, data: json)
        }
    }

    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!) -> (sut: RemoteExerciseLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteExerciseLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteExerciseLoader, toCompleteWith result: RemoteExerciseLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var capturedResult = [RemoteExerciseLoader.Result]()
        sut.load() { capturedResult.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResult, [result], file: file, line: line)
    }
    
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
            
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: withStatusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }

}
