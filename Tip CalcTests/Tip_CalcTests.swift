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
        let responseData: [HistoryData] = [.init(date: .now, amount: 120, tipPercent: 10, perPerson: 60)]
        let viewModel = TipViewModel(requestService: MockURLSession(responseData: responseData))
        viewModel.getTipHistoryFromServer()
        waitUntil(viewModel.$history, equals: responseData)
        XCTAssertEqual(viewModel.history.count, 1)
    }
    
    func test_getTipHistoryData_badURL() {
        let responseData: [HistoryData] = []
        let viewModel = TipViewModel(baseStringURL: "", requestService: MockURLSession(responseData: responseData))
        viewModel.getTipHistoryFromServer()
        XCTAssertEqual(viewModel.history.count, 0)
    }
    
    func test_getTipHistory_failed_badRequest() {
        let viewModel = TipViewModel(
            requestService: MockURLSession<HistoryData>(
                httpURLResponse: .init(url: URL(string: "www.google.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
            )
        )
        viewModel.getTipHistoryFromServer()
        waitUntil(viewModel.$error, equals: .badRequest)
        XCTAssertEqual(viewModel.error, .badRequest)
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
