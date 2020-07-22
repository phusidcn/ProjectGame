//
//  GameTests.swift
//  GameTests
//
//  Created by Huynh Lam Phu Si on 7/22/20.
//  Copyright © 2020 Huynh Lam Phu Si. All rights reserved.
//

import XCTest
import DemoObjectDetection

class GameTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveGame() throws {
        GameStorage.sharedInstance.saveGame()
        GameStorage.sharedInstance.loadGame()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
