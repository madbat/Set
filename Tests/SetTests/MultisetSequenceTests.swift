//  Copyright (c) 2015 Rob Rix. All rights reserved.

import XCTest
import Set

final class MultisetSequenceTests: XCTestCase {
	func testIteratorProducesEveryElement() {
        XCTAssertEqual(Array(Multiset(0, 1, 2)).sorted(), [ 0, 1, 2 ])
	}

	func testIteratorProducesElementsByMultiplicity() {
		XCTAssertEqual(Multiset(1, 1, 1, 2, 2, 3).reduce(0, +), 10)
	}
}
