//
//  FSMatrix.m
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import "FSMatrix.h"

#import "FSMutableMatrix.h"
#import "__FSMatrixPrivate.h"

@implementation FSMatrixImpl

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    _rows = 0;
    _columns = 0;
    _data = [[NSArray alloc] init];
    
    return self;
}

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt
{
    return [self initWithRows:rows count:cnt lambda:FSNullInitializer];
}

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt lambda:(id(^)())defaultInitializer;
{
    self = [super init];
    if (!self) return nil;
    
    _rows = cnt;
    _columns = 0;
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:_rows];
    
    for (NSUInteger i=0;
         i<_rows;
         ++i)
        if ([rows[i] count]>_columns) _columns = [rows[i] count];
    
    for (NSUInteger i=0;
         i<_rows;
         ++i) {
        NSMutableArray* row = [rows[i] mutableCopy];
        for (NSUInteger j=[row count];
             j<_columns; // pad the array with
             ++j) // the default initalizer
            [row addObject:defaultInitializer()];
        [data addObject:[row copy]]; // immutable copy
    }
    
    _data = [data copy]; // immutable copy
    
    return self;
}

- (id)initWithLambda:(id(^)())defaultInitializer firstObject:(NSArray*)arr args:(va_list)args
{
    self = [super init];
    
    NSMutableArray* rows = [[NSMutableArray alloc] init];
    _columns = 0;
    
    for (NSArray* arg = arr;
         arg != nil;
         arg = va_arg(args, NSArray*)) {
        [rows addObject:[arg mutableCopy]];
        if ([arg count]>_columns) _columns = [arg count];
    }
    
    _rows = [rows count];
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:_rows];
    
    // ensure width of each row
    for (NSUInteger i=0;
         i<_rows;
         ++i) {
        NSMutableArray* row = [rows objectAtIndex:i];
        for (NSUInteger j=[row count];
             j<_columns;
             ++j)
            [row addObject:defaultInitializer()];
        [data addObject:[row copy]]; // immutable copy
    }
    
    _data = [data copy]; // immutable copy
    
    return self;
}

- (id)initWithRows:(NSArray*)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    self = [self initWithLambda:FSNullInitializer firstObject:firstObj args:args];
    va_end(args);
    return self;
}

- (id)initWithLambda:(id(^)())defaultInitializer rows:(NSArray*)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    self = [self initWithLambda:defaultInitializer firstObject:firstObj args:args];
    va_end(args);
    return self;
}

- (id)initWithMatrix:(FSMatrix*)matrix
{
    self = [super init];
    if (!self) return nil;
    
    if ([matrix class]==[FSMatrixImpl class]) {
        // optimized initializer
        FSMatrixImpl* _matrix = (FSMatrixImpl*)matrix;
        _rows = _matrix->_rows;
        _columns = _matrix->_columns;
        NSMutableArray* deepCopyArray = [[NSMutableArray alloc] initWithCapacity:[_matrix->_data count]];
        for (NSArray* row in _matrix->_data) [deepCopyArray addObject:[row copy]];
        _data = [deepCopyArray copy];
    } else if ([matrix class]==[FSMutableMatrix class]) {
        // optimized initalizer
        FSMutableMatrix* _matrix = (FSMutableMatrix*)matrix;
        _rows = [_matrix rows];
        _columns = [_matrix columns];
        NSMutableArray* deepCopyArray = [[NSMutableArray alloc] initWithCapacity:_rows];
        for (NSUInteger i=0;
             i<_rows;
             ++i)
            [deepCopyArray addObject:[[[_matrix data] objectAtIndex:i] copy]]; // immutable copy
        _data = [deepCopyArray copy]; // immutable copy
    } else {
        // iterate over the thing the slow way
        _rows = [matrix rows];
        _columns = [matrix columns];
        NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:_rows];
        for (NSUInteger i=0;
             i<_rows;
             ++i) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columns];
            for (NSUInteger j=0;
                 j<_columns;
                 ++j)
                [row addObject:[matrix objectAtRow:i column:j]];
            [data addObject:[row copy]]; // immutable copy
        }
        _data = [data copy]; // immutable copy
    }
    
    return self;
}

