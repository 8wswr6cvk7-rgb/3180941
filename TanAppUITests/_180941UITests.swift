//
//  _180941UITests.swift
//  3180941UITests
//
//  Created by student01 on 2026/3/23.
//

import XCTest

final class _180941UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()

        let visitorRole = app.buttons["login.role.visitor"]
        let stallOwnerRole = app.buttons["login.role.stallOwner"]
        XCTAssertTrue(visitorRole.waitForExistence(timeout: 5))
        XCTAssertTrue(stallOwnerRole.exists)
        XCTAssertTrue(visitorRole.isHittable)
        XCTAssertTrue(stallOwnerRole.isHittable)
        XCTAssertLessThan(abs(visitorRole.frame.midY - stallOwnerRole.frame.midY), 4)

        let email = app.textFields["login.email"]
        XCTAssertTrue(email.waitForExistence(timeout: 5))
        email.tap()
        email.typeText("demo@tan.app")

        let password = app.secureTextFields["login.password"]
        password.tap()
        password.typeText("123456")

        let submit = app.buttons["login.submit"]
        XCTAssertTrue(submit.isEnabled)
        submit.tap()

        XCTAssertTrue(app.tabBars.buttons["发现"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["附近摊位与街巷记忆"].exists)

        let archiveName = app.staticTexts["张大爷糖油果子"].firstMatch
        XCTAssertTrue(archiveName.waitForExistence(timeout: 5))
        archiveName.tap()

        XCTAssertTrue(app.navigationBars["张大爷糖油果子"].waitForExistence(timeout: 5))
        let communityTitle = app.staticTexts["社区共建"]
        for _ in 0..<16 where !communityTitle.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(communityTitle.exists)

        let mapTab = app.tabBars.buttons["地图"]
        XCTAssertTrue(mapTab.exists)
        mapTab.tap()

        let xilianButton = app.buttons["打开昔涟记忆向导"]
        XCTAssertTrue(xilianButton.waitForExistence(timeout: 5))
        xilianButton.tap()

        let xilianInput = app.textFields["xilian.input"]
        XCTAssertTrue(xilianInput.waitForExistence(timeout: 5))
        xilianInput.tap()
        let chineseQuestion = "张大爷的故事是什么"
        xilianInput.typeText(chineseQuestion)
        XCTAssertEqual(xilianInput.value as? String, chineseQuestion)
        XCTAssertTrue(app.buttons["xilian.send"].isEnabled)
    }

    @MainActor
    func testArchiveBuilderShowsChineseDialectAndSpeechControls() throws {
        let app = XCUIApplication()
        app.launch()

        let stallOwnerRole = app.buttons["login.role.stallOwner"]
        XCTAssertTrue(stallOwnerRole.waitForExistence(timeout: 5))
        stallOwnerRole.tap()

        let email = app.textFields["login.email"]
        email.tap()
        email.typeText("owner@tan.app")

        let password = app.secureTextFields["login.password"]
        password.tap()
        password.typeText("123456")
        app.buttons["login.submit"].tap()

        XCTAssertTrue(app.tabBars.buttons["建档"].waitForExistence(timeout: 5))
        let dialectSelector = app.buttons["archive.dialect.selector"]
        let speechToggle = app.buttons["archive.speech.toggle"]
        XCTAssertTrue(dialectSelector.waitForExistence(timeout: 5))
        XCTAssertTrue(speechToggle.exists)
        XCTAssertTrue(speechToggle.isHittable)

        dialectSelector.tap()
        let zigongOption = app.buttons["自贡话"]
        XCTAssertTrue(zigongOption.waitForExistence(timeout: 3))
        zigongOption.tap()
        XCTAssertTrue(app.staticTexts["使用四川话识别能力"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["hand.thumbsup.fill"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
