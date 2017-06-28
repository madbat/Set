//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// A multiset of elements and their counts.
public struct Multiset<Element: Hashable>: SetAlgebra, Collection, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
    public func index(after i: MultisetIndex<Element>) -> MultisetIndex<Element> {
        return i.successor()
    }
    
	// MARK: Constructors

	/// Constructs a `Multiset` with the elements of `sequence`.
	public init<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
		self.init(values: [:])
        extend(sequence)
	}

	/// Constructs a `Multiset` from a variadic parameter list.
	public init(_ elements: Element...) {
		self.init(elements)
	}

	/// Constructs the empty `Multiset`.
	public init() {
		self.init(values: [:])
	}

	/// Constructs an empty `Multiset` with a hint as to the capacity it should allocate.
	public init(minimumCapacity: Int) {
		self.init(values: [Element: Int](minimumCapacity: minimumCapacity))
	}


	// MARK: Properties

	/// The number of entries in the receiver.
	public var count: Int {
		return values.values.reduce(0, +)
	}

	/// The number of distinct entries in the receiver.
	public var countDistinct: Int {
		return values.count
	}

	/// True iff `count` is 0.
	public var isEmpty: Bool {
		return values.isEmpty
	}


	// MARK: Primitive operations

	/// True iff `element` is in the receiver, as defined by its hash and equality.
	public func contains(_ element: Element) -> Bool {
		return count(element) > 0
	}

	/// Returns the number of occurrences of `element` in the receiver.
	public func count(_ element: Element) -> Int {
		return values[element] ?? 0
	}

	/// Removes all elements from the receiver, optionally maintaining its capacity (defaulting to false).
	public mutating func removeAll(_ keepCapacity: Bool = false) {
		values.removeAll(keepingCapacity: keepCapacity)
	}


    // MARK: Algebraic operations

    /// Returns the union of the receiver and `set`.
    public func union(_ set: Multiset) -> Multiset {
        return self + set
    }

    /// Returns the intersection of the receiver and `set`.
    public func intersection(_ set: Multiset) -> Multiset {
        let smallerSet = countDistinct <= set.countDistinct ? set : self
        return Multiset(values: values.map { entry in
            (entry.key, Swift.min(entry.value, smallerSet.count(entry.key)))
        })
    }

    /// Returns the relative complement of `set` in `self`.
    ///
    /// This is a new set with all elements from the receiver which are not contained in `set`.
    public func complement(_ set: Multiset) -> Multiset {
        return Multiset(values: values.lazy.map { entry in
            (entry.key, entry.value - set.count(entry.key))
        })
    }


    // MARK: SetAlgebra

    public func symmetricDifference(_ other: Multiset<Element>) -> Multiset<Element> {
        return (other - self) + (self - other)
    }

    @discardableResult
    public mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        values[newMember] = (values[newMember] ?? 0) + 1
        return (inserted: true, memberAfterInsert: newMember)
    }

    @discardableResult
    public mutating func remove(_ member: Element) -> Element? {
        guard let value = values[member] else {
            return nil
        }
        if value > 1 {
            values[member] = value - 1
        } else {
            values.removeValue(forKey: member)
        }
        return member
    }

    @discardableResult
    public mutating func update(with newMember: Element) -> Element? {
        return insert(newMember).memberAfterInsert
    }

    public mutating func formUnion(_ other: Multiset<Element>) {
        self = union(other)
    }

    public mutating func formIntersection(_ other: Multiset<Element>) {
        self = intersection(other)
    }

    public mutating func formSymmetricDifference(_ other: Multiset<Element>) {
        self = symmetricDifference(other)
    }


	// MARK: Inclusion functions

	/// True iff the receiver is a subset of (is included in) `set`.
	public func subset(_ set: Multiset) -> Bool {
		return complement(set) == Multiset()
	}

	/// True iff the receiver is a subset of but not equal to `set`.
	public func strictSubset(_ set: Multiset) -> Bool {
		return subset(set) && self != set
	}

	/// True iff the receiver is a superset of (includes) `set`.
	public func superset(_ set: Multiset) -> Bool {
		return set.subset(self)
	}

	/// True iff the receiver is a superset of but not equal to `set`.
	public func strictSuperset(_ set: Multiset) -> Bool {
		return set.strictSubset(self)
	}


    // MARK: Extension functions

    /// Inserts each element of `sequence` into the receiver.
    public mutating func extend<S: Sequence>(_ sequence: S) where S.Iterator.Element == Element {
        for each in sequence {
            insert(each)
        }
    }

    /// Appends `element` onto the `Multiset`.
    public mutating func append(_ element: Element) {
        insert(element)
    }


	// MARK: Higher-order functions

	/// Returns a new set including only those elements `x` where `includeElement(x)` is true.
	public func filter(_ includeElement: (Element) -> Bool) -> Multiset {
		return Multiset(self.lazy.filter(includeElement))
	}

	/// Returns a new set with the result of applying `transform` to each element.
	public func map<Result>(_ transform: (Element) -> Result) -> Multiset<Result> {
		return flatMap { [transform($0)] }
	}

	/// Applies `transform` to each element and returns a new set which is the union of each resulting set.
	public func flatMap<Result, S: Sequence>(_ transform: (Element) -> S) -> Multiset<Result> where S.Iterator.Element == Result {
		return reduce([]) { $0 + transform($1) }
	}


	// MARK: ArrayLiteralConvertible

	public init(arrayLiteral elements: Element...) {
		self.init(elements)
	}


	// MARK: Sequence

	public typealias Iterator = AnyIterator<Element>

	public func makeIterator() -> Iterator {
		var iterator = values.makeIterator()
		let next = { iterator.next() }
		var current: (element: Element?, count: Int) = (nil, 0)
		return AnyIterator {
			while current.count <= 0 {
				if let (element, count) = next() {
					current = (element, count)
					break
				}
				else { return nil }
			}
			current.count -= 1
			return current.element
		}
	}


	// MARK: Collection

	public typealias Index = MultisetIndex<Element>

	public var startIndex: Index {
		return MultisetIndex(from: values.startIndex, delta: 0, max: count)
	}

	public var endIndex: Index {
		return MultisetIndex(from: values.endIndex, delta: 0, max: count)
	}

	public subscript(index: Index) -> Element {
		let (element, count) = values[index.from]
		if index.delta > (count - 1) {
			return self[MultisetIndex(from: values.index(after: index.from), delta: index.delta - count, max: self.count)]
		} else {
			return element
		}
	}


	// MARK: CustomStringConvertible

	public var description: String {
		return describe(self)
	}


	// MARK: CustomDebugStringConvertible

	public var debugDescription: String {
		return debugDescribe(self)
	}


	// MARK: Private

	/// Constructs a `Multiset` with a dictionary of `values`.
	fileprivate init(values: [Element: Int]) {
		self.values = values
	}

	/// Constructs a `Multiset` with a sequence of element/count pairs.
	fileprivate init<S: Sequence>(values: S) where S.Iterator.Element == Dictionary<Element, Int>.Element {
		self.values = [:]
		for (element, count) in values {
			if count > 0 { self.values[element] = count }
		}
	}

	/// Counts indexed by value.
	fileprivate var values: Dictionary<Element, Int>


    // MARK: Operators

    /// Returns a new set with all elements from `set` and `other`.
    public static func + <S: Sequence>(set: Multiset<Element>, other: S) -> Multiset<Element> where S.Iterator.Element == Element {
        var set = set
        for element in other {
            set.insert(element)
        }
        return set
    }

    /// Extends a `set` with the elements of a `sequence`.
    public static func += <S: Sequence>(set: inout Multiset<S.Iterator.Element>, sequence: S) {
        set.extend(sequence)
    }


    /// Returns a new set with all elements from `set` which are not contained in `other`.
    public static func - (set: Multiset<Element>, other: Multiset<Element>) -> Multiset<Element> {
        return set.complement(other)
    }

    /// Removes all elements in `other` from `set`.
    public static func -= (set: inout Multiset<Element>, other: Multiset<Element>) {
        set = set.complement(other)
    }


    /// Intersects with `set` with `other`.
    public static func &= (set: inout Multiset<Element>, other: Multiset<Element>) {
        set = set.intersection(other)
    }

    /// Returns the intersection of `set` and `other`.
    public static func & (set: Multiset<Element>, other: Multiset<Element>) -> Multiset<Element> {
        return set.intersection(other)
    }


    // Defines equality for multisets.
    public static func == (a: Multiset<Element>, b: Multiset<Element>) -> Bool {
        return a.values == b.values
    }
}


/// The index for values of a multiset.
public struct MultisetIndex<Element: Hashable>: Comparable {
	// MARK: ForwardIndexType

	public func successor() -> MultisetIndex {
		return MultisetIndex(from: from, delta: delta + 1, max: max)
	}


	// MARK: Private

	fileprivate let from: DictionaryIndex<Element, Int>
	fileprivate let delta: Int
	fileprivate let max: Int


    // MARK: Equatable

    public static func == (left: MultisetIndex<Element>, right: MultisetIndex<Element>) -> Bool {
        if left.from == right.from {
            return left.delta == right.delta && left.max == right.max
        } else {
            return left.max == right.max && abs(left.delta - right.delta) == left.max
        }
    }


    // MARK: Comparable

    public static func < (left: MultisetIndex<Element>, right: MultisetIndex<Element>) -> Bool {
        if left.from == right.from {
            return left.delta < right.delta
        } else if left.from < right.from {
            return (left.delta - right.delta) < left.max
        }
        return false
    }
}
