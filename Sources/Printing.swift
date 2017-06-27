//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// Describes a sequence as a set.
internal func describe<S: Sequence>(_ sequence: S) -> String {
	return mapDescription(sequence, transform: toString)
}

/// Debug-describes a sequence as a set.
internal func debugDescribe<S: Sequence>(_ sequence: S) -> String {
	return mapDescription(sequence, transform: toDebugString)
}

/// Maps the elements of `sequence` with `transform` and formats them as a set.
private func mapDescription<S: Sequence>(_ sequence: S, transform: (S.Iterator.Element) -> String) -> String {
	return wrapDescription(sequence.lazy.map(transform).joined(separator: ", "))
}

/// Wraps a string appropriately for formatting as a set.
private func wrapDescription(_ description: String) -> String {
	return description.isEmpty ?
		"{}"
	:	"{\(description)}"
}

// Returns the result of `print`ing x into a `String`
private func toString<T>(_ x: T) -> String {
	return String(describing: x)
}

// Returns the result of `debugPrint`ing x into a `String`
private func toDebugString<T>(_ x: T) -> String {
	return String(reflecting: x)
}
