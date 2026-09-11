/*
 ShiftIt: Window Organizer for OSX
 Copyright (c) 2010-2011 Filip Krikava

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.

 */

#import <XCTest/XCTest.h>
#import "SIAdjacentRectangles.h"

@interface SIAdjacentRectanglesTests : XCTestCase
@end

@implementation SIAdjacentRectanglesTests

- (void)testDirectionalPathVisitsAllRectangles {
    NSRect a = NSMakeRect(5, 5, 5, 5);
    NSRect b = NSMakeRect(11, 6, 3, 3);
    NSRect c = NSMakeRect(11, 15, 3, 3);
    NSRect d = NSMakeRect(14, 11, 3, 3);
    NSRect e = NSMakeRect(14, 6, 3, 3);
    NSRect f = NSMakeRect(6, 13, 3, 3);
    NSRect g = NSMakeRect(2, 13, 3, 3);
    NSRect h = NSMakeRect(4, 17, 3, 3);
    NSRect i = NSMakeRect(1, 8, 3, 3);
    NSRect j = NSMakeRect(1, 4, 3, 3);
    NSRect k = NSMakeRect(6, 1, 3, 3);

    NSArray *rectValues = @[
        [SIValueRect rect:a withValue:@"A"],
        [SIValueRect rect:b withValue:@"B"],
        [SIValueRect rect:c withValue:@"C"],
        [SIValueRect rect:d withValue:@"D"],
        [SIValueRect rect:e withValue:@"E"],
        [SIValueRect rect:f withValue:@"F"],
        [SIValueRect rect:g withValue:@"G"],
        [SIValueRect rect:h withValue:@"H"],
        [SIValueRect rect:i withValue:@"I"],
        [SIValueRect rect:j withValue:@"J"],
        [SIValueRect rect:k withValue:@"K"],
    ];

    SIAdjacentRectangles *adjr = [SIAdjacentRectangles adjacentRect:rectValues];
    FMTDirection directions[] = {kRightDirection, kBottomDirection, kLeftDirection, kTopDirection};
    NSArray *path = [adjr buildDirectionalPath:directions fromValue:@"A"];

    // every rectangle is in some direction from A, and the path ends with A itself
    XCTAssertEqual((NSUInteger) 11, [path count]);
    XCTAssertEqualObjects(@"A", [path lastObject]);
}

- (void)testRectanglesInDirection {
    NSRect a = NSMakeRect(5, 5, 5, 5);
    NSRect b = NSMakeRect(11, 6, 3, 3);

    NSArray *rectValues = @[
        [SIValueRect rect:a withValue:@"A"],
        [SIValueRect rect:b withValue:@"B"],
    ];

    SIAdjacentRectangles *adjr = [SIAdjacentRectangles adjacentRect:rectValues];

    // B starts right of the right edge of A
    NSArray *right = [adjr rectanglesInDirection:kRightDirection fromValue:@"A"];
    XCTAssertEqual((NSUInteger) 1, [right count]);
    XCTAssertEqualObjects(@"B", [(SIDistanceValueRect *) right[0] value]);
    XCTAssertEqualWithAccuracy(1.0, [(SIDistanceValueRect *) right[0] distance], 0.001);

    XCTAssertEqual((NSUInteger) 0, [[adjr rectanglesInDirection:kLeftDirection fromValue:@"A"] count]);
    XCTAssertEqual((NSUInteger) 0, [[adjr rectanglesInDirection:kTopDirection fromValue:@"A"] count]);
    XCTAssertEqual((NSUInteger) 0, [[adjr rectanglesInDirection:kBottomDirection fromValue:@"A"] count]);

    FMTDirection directions[] = {kRightDirection, kBottomDirection, kLeftDirection, kTopDirection};
    XCTAssertEqualObjects((@[@"B", @"A"]), [adjr buildDirectionalPath:directions fromValue:@"A"]);
}

@end
