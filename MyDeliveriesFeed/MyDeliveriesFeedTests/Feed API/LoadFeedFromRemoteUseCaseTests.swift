//
//  RemoteFeedLoaderTests.swift
//  MyDeliveriesFeedTests
//
//  Created by Ryan Neil Stroud on 23/3/2024.
//

import XCTest
import MyDeliveriesFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
  
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let item = makeItem(
            id: UUID(),
            remarks: "some remarks",
            goodsPicture: URL(string: "https://any-url.com")!,
            deliveryFee: 100.00,
            surcharge: 10.00,
            routeStart: "some starting address",
            routeEnd: "some ending address",
            senderPhone: "+852 5555 5555",
            senderName: "some sender name",
            senderEmail: "someSender@email.com",
            favorited: false)
                
        expect(sut, toCompleteWith: .success([item.model]), when: {
            let json = makeItemsJSON([item.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }

    
//    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
//        let (sut, client) = makeSUT()
//        
//        let item = makeItem(
//            id: UUID(),
//            remarks: "some remarks",
//            goodsPicture: URL(string: "https://any-url.com")!,
//            deliveryFee: "$100",
//            surcharge: "$10",
//            routeStart: "some starting address",
//            routeEnd: "some ending address",
//            senderPhone: "+852 5555 5555",
//            senderName: "some sender name",
//            senderEmail: "someSender@email.com")
//        
//        let invalidJSON = ["key" : "invalid data"]
//                
//        expect(sut, toCompleteWith: .success([item.model]), when: {
//            let json = makeItemsJSON([item.json, invalidJSON])
//            client.complete(withStatusCode: 200, data: json)
//        })
//    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
//        trackForMemoryLeaks(sut, file: file, line: line)
//        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        private(set) var cancelledURLs = [URL]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }

    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, remarks: String, goodsPicture: URL, deliveryFee: Decimal, surcharge: Decimal, routeStart: String, routeEnd: String, senderPhone: String, senderName: String, senderEmail: String, favorited: Bool) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            remarks: remarks,
            goodsPicture: goodsPicture,
            deliveryFee: deliveryFee,
            surcharge: surcharge,
            route: .init(
                start: routeStart,
                end: routeEnd),
            sender: .init(
                phone: senderPhone,
                name: senderName,
                email: senderEmail), 
            favorited: favorited)
        
        let json = [
            "id": id.uuidString,
            "remarks": remarks,
            "goodsPicture": goodsPicture.absoluteString,
            "deliveryFee": "$\(deliveryFee)",
            "surcharge": "$\(surcharge)",
            "route": [
                "start": routeStart,
                "end": routeEnd
            ],
            "sender": [
                "phone": senderPhone,
                "name": senderName,
                "email": senderEmail
            ]
        ] as [String : Any]
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: items)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
}


