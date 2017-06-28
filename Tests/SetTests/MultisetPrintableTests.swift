//  Copyright (c) 2014 Rob Rix. All rights reserved.

import XCTest
import Set

final class TestElement: NSObject {

	// MARK: CustomStringConvertible
	
	override var description: String {
        return #function
	}
	
	// MARK: CustomDebugStringConvertible

	override var debugDescription: String {
        return #function
	}
}

final class MultisetPrintableTests: XCTestCase {
	func testDescription() {
		XCTAssertEqual(Multiset<Int>().description, "{}")
		XCTAssertEqual(Multiset(TestElement()).description, "{description}")
	}
	
	func testDebugDescription() {
		XCTAssertEqual(Multiset<Int>().debugDescription, "{}")
		XCTAssertEqual(Multiset(TestElement()).debugDescription, "{debugDescription}")
	}
	
}
