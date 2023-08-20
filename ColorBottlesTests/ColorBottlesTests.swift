//
//  ColorBottlesTests.swift
//  ColorBottlesTests
//
//  Created by Pavel Tsybulin on 14.08.2023.
//

import XCTest

final class ColorBottlesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testManagerLoadLevels() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
        let mgr = GameManager.shared
        
        mgr.loadLevels()
        
        for level in mgr.levels {
            var colors : [String : Int] = [:]
            for bottle in level.bottles {
                for block in bottle.blocks {
                    if let cnt = colors[block] {
                        colors[block] = cnt + 1
                    } else {
                        colors[block] = 1
                    }
                }
            }
            
            for (color, cnt) in colors {
                if cnt != 4 {
                    XCTAssertEqual(cnt, 4, "level \(level.id) \(color)")
                }
            }
        }
    }

}
