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
 * This container emulates the class-cluster that is `NSArray` and its mutable counterpart, `NSMutableArray`.
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
