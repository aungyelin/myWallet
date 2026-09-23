//
//  ThemeManagerTests.swift
//  myWalletTests
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import XCTest
@testable import myWallet

@MainActor
final class ThemeManagerTests: XCTestCase {
    
    private var testDefaults: UserDefaults!
    private var testSuiteName: String!
    
    override func setUp() {
        super.setUp()
        testSuiteName = "ThemeManagerTests_\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: testSuiteName)
    }
    
    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        testDefaults = nil
        super.tearDown()
    }
    
    func test_initialState_defaultsToSystemWhenStorageEmpty() {
        let sut = ThemeManager(defaults: testDefaults)
        
        XCTAssertEqual(sut.currentTheme, .system)
    }
    
    func test_initialState_loadsPersistedThemeFromStorage() {
        testDefaults.set(AppTheme.dark.rawValue, forKey: "app_theme")
        
        let sut = ThemeManager(defaults: testDefaults)
        
        XCTAssertEqual(sut.currentTheme, .dark)
    }
    
    func test_setTheme_updatesCurrentThemeSynchronously() {
        let sut = ThemeManager(defaults: testDefaults)
        XCTAssertEqual(sut.currentTheme, .system)
        
        sut.setTheme(.dark)
        
        XCTAssertEqual(sut.currentTheme, .dark)
        XCTAssertEqual(testDefaults.string(forKey: "app_theme"), AppTheme.dark.rawValue)
    }
    
    func test_setTheme_transitionsBetweenMultipleThemesDeterministically() {
        let sut = ThemeManager(defaults: testDefaults)
        
        // 1st attempt: system -> dark
        sut.setTheme(.dark)
        XCTAssertEqual(sut.currentTheme, .dark)
        XCTAssertEqual(testDefaults.string(forKey: "app_theme"), AppTheme.dark.rawValue)
        
        // 2nd attempt: dark -> light (the reported bug scenario)
        sut.setTheme(.light)
        XCTAssertEqual(sut.currentTheme, .light)
        XCTAssertEqual(testDefaults.string(forKey: "app_theme"), AppTheme.light.rawValue)
        
        // 3rd attempt: light -> system
        sut.setTheme(.system)
        XCTAssertEqual(sut.currentTheme, .system)
        XCTAssertEqual(testDefaults.string(forKey: "app_theme"), AppTheme.system.rawValue)
    }
    
    func test_setTheme_ignoresRedundantCalls() {
        let sut = ThemeManager(defaults: testDefaults)
        sut.setTheme(.dark)
        
        // Setting .dark again should be a no-op
        sut.setTheme(.dark)
        XCTAssertEqual(sut.currentTheme, .dark)
    }
    
    func test_appContainer_exposesThemeManager() throws {
        let container = try AppContainer.createInMemory()
        
        XCTAssertNotNil(container.themeManager)
    }
    
}
