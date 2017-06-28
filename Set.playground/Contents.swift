//: Playground - noun: a place where people can play

import Cocoa
import Set

var str = "Hello, playground"

var multiset = Multiset<Int>()
for each in [1, 5, 2, 2] {
    multiset.insert(each)
}

print(multiset)

let seq: Set = [1, 2, 3, 4]

struct P<T: Hashable> {
    let seq: Set<T>
    init(_ sequence: Set<T>) {
        self.seq = sequence
    }
}

extension P {
    func transform<T>(el: T) -> String {
        return String(describing: el)
    }
}

extension P: CustomStringConvertible {
    var description: String {
        return seq.lazy.map(transform).joined(separator: ", ")
    }
}

P(seq)
