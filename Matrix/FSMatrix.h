//
//  FSMatrix.h
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Simple two-dimensional container utilizing `NSArray` under the hood.
 * 
 * `FSMatrix` differs from a standard two-dimensional array graph because it enforces a constant row-width. Every row is guaranteed to have as many columns as the longest row. So for the following `FSMatrix` the assertion is true:
 *
 *     FSMatrix* deadFolks = [[FSMatrix alloc] initWithRows:
 *       [NSArray arrayWithObjects:
 *         @"Franklin Roosevelt",
 *         @"Lyndon Johnson", nil],
 *       [NSArray arrayWithObjects:
 *         @"Josef Stalin",
 *         @"Leon Trotsky",
 *         @"Vladimir Lenin", nil],
 *       nil];
 *     NSAssert([deadFolks objectForColumn:2 row:0]==[NSNull null],
 *              @"Assertion Failure!"); // this will always be true,
 *     // so the assertion will never fail
 *
 * You can use the `lambda` parameter of some construtors to control what the matrix will be prepopulated with. For example, if I were building a video game and wanted an isometric map to hold all the actors, I'd want a matrix of `NSMutableSet` objects to hold everything. The best initializer to use in that situation is:
 *
 *     NSUInteger cols = ...; // hopefully you'll get these from
 *     NSUInteger rows = ...; // somewhere...
 *     FSMatrix* map =
 *       [[FSMatrix alloc]
 *         initWithColumns:cols
 *                    rows:rows
 *                  lambda:id(^)(){
 *                    return [NSMutableSet setWithCapacity:10];
 *                   }];
 *
 * Each and every value in the matrix is a mutable set, ready for action.
 *
 * This container emulates the class-cluster that is `NSArray`. There is no `FSMatrix` class that you will use; rather, you'll be using `FSMatrixImpl` (which is returned by calls to `alloc` on `FSMatrix`). `FSMatrixImpl` uses `NSArray` internally, whereas `FSMutableMatrix` uses `NSMutableArray`. When copying an `FSMutableMatrix` (not making a mutable copy!) the internal data structures are deep-copied to immutable variants.
 *
 * The entire project requires Apple LLVM 3.0 Automatic Reference Counting.
 */
@interface FSMatrix : NSObject <NSCopying, NSMutableCopying, NSCoding>

- (id)init;
- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt;
- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt lambda:(id(^)())defaultInitializer;
- (id)initWithRows:(NSArray*)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithLambda:(id(^)())defaultInitializer rows:(NSArray*)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithMatrix:(FSMatrix*)matrix;
- (id)initWithColumns:(NSUInteger)columns rows:(NSUInteger)rows lambda:(id(^)())defaultInitializer;

- (NSUInteger)rows;
- (NSUInteger)columns;

- (id)objectForColumn:(NSUInteger)column row:(NSUInteger)row;

@end

static
id(^NullInitializer)() = (id)^{
    static NSNull* null;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ null = [NSNull null]; });
    return null;
};
