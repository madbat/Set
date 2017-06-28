//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// Hashes a sequence of `Hashable` elements.
extension Sequence where Iterator.Element: Hashable {
    /// Hashes using Bob Jenkins’ one-at-a-time hash.
    ///
    /// http://en.wikipedia.org/wiki/Jenkins_hash_function#one-at-a-time
    ///
    /// NB: Jenkins’ usage appears to have been string keys; the usage employed here seems similar but may have subtle differences which have yet to be discovered.
    public var hashValue: Int {
        var h = reduce(0) { into, each in
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
}
