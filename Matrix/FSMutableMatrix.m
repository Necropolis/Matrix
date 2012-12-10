//
//  FSMutableMatrix.m
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import "FSMutableMatrix.h"
#import "__FSMatrixPrivate.h"

@implementation FSMutableMatrix

@synthesize defaultInitializer=_defaultInitializer;

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = 0;
    _columnCount = 0;
    
    _data = [[NSMutableArray alloc] init];
    _defaultInitializer = FSNullInitializer;
    
    return self;
}

- (id)initWithMatrix:(FSMatrix *)matrix
{
    self = [super init];
    if (!self) return nil;
    
    if ([matrix class]==[FSMatrixImpl class]) {
        // optimized initializer
        FSMatrixImpl* _matrix = (FSMatrixImpl*)matrix;
        _rowCount = [_matrix rowCount];
        _columnCount = [_matrix columnCount];
        _data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSArray* row in [_matrix data])
            [_data addObject:[row mutableCopy]];
        _defaultInitializer = FSNullInitializer;
    } else if ([matrix class]==[FSMutableMatrix class]) {
        // optimized initializer
        FSMutableMatrix* _matrix = (FSMutableMatrix*)matrix;
        _rowCount = _matrix->_rowCount;
        _columnCount = _matrix->_columnCount;
        _data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSUInteger i=0; // perform a
             i<_rowCount;        // deep copy
             ++i)
            [_data addObject:[[_matrix->_data objectAtIndex:i] mutableCopy]];
    } else {
        // really not optimized initializer
        _rowCount = [matrix rowCount];
        _columnCount = [matrix columnCount];
        _data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSUInteger i=0;
             i<_rowCount;
             ++i) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columnCount];
            for (NSUInteger j=0;
                 j<_columnCount;
                 ++j)
                [row addObject:[matrix objectAtRow:i column:j]];
            [_data addObject:row];
        }
    }
    
    return self;
}

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt
{
    return [self initWithRows:rows count:cnt lambda:FSNullInitializer];
}

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt lambda:(FSMatrixInitializer)defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = cnt;
    _columnCount = 0;
    _data = [[NSMutableArray alloc] initWithCapacity:_rowCount];
    
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
        [_data addObject:row]; // immutable copy
    }
    
    return self;
}

- (id)initWithLambda:(FSMatrixInitializer)defaultInitializer firstObject:(NSArray*)firstObject args:(va_list)args
{
    self = [super init];
    
    _data = [[NSMutableArray alloc] init];
    _columnCount = 0;
    
    for (NSArray* arg = firstObject;
         arg != nil;
         arg = va_arg(args, NSArray*)) {
        [_data addObject:[arg mutableCopy]];
        if ([arg count]>_columnCount) _columnCount = [arg count];
    }
    
    _rowCount = [_data count];
    
    // ensure width of each row
    for (NSUInteger i=0;
         i<_rowCount;
         ++i) {
        NSMutableArray* row = [_data objectAtIndex:i];
        for (NSUInteger j=[row count];
             j<_columnCount;
             ++j)
            [row addObject:defaultInitializer(i, j)];
        // already in _data, we just mutated it
    }
    
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

- (id)initWithLambda:(FSMatrixInitializer)defaultInitializer rows:(NSArray*)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    self = [self initWithLambda:defaultInitializer firstObject:firstObj args:args];
    va_end(args);
    
    return self;
}

- (id)initWithRows:(NSUInteger)rowCount columns:(NSUInteger)columnCount lambda:(FSMatrixInitializer)defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = rowCount;
    _columnCount = columnCount;
    
    _defaultInitializer = [defaultInitializer copy];
    
    _data = [[NSMutableArray alloc] initWithCapacity:rowCount];
    
    for (NSUInteger i=0;
         i<_rowCount;
         ++i) {
        NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columnCount];
        for (NSUInteger j=0;
             j<_columnCount;
             ++j)
            [row addObject:_defaultInitializer(i, j)];
        [_data addObject:row];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) return nil;
    
    if (![aDecoder allowsKeyedCoding])
        [NSException raise:kUnkeyedArchiveException format:kUnkeyedArchiveExceptionDetail];
    
    _rowCount = [aDecoder decodeInt64ForKey:@"_rowCount"];
    _columnCount = [aDecoder decodeInt64ForKey:@"_columnCount"];
    _data = [aDecoder decodeObjectForKey:@"_data"]; // yay for NSArray & friends doing all the work
    
    return self;
}

- (NSUInteger)rowCount { return _rowCount; }
- (NSUInteger)columnCount { return _columnCount; }
- (NSMutableArray*)data { return _data; }

- (id)objectAtRow:(NSUInteger)row column:(NSUInteger)column
{
    return [[_data objectAtIndex:row] objectAtIndex:column];
}

- (void)setObject:(id)object forRow:(NSUInteger)row column:(NSUInteger)column
{
    if (column>_columnCount || row>_rowCount)
        [self growToRows:MAX(row+1, _rowCount) columns:MAX(column+1, _columnCount)];
    [[_data objectAtIndex:row] replaceObjectAtIndex:column withObject:object];
}

- (void)growToRows:(NSUInteger)rowCount columns:(NSUInteger)columnCount
{
    // Step 1: Add additional columns to all rows
    if (columnCount > _columnCount) {
        NSUInteger i=columnCount-_columnCount;
        for (NSUInteger j=0;
             j<_rowCount;
             ++j) {
            NSMutableArray* row = [_data objectAtIndex:j];
            for (NSUInteger k=0;
                 k<i;
                 ++k)
                [row addObject:_defaultInitializer(j, k)];
        }
        _columnCount = columnCount; // send KVO notes
    }
    // Step 2: Add additional rows
    if (rowCount > _rowCount) {
        NSUInteger i=rowCount-_rowCount;
        for (NSUInteger j=0;
             j<i;
             ++j) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columnCount];
            for (NSUInteger k=0;
                 k<_columnCount;
                 ++k)
                [row addObject:_defaultInitializer(j, k)];
            [_data addObject:row];
        }
        _rowCount = rowCount; // send KVO notes
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    if (![aCoder allowsKeyedCoding])
        [NSException raise:kUnkeyedArchiveException format:kUnkeyedArchiveExceptionDetail];
    
    [aCoder encodeInt64:_rowCount forKey:@"_rowCount"];
    [aCoder encodeInt64:_columnCount forKey:@"_columnCount"];
    [aCoder encodeObject:_data forKey:@"_data"];
}

- (NSString*)description
{
    return [_data description];
}

- (id)copy { return [[FSMatrixImpl alloc] initWithMatrix:self]; }
- (id)copyWithZone:(NSZone*)zone { return [[FSMatrixImpl alloc] initWithMatrix:self]; }
- (id)mutableCopy { return [[FSMutableMatrix alloc] initWithMatrix:self]; }
- (id)mutableCopyWithZone:(NSZone*)zone { return [[FSMutableMatrix alloc] initWithMatrix:self]; }

@end
