//
//  String+NSRange.swift
//
//  CotEditor
//  https://coteditor.com
//
//  Created by 1024jp on 2016-06-25.
//
//  ---------------------------------------------------------------------------
//
//  © 2016-2018 1024jp
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

extension StringProtocol where Self.Index == String.Index {
    
    /// whole range in NSRange
    var nsRange: NSRange {
        
        return NSRange(self.startIndex..<self.endIndex, in: self)
    }
    
}



extension NSRange {
    
    static let notFound = NSRange(location: NSNotFound, length: 0)
}



extension NSString {
    
    var range: NSRange {
        
        return NSRange(location: 0, length: self.length)
    }
    
    
    /// Find and return ranges of passed-in substring with the given range of receiver.
    ///
    /// - Parameters:
    ///   - searchString: The string for which to search.
    ///   - options: A mask specifying search options.
    ///   - searchRange: The range with in the receiver for which to search for aString.
    /// - Returns: An array of NSRange in the receiver of `searchString` within `searchRange`.
    func ranges(of searchString: String, options: NSString.CompareOptions = .literal, range searchRange: NSRange? = nil) -> [NSRange] {
        
        let searchRange = searchRange ?? self.range
        var ranges = [NSRange]()
        
        var location = searchRange.location
        while location != NSNotFound {
            let range = self.range(of: searchString, options: options, range: NSRange(location..<searchRange.upperBound))
            location = range.upperBound
            
            guard range.location != NSNotFound else { break }
            
            ranges.append(range)
        }
        
        return ranges
    }
    
    
    /// line range containing a given location
    func lineRange(at location: Int) -> NSRange {
        
        return self.lineRange(for: NSRange(location: location, length: 0))
    }
    
    
    /// line range adding ability to exclude last line ending character if exists
    func lineRange(for range: NSRange, excludingLastLineEnding: Bool) -> NSRange {
        
        var lineRange = self.lineRange(for: range)
        
        guard excludingLastLineEnding else { return lineRange }
        
        // ignore last line ending
        if lineRange.length > 0, self.character(at: lineRange.upperBound - 1) == "\n".utf16.first! {
            lineRange.length -= 1
        }
        
        return lineRange
    }
    
    
    /// Calculate line-by-line ranges that given ranges include.
    ///
    /// - Parameters:
    ///   - ranges: Ranges to include.
    ///   - includingLastEmptyLine: Whether the last empty line sould be included; otherwise, return value can be empty.
    /// - Returns: Array of ranges of each indivisual line.
    func lineRanges(for ranges: [NSRange], includingLastEmptyLine: Bool = false) -> [NSRange] {
        
        guard !ranges.isEmpty else { return [] }
        
        if includingLastEmptyLine,
            ranges == [NSRange(location: self.length, length: 0)],
            (self.length == 0 || self.character(at: self.length - 1) == "\n".utf16.first!) {
            return ranges
        }
        
        var lineRanges = OrderedSet<NSRange>()
        
        // get line ranges to process
        for range in ranges {
            let linesRange = self.lineRange(for: range)
            
            // store each line to process
            self.enumerateSubstrings(in: linesRange, options: [.byLines, .substringNotRequired]) { (_, _, enclosingRange, _) in
                
                lineRanges.append(enclosingRange)
            }
        }
        
        return lineRanges.array
    }
    
}