//final class RemoteFeedLoaderTests: XCTestCase {
//
//    func test_init_doesNotLoadOnCreation() {
//        let (_, client) = makeSUT()
//
//        XCTAssertTrue(client.requestedURLs.isEmpty)
//    }
//    
//    func test_load_requestsDataOnLoad() {
//        let url = URL(string: "https://a-given-url.com")!
//        let (sut, client) = makeSUT(url: url)
//        
//        sut.load { _ in }
//        
//        XCTAssertEqual(client.requestedURLs, [url])
//    }
//    
//    func test_loadTwice_requestsDataOnLoad() {
//        let url = URL(string: "https://a-given-url.com")!
//        let (sut, client) = makeSUT(url: url)
//        
//        sut.load { _ in }
//        sut.load { _ in }
//
//        XCTAssertEqual(client.requestedURLs, [url, url])
//    }
//    
//    func test_load_deliversErrorOnClientError() {
//        let (sut, client) = makeSUT()
//        
//        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity), when: {
//            let clientError = NSError(domain: "Test", code: 0)
//            client.complete(with: clientError)
//        })
//    }
//    
//    func test_load_deliversErrorOnNon200HTTPResponse() {
//        let (sut, client) = makeSUT()
//        
//        let samples = [199, 201, 300, 400, 500]
//        
//        samples.enumerated().forEach { index, code in
//            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData), when: {
//                client.complete(withStatusCode: code, at: index)
//            })
//        }
//    }
//    
//    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
//        let (sut, client) = makeSUT()
//        
//        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData), when: {
//            let invalidJSON = Data("invalid json".utf8)
//            client.complete(withStatusCode: 200, data: invalidJSON)
//        })
//    }
//    
//    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
//        let (sut, client) = makeSUT()
//        
//        expect(sut, toCompleteWith: .success([]), when: {
//            let emptyListJSON = makeItemsJSON([])
//            client.complete(withStatusCode: 200, data: emptyListJSON)
//        })
//    }
//    
//    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
//        let (sut, client) = makeSUT()
//        
//        let item = makeItem(
//            id: UUID(),
//            remarks: "some remarks",
//            goodsPicture: URL(string: "https://any-url.com")!,
//            deliveryFee: "$100",
//            surcharge: "$10",
//            routeStart: "some starting address",
//            routeEnd: "some ending address",
//            senderPhone: "+852 5555 5555",
//            senderName: "some sender name",
//            senderEmail: "someSender@email.com")
//        
//        let items = [item.model]
//        
//        expect(sut, toCompleteWith: .success(items), when: {
//            let json = makeItemsJSON([item.json])
//            client.complete(withStatusCode: 200, data: json)
//        })
//    }
//    
//    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
//        let url = URL(string: "http://any-url.com")!
//        let client = HTTPClientSpy()
//        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
//        
//        var capturedResults = [RemoteFeedLoader.Result]()
//        sut?.load { capturedResults.append($0) }
//        
//        sut = nil
//        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
//        
//        XCTAssertTrue(capturedResults.isEmpty)
//    }
//    
//    private func makeSUT(url: URL = URL(string: "https://any-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
//        let client = HTTPClientSpy()
//        let sut = RemoteFeedLoader(url: url, client: client)
//        
//        return (sut, client)
//    }
//    
//    private func makeItem(id: UUID, remarks: String, goodsPicture: URL, deliveryFee: String, surcharge: String, routeStart: String, routeEnd: String, senderPhone: String, senderName: String, senderEmail: String) -> (model: FeedItem, json: [String: Any]) {
//        let item = FeedItem(
//            id: id,
//            remarks: remarks,
//            goodsPicture: goodsPicture,
//            deliveryFee: deliveryFee,
//            surcharge: surcharge,
//            route: .init(
//                start: routeStart,
//                end: routeEnd),
//            sender: .init(
//                phone: senderPhone,
//                name: senderName,
//                email: senderEmail))
//        
//        let json = [
//            "id": id.uuidString,
//            "remarks": remarks,
//            "goodsPicture": goodsPicture.absoluteString,
//            "deliveryFee": deliveryFee,
//            "surcharge": surcharge,
//            "route": [
//                "start": routeStart,
//                "end": routeEnd
//            ],
//            "sender": [
//                "phone": senderPhone,
//                "name": senderName,
//                "email": senderEmail
//            ]
//        ] as [String : Any]
//        
//        return (item, json)
//    }
//    
//    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
//        try! JSONSerialization.data(withJSONObject: items)
//    }
//    
//    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
//        let exp = expectation(description: "Wait for load completion")
//        
//        sut.load { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedItems), .success(expectedItems)):
//                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
//                
//            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
//                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
//                
//            default:
//                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
//            }
//            
//            exp.fulfill()
//        }
//        
//        action()
//        
//        wait(for: [exp], timeout: 1.0)
//    }
//    
//    private class HTTPClientSpy: HTTPClient {
//        private(set) var requestedURLs = [URL]()
//        private(set) var completions = [(HTTPClient.Result) -> Void]()
//        
//        func complete(with error: Error, at index: Int = 0) {
//            completions[index](.failure(error))
//        }
//        
//        func complete(withStatusCode code: Int, data: Data = .init(), at index: Int = 0) {
//            let response = HTTPURLResponse(
//                url: requestedURLs[index],
//                statusCode: code,
//                httpVersion: nil,
//                headerFields: nil
//            )!
//            completions[index](.success((data, response)))
//        }
//        
//        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
//            completions.append(completion)
//            requestedURLs.append(url)
//        }
//    }
//}
