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

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = 0;
    _columnCount = 0;
    
    _rows = [[NSMutableArray alloc] init];
    _defaultInitializer = FSNullInitializer;
    
    return self;
}

- (instancetype)initWithMatrix:(FSMatrix *)matrix
{
    self = [super init];
    if (!self) return nil;
    
    if ([matrix class]==[FSMatrixImpl class]) {
        // optimized initializer
        FSMatrixImpl* _matrix = (FSMatrixImpl*)matrix;
        _rowCount = [_matrix rowCount];
        _columnCount = [_matrix columnCount];
        _rows = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSArray* row in [_matrix rows])
            [_rows addObject:[row mutableCopy]];
        _defaultInitializer = FSNullInitializer;
    } else if ([matrix class]==[FSMutableMatrix class]) {
        // optimized initializer
        FSMutableMatrix* _matrix = (FSMutableMatrix*)matrix;
        _rowCount = _matrix->_rowCount;
        _columnCount = _matrix->_columnCount;
        _rows = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSUInteger i=0; // perform a
             i<_rowCount;        // deep copy
             ++i)
            [_rows addObject:[[_matrix->_rows objectAtIndex:i] mutableCopy]];
    } else {
        // really not optimized initializer
        _rowCount = [matrix rowCount];
        _columnCount = [matrix columnCount];
        _rows = [[NSMutableArray alloc] initWithCapacity:_rowCount];
        for (NSUInteger i=0;
             i<_rowCount;
             ++i) {
            NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columnCount];
            for (NSUInteger j=0;
                 j<_columnCount;
                 ++j)
                [row addObject:[matrix objectAtRowIndex:i columnIndex:j]];
            [_rows addObject:row];
        }
    }
    
    return self;
}

- (instancetype)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt
{
    return [self initWithRows:rows count:cnt initializer:FSNullInitializer];
}

- (instancetype)initWithRows:(const NSArray* [])rows count:(NSUInteger)cnt initializer:(FSMatrixInitializer)defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = cnt;
    _columnCount = 0;
    _rows = [[NSMutableArray alloc] initWithCapacity:_rowCount];
    
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
        [_rows addObject:row]; // immutable copy
    }
    
    return self;
}

- (instancetype)initWithInitializer:(FSMatrixInitializer)defaultInitializer firstObject:(NSArray*)firstObject args:(va_list)args
{
    self = [super init];
    
    _rows = [[NSMutableArray alloc] init];
    _columnCount = 0;
    
    for (NSArray* arg = firstObject;
         arg != nil;
         arg = va_arg(args, NSArray*)) {
        [_rows addObject:[arg mutableCopy]];
        if ([arg count]>_columnCount) _columnCount = [arg count];
    }
    
    _rowCount = [_rows count];
    
    // ensure width of each row
    for (NSUInteger i=0;
         i<_rowCount;
         ++i) {
        NSMutableArray* row = [_rows objectAtIndex:i];
        for (NSUInteger j=[row count];
             j<_columnCount;
             ++j)
            [row addObject:defaultInitializer(i, j)];
        // already in _rows, we just mutated it
    }
    
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

- (instancetype)initWithRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount initializer:(FSMatrixInitializer)defaultInitializer
{
    self = [super init];
    if (!self) return nil;
    
    _rowCount = rowCount;
    _columnCount = columnCount;
    
    _defaultInitializer = [defaultInitializer copy];
    
    _rows = [[NSMutableArray alloc] initWithCapacity:rowCount];
    
    for (NSUInteger i=0;
         i<_rowCount;
         ++i) {
        NSMutableArray* row = [[NSMutableArray alloc] initWithCapacity:_columnCount];
        for (NSUInteger j=0;
             j<_columnCount;
             ++j)
            [row addObject:_defaultInitializer(i, j)];
        [_rows addObject:row];
    }
    
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
    _rows = [aDecoder decodeObjectForKey:@"_rows"]; // yay for NSArray & friends doing all the work
    
    return self;
}

- (NSUInteger)rowCount { return _rowCount; }
- (NSUInteger)columnCount { return _columnCount; }
- (NSMutableArray*)rows { return _rows; }

- (instancetype)objectAtRowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)columnIndex
{
    return [[_rows objectAtIndex:rowIndex] objectAtIndex:columnIndex];
}

- (void)setObject:(id)anObject atRowIndex:(NSUInteger)rowIndex columnIndex:(NSUInteger)columnIndex
{
    if (columnIndex >= _columnCount)
        [self growToColumnCount:MAX(columnIndex+1, _columnCount)];
    
    if (rowIndex >= _rowCount)
        [self growToRowCount:MAX(rowIndex+1, _rowCount)];
    
    if (anObject == nil)
        anObject = _defaultInitializer(rowIndex, columnIndex);

    [[_rows objectAtIndex:rowIndex] replaceObjectAtIndex:columnIndex withObject:anObject];
}

- (void)insertObject:(id)anObject atRowIndex:(NSUInteger)rowIndex newRow:(BOOL)newRow columnIndex:(NSUInteger)columnIndex newColumn:(BOOL)newColumn;
{
    if (newRow) {
        [self insertRowAtIndex:rowIndex];
    }
    if (newColumn) {
        [self insertColumnAtIndex:columnIndex];
    }
    
    [self setObject:anObject atRowIndex:rowIndex columnIndex:columnIndex];
}

- (void)insertRowAtIndex:(NSUInteger)rowIndex;
{
    if (rowIndex >= _rowCount) {
        [self growToRowCount:rowIndex + 1];
    }
    else {
        NSMutableArray* newRow = [[NSMutableArray alloc] initWithCapacity:_columnCount];
        for (NSUInteger j=0;
             j<_columnCount;
             ++j)
            [newRow addObject:_defaultInitializer(rowIndex, j)];
        [_rows insertObject:newRow atIndex:rowIndex];
        
        _rowCount++;
    }
}

- (void)insertColumnAtIndex:(NSUInteger)columnIndex;
{
    if (columnIndex >= _columnCount) {
        [self growToColumnCount:columnIndex + 1];
    }
    else {
        NSUInteger i=0;
        for (NSMutableArray* row in _rows) {
            [row insertObject:_defaultInitializer(i, columnIndex) atIndex:columnIndex];
            i++;
        }
        
        _columnCount++;
    }
}

- (void)growToRowCount:(NSUInteger)rowCount;
{
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
            [_rows addObject:row];
        }
        _rowCount = rowCount; // send KVO notes
    }
}

- (void)growToColumnCount:(NSUInteger)columnCount;
{
    if (columnCount > _columnCount) {
        NSUInteger i=columnCount-_columnCount;
        for (NSUInteger j=0;
             j<_rowCount;
             ++j) {
            NSMutableArray* row = [_rows objectAtIndex:j];
            for (NSUInteger k=0;
                 k<i;
                 ++k)
                [row addObject:_defaultInitializer(j, k)];
        }
        _columnCount = columnCount; // send KVO notes
    }
}

- (void)growToRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount
{
    // Step 1: Add additional columns to all rows
    [self growToColumnCount:columnCount];

    // Step 2: Add additional rows
    [self growToRowCount:rowCount];
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

- (id)copy { return [[FSMatrixImpl alloc] initWithMatrix:self]; }
- (id)copyWithZone:(NSZone*)zone { return [[FSMatrixImpl alloc] initWithMatrix:self]; }
- (instancetype)mutableCopy { return [[FSMutableMatrix alloc] initWithMatrix:self]; }
- (instancetype)mutableCopyWithZone:(NSZone*)zone { return [[FSMutableMatrix alloc] initWithMatrix:self]; }

@end
