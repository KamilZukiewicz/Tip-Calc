//
//  Tip_CalcTests.swift
//  Tip CalcTests
//
//  Created by Kamil Żukiewicz on 08/10/2025.
//

import XCTest
import Combine
@testable import Tip_Calc

final class Tip_CalcTests: XCTestCase {
    
    func test_getTipHistoryData_Success() {
       
    }
    
    func test_getTipHistoryData_badURL() {
       
    }
    
    func test_getTipHistory_failed_badRequest() {
       
    }
}

extension XCTestCase {
    func waitUntil<T: Equatable>(
        _ propertyPublisher: Published<T>.Publisher,
        equals expectedValue: T,
        timeout: TimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let expectation = expectation(
            description: "Awaiting value \(expectedValue)"
        )
        
        var cancellable: AnyCancellable?

        cancellable = propertyPublisher
            .dropFirst()
            .first(where: { $0 == expectedValue })
            .sink { value in
                XCTAssertEqual(value, expectedValue, file: file, line: line)
                cancellable?.cancel()
                expectation.fulfill()
            }

        waitForExpectations(timeout: timeout, handler: nil)
    }
}
