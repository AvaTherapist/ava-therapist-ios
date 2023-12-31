//
//  AppDelegateTests.swift
//  UnitTests
//
//  Created by Cyrus Refahi on 10/6/23.
//  Copyright © 2020 Cyrus Refahi. All rights reserved.
//

import XCTest
import UIKit
@testable import AITherapist

final class AppDelegateTests: XCTestCase {

    func test_didFinishLaunching() {
        let sut = AppDelegate()
        let eventsHandler = MockedSystemEventsHandler(expected: [])
        sut.systemEventsHandler = eventsHandler
        _ = sut.application(UIApplication.shared, didFinishLaunchingWithOptions: [:])
        eventsHandler.verify()
    }
    
    func test_pushRegistration() {
        let sut = AppDelegate()
        let eventsHandler = MockedSystemEventsHandler(expected: [
            .pushRegistration, .pushRegistration
        ])
        sut.systemEventsHandler = eventsHandler
        sut.application(UIApplication.shared, didRegisterForRemoteNotificationsWithDeviceToken: Data())
        sut.application(UIApplication.shared, didFailToRegisterForRemoteNotificationsWithError: NSError.test)
        eventsHandler.verify()
    }
    
    func test_didRecevieRemoteNotification() {
        let sut = AppDelegate()
        let eventsHandler = MockedSystemEventsHandler(expected: [
            .recevieRemoteNotification
        ])
        sut.systemEventsHandler = eventsHandler
        sut.application(UIApplication.shared, didReceiveRemoteNotification: [:], fetchCompletionHandler: { _ in })
        eventsHandler.verify()
    }
    
    func test_systemEventsHandler() {
        let sut = AppDelegate()
        let handler = sut.systemEventsHandler
        XCTAssertTrue(handler is MainSystemEventsHandler)
    }
}
