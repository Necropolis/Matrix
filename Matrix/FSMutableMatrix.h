//
//  FSMutableMatrix.h
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import "FSMatrix.h"

/**
 * Mutable variant of FSMatrix.
 *
 * Because this is mutable, you can set an object for any index at any time. Please be careful when doing so, because if you have a large matrix this can incur quite a lot of additions as the matrix mutates to ensure a constant column width! So in essence, if I do this:
 *
 *     FSMutableMatrix* mutableMatrix = [[FSMutableMatrix alloc] init];
 *     // mutableMatrix is now an empty matrix
 *     [mutableMatrix setObject:@"Hello, world!" forRow:3 column:3];
 *     // mutableMatrix now looks something like this:
 *     // NULL NULL NULL NULL
 *     // NULL NULL NULL NULL
 *     // NULL NULL NULL NULL
 *     // NULL NULL NULL "Hellow, world!"
 */
@interface FSMutableMatrix : FSMatrix

/**
 * Because you can change the size of the matrix dynamically, it's also nice to be able to change your mind about what kind of default object you want in there.
 */
@property (copy) FSMatrixInitializer defaultInitializer;

/**
 * Replaces an object. This will grow the matrix if necessary.
 */ 
- (void)setObject:(id)anObject atRowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)columnIndex;
- (void)insertObject:(id)anObject atRowIndex:(NSUInteger)rowIndex newRow:(BOOL)newRow columnIndex:(NSUInteger)columnIndex newColumn:(BOOL)newColumn;

- (void)growToRowCount:(NSUInteger)rowCount;
- (void)growToColumnCount:(NSUInteger)columnCount;

@end
