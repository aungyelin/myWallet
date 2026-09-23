//
//  myWalletUITests.swift
//  myWalletUITests
//
//  Created by Ye Lin Aung on 21/9/2569 BE.
//

import XCTest

final class myWalletUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
}
