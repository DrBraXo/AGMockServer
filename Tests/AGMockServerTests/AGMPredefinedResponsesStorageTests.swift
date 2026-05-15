//
//  AGMPredefinedResponsesStorageTests.swift
//
//  Regression for the unsynchronized-storage race in
//  AGMPredefinedResponsesStorage that surfaced as flaky tests in projects
//  doing several concurrent URL requests against a single AGMockServer.
//

import XCTest
@testable import AGMockServer

final class AGMPredefinedResponsesStorageTests: XCTestCase {

    /// Hammers add/response/remove from many concurrent queues. Pre-fix the
    /// Swift runtime would fault on contended Array writes; this test serves
    /// as a regression guard for the NSLock-protected storage.
    func testConcurrentAddAndRemoveDoesNotCrash() {
        let storage = AGMPredefinedResponsesStorage()
        let iterations = 200

        let expectation = expectation(description: "concurrent storage access")
        expectation.expectedFulfillmentCount = iterations * 3

        let queue = DispatchQueue.global(qos: .userInitiated)
        let group = DispatchGroup()

        for index in 0..<iterations {
            let url = URL(string: "https://example.com/\(index)")!
            let response = AGMockServer.CustomResponse(data: Data("payload-\(index)".utf8), statusCode: 200)

            group.enter()
            queue.async {
                storage.addResponse(response, for: url)
                expectation.fulfill()
                group.leave()
            }
            group.enter()
            queue.async {
                _ = storage.response(for: url)
                expectation.fulfill()
                group.leave()
            }
            group.enter()
            queue.async {
                storage.removeResponse(for: url)
                expectation.fulfill()
                group.leave()
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
