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
        
        expect(sut, toCompleteWith: .failure(RemoteExerciseLoader.Error.connectivity)) {
            let error = NSError(domain: "Test", code: 0)
            client.complete(with: error)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteExerciseLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteExerciseLoader.Error.invalidData)) {
            let invalidJSON = Data("invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemOn200HTTPResponsWithEmpyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemWith200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            frontImage: URL(string: "http://a-url.com")!,
            title: "Ben",
            category: "Legs")
        
        let item2 = makeItem(
            id: UUID(),
            frontImage: URL(string: "http://aNother-url.com")!,
            title: "Bröst",
            category: "Överkropp")
        
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let json = makeItemsJSON(([item1.json, item2.json]))
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTHasBeenDealocated() {
        let url = URL(string: "http://aNother-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteExerciseLoader? = RemoteExerciseLoader(url: url, client: client)
        
        var capturedResult = [RemoteExerciseLoader.Result]()
        sut?.load() { capturedResult.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }

    //MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-given-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteExerciseLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteExerciseLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been dealocated, potentional memory leak", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID, frontImage: URL, title: String, category: String) -> (model: ExerciseItem, json: [String: Any]) {
        
        let item = ExerciseItem(id: id, frontImage: frontImage, title: title, category: category)
        
        let json = [
            "id": id.uuidString,
            "frontImage": frontImage.absoluteString,
            "title": title,
            "category": category
        ]
        return (item, json)
    }
    
    private func makeItemsJSON(_ item: [[String: Any]]) -> Data {
        let json = ["items": item]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func expect(_ sut: RemoteExerciseLoader, toCompleteWith expectedResult: RemoteExerciseLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for the result")
        
        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
                
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
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
        
        func complete(withStatusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: withStatusCode,
                httpVersion: nil,
                headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }

}
