//
//  Topical_DictionaryUITests.swift
//  Topical DictionaryUITests
//
//  Created by İbrahim Ethem Karalı on 14.08.2020.
//  Copyright © 2020 İbrahim Ethem Karalı. All rights reserved.
//

import XCTest

class Topical_DictionaryUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        snapshot("01LoginScreen")
        
        let button = app.buttons["Continue with E-mail"]
        if button.waitForExistence(timeout: 30) {
            button.tap()
        }
        
        let signUp = app.scrollViews.otherElements.buttons["Sign in"]
        if signUp.waitForExistence(timeout: 30) {
            signUp.tap()
        }
        
        let elementsQuery = XCUIApplication().scrollViews.otherElements
        
        let email = elementsQuery.textFields["Email"]
        email.tap()
        email.typeText(testEmail)
        
        let password = elementsQuery.secureTextFields["Password"]
        password.tap()
        password.typeText(testPassword)
        
        
        
        let signInButton = elementsQuery.buttons["Sign in with Email"]
        if signInButton.waitForExistence(timeout: 30) {
            signInButton.tap()
        }
        
        let app2 = XCUIApplication()

        let cell = app2.tables.cells.staticTexts["Cooking Instruction Dictionary"]
        
        if cell.waitForExistence(timeout: .init(30)) {
            snapshot("02HomeScreen")
            cell.tap()
        }
        snapshot("03DictionaryScreen")
        
        let tabbar = app2.tabBars["Tab Bar"]
        tabbar.children(matching: .button).element(boundBy: 2).tap()
        snapshot("04AccountScreen")
        
        let settings = app2.tables.cells.staticTexts["Settings"]
        if settings.waitForExistence(timeout: 10) {
            settings.tap()
        }
        
        let defaultSwitch = app2.tables.cells.switches["deviceDefaultSwitch"]
        
        if defaultSwitch.waitForExistence(timeout: 10) {
            defaultSwitch.swipeLeft()
        }
        
        let lightTheme = app2.tables.cells.staticTexts["Dark"]
        
        if lightTheme.waitForExistence(timeout: 10) {
            lightTheme.tap()
        }
        
        let accountTab = tabbar.children(matching: .button).element(boundBy: 0)
        accountTab.tap()
        accountTab.tap()
        
        snapshot("05DarkMode")
        
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
    
    override class func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
}
