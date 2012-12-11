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

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = 0;
    _columnCount = 0;
    _rows = [[NSArray alloc] init];
    
    return self;
}

- (instancetype)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt
{
    return [self initWithRows:rows count:cnt initializer:FSNullInitializer];
}

- (instancetype)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt initializer:(FSMatrixInitializer)defaultInitializer;
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = cnt;
    _columnCount = 0;
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
    
    for (NSUInteger i=0;
         i<_rowCount;
         ++i)
        if ([rows[i] count]>_columnCount) _columnCount = [rows[i] count];
    
    for (NSUInteger i=0;
         i<_rowCount;
         ++i) {
        NSMutableArray* row = [rows[i] mutableCopy];
        for (NSUInteger j=[row count];
             j<_columnCount; // pad the array with
             ++j) // the default initalizer
            [row addObject:defaultInitializer(i, j)];
        [data addObject:[row copy]]; // immutable copy
    }
    
    _rows = [data copy]; // immutable copy
    
    return self;
}

- (instancetype)initWithInitializer:(FSMatrixInitializer)defaultInitializer firstObject:(NSArray*)arr args:(va_list)args
{
    self = [super init];
    
    NSMutableArray* rows = [[NSMutableArray alloc] init];
    _columnCount = 0;
    
    for (NSArray* arg = arr;
         arg != nil;
         arg = va_arg(args, NSArray*)) {
        [rows addObject:[arg mutableCopy]];
        if ([arg count]>_columnCount) _columnCount = [arg count];
    }
    
    _rowCount = [rows count];
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
    
    // ensure width of each row
    for (NSUInteger i=0;
         i<_rowCount;
         ++i) {
        NSMutableArray* row = [rows objectAtIndex:i];
        for (NSUInteger j=[row count];
             j<_columnCount;
             ++j)
            [row addObject:defaultInitializer(i, j)];
        [data addObject:[row copy]]; // immutable copy
    }
    
    _rows = [data copy]; // immutable copy
    
    return self;
}

- (instancetype)initWithRows:(NSArray*)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    self = [self initWithInitializer:FSNullInitializer firstObject:firstObj args:args];
    va_end(args);
    return self;
}

- (instancetype)initWithInitializer:(FSMatrixInitializer)defaultInitializer rows:(NSArray*)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    self = [self initWithInitializer:defaultInitializer firstObject:firstObj args:args];
    va_end(args);
    return self;
}

- (instancetype)initWithMatrix:(FSMatrix*)matrix
{
    self = [super init];
    if (!self) return nil;
    
    if ([matrix class]==[FSMatrixImpl class]) {
        // optimized initializer
        FSMatrixImpl* _matrix = (FSMatrixImpl*)matrix;
        _rowCount = _matrix->_rowCount;
        _columnCount = _matrix->_columnCount;
        NSMutableArray* deepCopyArray = [[NSMutableArray alloc] initWithCapacity:[_matrix->_rows count]];
        for (NSArray* row in _matrix->_rows) [deepCopyArray addObject:[row copy]];
        _rows = [deepCopyArray copy];
    } else if ([matrix class]==[FSMutableMatrix class]) {
        // optimized initalizer
        FSMutableMatrix* _matrix = (FSMutableMatrix*)matrix;
        _rowCount = [_matrix rowCount];
        _columnCount = [_matrix columnCount];
        NSMutableArray* deepCopyArray = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSUInteger i=0;
             i<_rowCount;
             ++i)
            [deepCopyArray addObject:[[[_matrix rows] objectAtIndex:i] copy]]; // immutable copy
        _rows = [deepCopyArray copy]; // immutable copy
    } else {
        // iterate over the thing the slow way
        _rowCount = [matrix rowCount];
        _columnCount = [matrix columnCount];
        NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSUInteger i=0;
             i<_rowCount;
             ++i) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columnCount];
            for (NSUInteger j=0;
                 j<_columnCount;
                 ++j)
                [row addObject:[matrix objectAtRowIndex:i columnIndex:j]];
            [data addObject:[row copy]]; // immutable copy
        }
        _rows = [data copy]; // immutable copy
    }
    
    return self;
}

- (instancetype)initWithRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount initializer:(FSMatrixInitializer)defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = rowCount;
    _columnCount = columnCount;
    
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:rowCount];
    for (NSUInteger i=0;
         i<rowCount;
         ++i) {
        NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for (NSUInteger j=0;
             j<columnCount;
             ++j)
            [row addObject:defaultInitializer(i, j)];
        [data addObject:[row copy]];
    }
    
    _rows = [data copy];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) return nil;
    
    if (![aDecoder allowsKeyedCoding])
        [NSException raise:kUnkeyedArchiveException format:kUnkeyedArchiveExceptionDetail];
    
    _rowCount = [aDecoder decodeInt64ForKey:@"_rowCount"];
    _columnCount = [aDecoder decodeInt64ForKey:@"_columnCount"];
    _rows = [aDecoder decodeObjectForKey:@"_rows"];
    
    return self;
}

- (NSUInteger)rowCount { return _rowCount; }
- (NSUInteger)columnCount { return _columnCount; }
- (NSArray*)rows { return _rows; }

- (instancetype)objectAtRowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)columnIndex
{
    return [[_rows objectAtIndex:rowIndex] objectAtIndex:columnIndex];
}

- (instancetype)copy
{
    return [[FSMatrixImpl alloc] initWithMatrix:self];
}

- (instancetype)copyWithZone:(NSZone*)zone
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
    
    [aCoder encodeInt64:_rowCount forKey:@"_rowCount"];
    [aCoder encodeInt64:_columnCount forKey:@"_columnCount"];
    [aCoder encodeObject:_rows forKey:@"_rows"];
}

- (NSString*)description
{
    return [_rows description];
}

@end

@implementation FSMatrix

+ (instancetype)alloc
{
    if ([self isEqual:[FSMatrix class]])
        return [FSMatrixImpl alloc];
    else
        return [super alloc];
}

+ (instancetype)allocWithZone:(NSZone*)zone
{
    if ([self isEqual:[FSMatrix class]])
        return [FSMatrixImpl allocWithZone:zone];
    else
        return [super allocWithZone:zone];
}

- (instancetype)init 
{   // no ivars to do anything to
    return [super init];
}

- (instancetype)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt initializer:(FSMatrixInitializer)defaultInitializer
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)initWithRows:(NSArray*)firstObj, ...
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)initWithInitializer:(FSMatrixInitializer)defaultInitializer rows:(NSArray*)firstObj, ...
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
};

- (instancetype)initWithMatrix:(FSMatrix*)matrix
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)initWithRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount initializer:(FSMatrixInitializer)defaultInitializer
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
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

- (NSUInteger)rowCount
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return 0;
}

- (NSUInteger)columnCount
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return 0;
}

- (NSArray *)rows
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)objectAtRowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)column
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)copy
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)copyWithZone:(NSZone*)zone
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)mutableCopy
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

- (instancetype)mutableCopyWithZone:(NSZone*)zone
{
    [NSException raise:kVirtualMethodCalledException format:kVirtualMethodCalledExceptionDetail];
    return nil;
}

@end
