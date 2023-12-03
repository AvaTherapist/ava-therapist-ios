//
//  HelpersTests.swift
//  UnitTests
//
//  Created by Cyrus Refahi on 27.04.2020.
//  Copyright © 2020 Cyrus Refahi. All rights reserved.
//

import XCTest
@testable import AITherapist

class HelpersTests: XCTestCase {

//    func test_localized_knownLocale() {
//        let sut = "Countries".localized(Locale(identifier: "fr"))
//        XCTAssertEqual(sut, "Des pays")
//    }
    
//    func test_localized_unknownLocale() {
//        let sut = "Countries".localized(Locale(identifier: "ch"))
//        XCTAssertEqual(sut, "Countries")
//    }
    
    func test_result_isSuccess() {
        let sut1 = Result<Void, Error>.success(())
        let sut2 = Result<Void, Error>.failure(NSError.test)
        XCTAssertTrue(sut1.isSuccess)
        XCTAssertFalse(sut2.isSuccess)
    }
}
