//
//  FSMatrix.h
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^FSMatrixInitializer)(NSUInteger row, NSUInteger column);

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
 *     NSAssert([deadFolks objectForRow:0 column:2]==[NSNull null],
 *              @"Assertion Failure!"); // this will always be true,
 *     // so the assertion will never fail
 *
 * You can use the `lambda` parameter of some constructors to control what the matrix will be prepopulated with. For example, if I were building a video game and wanted an isometric map to hold all the actors, I'd want a matrix of `NSMutableSet` objects to hold everything. The best initializer to use in that situation is:
 *
 *     NSUInteger cols = ...; // hopefully you'll get these from
 *     NSUInteger rows = ...; // somewhere...
 *     FSMatrix* map =
 *       [[FSMatrix alloc]
 *         initWithRows:rows
 *              columns:cols
 *               lambda:id(^)(){
 *                 return [NSMutableSet setWithCapacity:10];
 *               }];
 *
 * Each and every value in the matrix is a mutable set, ready for action.
 *
 * This container emulates the class-cluster that is `NSArray`. There is no `FSMatrix` class that you will use; rather, you'll be using `FSMatrixImpl` (which is returned by calls to `alloc` on `FSMatrix`). `FSMatrixImpl` uses `NSArray` internally, whereas `FSMutableMatrix` uses `NSMutableArray`. When copying an `FSMutableMatrix` (not making a mutable copy!) the internal data structures are deep-copied to immutable variants.
 *
 * The entire project requires Apple LLVM 3.0 Automatic Reference Counting.
 */
@interface FSMatrix : NSObject <NSCopying, NSMutableCopying, NSCoding>

/**
 * Makes a new empty matrix. I'm not sure why you'd want an empty immutable matrix, but you can get one if you like.
 */
- (id)init;

/**
 * Same as a call to `initWithRows:count:lambda:` where lambda is `FSNullInitializer`.
 */
- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt;

/**
 * Creates a new matrix using a (c) array of arrays that is `count` long. `lambda` is used to initalize any potential missing columns in the arrays to an object of your choice.
 */
- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt lambda:(FSMatrixInitializer)defaultInitializer;

/**
 * Same as a call to `initWithLambda:rows:` where `lambda` is `FSNullInitializer`.
 */
- (id)initWithRows:(NSArray*)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Variadic variant of `initWithRows:count:lambda:`.
 */
- (id)initWithLambda:(FSMatrixInitializer)defaultInitializer rows:(NSArray*)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

/**
 * Copy constructor, ahoy!
 */
- (id)initWithMatrix:(FSMatrix*)matrix;

/**
 * Initialize a new matrix that is described by the given dimensions and initialize everything to the return type of `lambda`.
 */
- (id)initWithRows:(NSUInteger)rowCount columns:(NSUInteger)columnCount lambda:(FSMatrixInitializer)defaultInitializer;

/** The number of rows in this matrix. If this were a 2-d C array (or C++ vector) that would be the first array subscript: `vec[x]` */
- (NSUInteger)rowCount;

/** The number of columns in each row in the receiver. If this were a 2-d C array (or C++ vector) that would be the second array subscipt: `vec[x][y]` */
- (NSUInteger)columnCount;

/**
 * Returns the object at the given path in the receiver. Will throw an `NSArray` bounds exception if you screw up.
 */
- (id)objectAtRow:(NSUInteger)row column:(NSUInteger)column;

@end

/**
 * Returns `[NSNull null]` all the time. Kinda clever, ain't it?
 */
static
FSMatrixInitializer FSNullInitializer = ^(NSUInteger row, NSUInteger column){
    static NSNull* null;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ null = [NSNull null]; });
    return null;
};
