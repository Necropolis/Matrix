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
    
    _rows = 0;
    _columns = 0;
    
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
        _rows = [_matrix rows];
        _columns = [_matrix columns];
        _data = [[NSMutableArray alloc] initWithCapacity:_rows];
        for (NSArray* row in [_matrix data])
            [_data addObject:[row mutableCopy]];
        _defaultInitializer = FSNullInitializer;
    } else if ([matrix class]==[FSMutableMatrix class]) {
        // optimized initializer
        FSMutableMatrix* _matrix = (FSMutableMatrix*)matrix;
        _rows = _matrix->_rows;
        _columns = _matrix->_columns;
        _data = [[NSMutableArray alloc] initWithCapacity:_rows];
        for (NSUInteger i=0; // perform a
             i<_rows;        // deep copy
             ++i)
            [_data addObject:[[_matrix->_data objectAtIndex:i] mutableCopy]];
    } else {
        // really not optimized initializer
        _rows = [matrix rows];
        _columns = [matrix columns];
        _data = [[NSMutableArray alloc] initWithCapacity:_rows];
        for (NSUInteger i=0;
             i<_rows;
             ++i) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columns];
            for (NSUInteger j=0;
                 j<_columns;
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

- (id)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt lambda:(id(^)())defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rows = cnt;
    _columns = 0;
    _data = [[NSMutableArray alloc] initWithCapacity:_rows];
    
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
        [_data addObject:row]; // immutable copy
    }
    
    return self;
}

- (id)initWithLambda:(id (^)())defaultInitializer firstObject:(NSArray*)firstObject args:(va_list)args
{
    self = [super init];
    
    _data = [[NSMutableArray alloc] init];
    _columns = 0;
    
    for (NSArray* arg = firstObject;
         arg != nil;
         arg = va_arg(args, NSArray*)) {
        [_data addObject:[arg mutableCopy]];
        if ([arg count]>_columns) _columns = [arg count];
    }
    
    _rows = [_data count];
    
    // ensure width of each row
    for (NSUInteger i=0;
         i<_rows;
         ++i) {
        NSMutableArray* row = [_data objectAtIndex:i];
        for (NSUInteger j=[row count];
             j<_columns;
             ++j)
            [row addObject:defaultInitializer()];
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

- (id)initWithLambda:(id(^)())defaultInitializer rows:(NSArray*)firstObj, ...
{
    va_list args;
    va_start(args, firstObj);
    self = [self initWithLambda:defaultInitializer firstObject:firstObj args:args];
    va_end(args);
    
    return self;
}

- (id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns lambda:(id (^)())defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rows = rows;
    _columns = columns;
    
    _defaultInitializer = [defaultInitializer copy];
    
    _data = [[NSMutableArray alloc] initWithCapacity:rows];
    
    for (NSUInteger i=0;
         i<_rows;
         ++i) {
        NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columns];
        for (NSUInteger j=0;
             j<_columns;
             ++j)
            [row addObject:_defaultInitializer()];
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
    
    _rows = [aDecoder decodeInt64ForKey:@"_rows"];
    _columns = [aDecoder decodeInt64ForKey:@"_columns"];
    _data = [aDecoder decodeObjectForKey:@"_data"]; // yay for NSArray & friends doing all the work
    
    return self;
}

- (NSUInteger)rows { return _rows; }
- (NSUInteger)columns { return _columns; }
- (NSMutableArray*)data { return _data; }

- (id)objectAtRow:(NSUInteger)row column:(NSUInteger)column
{
    return [[_data objectAtIndex:row] objectAtIndex:column];
}

- (void)setObject:(id)object forRow:(NSUInteger)row column:(NSUInteger)column
{
    if (column>_columns || row>_rows)
        [self growToRows:MAX(row+1, _rows) columns:MAX(column+1, _columns)];
    [[_data objectAtIndex:row] replaceObjectAtIndex:column withObject:object];
}

- (void)growToRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    // Step 1: Add additional columns to all rows
    if (columns > _columns) {
        NSUInteger i=columns-_columns;
        for (NSUInteger j=0;
             j<_rows;
             ++j) {
            NSMutableArray* row = [_data objectAtIndex:j];
            for (NSUInteger k=0;
                 k<i;
                 ++k)
                [row addObject:_defaultInitializer()];
        }
        _columns = columns; // send KVO notes
    }
    // Step 2: Add additional rows
    if (rows > _rows) {
        NSUInteger i=rows-_rows;
        for (NSUInteger j=0;
             j<i;
             ++j) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columns];
            for (NSUInteger k=0;
                 k<_columns;
                 ++k)
                [row addObject:_defaultInitializer()];
            [_data addObject:row];
        }
        _rows = rows; // send KVO notes
    }
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

- (id)copy { return [[FSMatrixImpl alloc] initWithMatrix:self]; }
- (id)copyWithZone:(NSZone*)zone { return [[FSMatrixImpl alloc] initWithMatrix:self]; }
- (id)mutableCopy { return [[FSMutableMatrix alloc] initWithMatrix:self]; }
- (id)mutableCopyWithZone:(NSZone*)zone { return [[FSMutableMatrix alloc] initWithMatrix:self]; }

@end