- (id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns lambda:(id(^)())defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rows = rows;
    _columns = columns;
    
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:rows];
    for (NSUInteger i=0;
         i<rows;
         ++i) {
        NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:columns];
        for (NSUInteger j=0;
             j<columns;
             ++j)
            [row addObject:defaultInitializer()];
        [data addObject:[row copy]];
    }
    
    _data = [data copy];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) return nil;
    
    if (![aDecoder allowsKeyedCoding])
        [NSException raise:kUnkeyedArchiveException format:kUnkeyedArchiveExceptionDetail];
    
    _rows = [aDecoder decodeInt64ForKey:@"_rows"];
    _columns = [aDecoder decodeInt64ForKey:@"_columns"];
    _data = [aDecoder decodeObjectForKey:@"_data"];
    
    return self;
}

- (NSUInteger)rows { return _rows; }
- (NSUInteger)columns { return _columns; }
- (NSArray*)data { return _data; }

- (id)objectAtRow:(NSUInteger)row column:(NSUInteger)column
{
    return [[_data objectAtIndex:row] objectAtIndex:column];
}

- (id)copy
{
    return [[FSMatrixImpl alloc] initWithMatrix:self];
}

- (id)copyWithZone:(NSZone*)zone
{   // zones are deprecated and are ignored by the runtime in general
    return [[FSMatrixImpl alloc] initWithMatrix:self];
}

- (id)mutableCopy
{
    return [[FSMutableMatrix alloc] initWithMatrix:self];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{   // zones are deprecated and are ignored by the runtime in general
    return [[FSMutableMatrix alloc] initWithMatrix:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (![aCoder allowsKeyedCoding])
        [NSException raise:kUnkeyedArchiveException format:kUnkeyedArchiveExceptionDetail];
    
    [aCoder encodeInt64:_rows forKey:@"_rows"];
    [aCoder encodeInt64:_columns forKey:@"_columns"];
    [aCoder encodeObject:_data forKey:@"_data"];
}

- (NSString*)description
{
    return [_data description];
}

@end

@implementation FSMatrix

+ (id)alloc
{
    if ([self isEqual:[FSMatrix class]])
        return [FSMatrixImpl alloc];
    else
        return [super alloc];
}

+ (id)allocWithZone:(NSZone*)zone
{
    if ([self isEqual:[FSMatrix class]])
        return [FSMatrixImpl allocWithZone:zone];
    else
        return [super allocWithZone:zone];
}

- (id)init 
{   // no ivars to do anything to
    return [super init];
}

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt lambda:(id(^)())defaultInitializer
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)initWithRows:(NSArray*)firstObj, ...
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)initWithLambda:(id(^)())defaultInitializer rows:(NSArray*)firstObj, ...
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
};

- (id)initWithMatrix:(FSMatrix*)matrix
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns lambda:(id(^)())defaultInitializer
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    [NSException raise:kVirtualCodingCalledException format:kVritualCodingCalledExceptionDetail];
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [NSException raise:kVirtualCodingCalledException format:kVritualCodingCalledExceptionDetail];
}

#pragma mark Virtual Methods

// Objective-C doesn't support pure-virtual methods, so these are just stubs which
// return dummy data; potentially put an NSAssert(YES==NO,@"virtual method called");
// or something similar in here.

- (NSUInteger)rows
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return 0;
}

- (NSUInteger)columns
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return 0;
}

- (id)objectAtRow:(NSUInteger)row column:(NSUInteger)column
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)copy
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)copyWithZone:(NSZone*)zone
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)mutableCopy
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (id)mutableCopyWithZone:(NSZone*)zone
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

@end
