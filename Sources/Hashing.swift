//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// Hashes a sequence of `Hashable` elements.
internal func hashValues<S: Sequence>(_ sequence: S) -> Int where S.Iterator.Element: Hashable {
	var h = sequence.reduce(0) { into, each in
		var h = into + each.hashValue
		h += (h << 10)
		h ^= (h >> 6)
		return h
	}
	h += (h << 3)
	h ^= (h >> 11)
	h += (h << 15)
	return h
}
