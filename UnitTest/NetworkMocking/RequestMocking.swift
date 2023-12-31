//
//  RequestMocking.swift
//  CountriesSwiftUI
//
//  Created by Cyrus Refahi on 10/6/23.
//  Copyright © 2023 Cyrus Refahi. All rights reserved.
//
import Foundation
import Alamofire

extension URLSession {
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMocking.self, RequestBlocking.self]
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

// MARK: - RequestMocking

final class RequestMocking: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        return mock(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // swiftlint:disable identifier_name
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
    // swiftlint:enable identifier_name
        return false
    }

    override func startLoading() {
        if let mock = RequestMocking.mock(for: request),
            let url = request.url,
            let response = mock.customResponse ??
                HTTPURLResponse(url: url,
                statusCode: mock.httpCode,
                httpVersion: "HTTP/1.1",
                headerFields: mock.headers) {
            DispatchQueue.main.asyncAfter(deadline: .now() + mock.loadingTime) { [weak self] in
                guard let self = self else { return }
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                switch mock.result {
                case let .success(data):
                    self.client?.urlProtocol(self, didLoad: data)
                    self.client?.urlProtocolDidFinishLoading(self)
                case let .failure(error):
                    let failure = NSError(domain: NSURLErrorDomain, code: 1,
                                          userInfo: [NSUnderlyingErrorKey: error])
                    self.client?.urlProtocol(self, didFailWithError: failure)
                }
            }
        }
    }

    override func stopLoading() { }
}

// MARK: - RequestBlocking

private class RequestBlocking: URLProtocol {
    enum Error: Swift.Error {
        case requestBlocked
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        DispatchQueue(label: "").async {
            self.client?.urlProtocol(self, didFailWithError: Error.requestBlocked)
        }
    }
    override func stopLoading() { }
}


extension RequestMocking {
    static private var mocks: [MockedResponse] = []
    
    static func add(mock: MockedResponse) {
        mocks.append(mock)
    }
    
    static func removeAllMocks() {
        mocks.removeAll()
    }
    
    static private func mock(for request: URLRequest) -> MockedResponse? {
        return mocks.first { $0.url == request.url }
    }
}

extension RequestMocking {
    
    class MockInterceptor: RequestInterceptor {
        private var mocks: [MockedResponse] = []
        
        func add(mock: MockedResponse) {
            mocks.append(mock)
        }
        
        func removeAllMocks() {
            mocks.removeAll()
        }
        
        private func mock(for request: URLRequest) -> MockedResponse? {
            return mocks.first { $0.url == request.url }
        }
        
        func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
            if let mock = mock(for: urlRequest),
               let url = urlRequest.url,
               let response = mock.customResponse ??
                HTTPURLResponse(url: url,
                                statusCode: mock.httpCode,
                                httpVersion: "HTTP/1.1",
                                headerFields: mock.headers) {
                DispatchQueue.main.asyncAfter(deadline: .now() + mock.loadingTime) {
                    switch mock.result {
                    case let .success(data):
                        completion(.success(urlRequest))
                    case let .failure(error):
                        completion(.failure(error as! RequestMocking.Error))
                    }
                }
            } else {
                completion(.failure(Error.requestBlocked))
            }
        }
    }
    
    enum Error: Swift.Error {
        case requestBlocked
    }
}
