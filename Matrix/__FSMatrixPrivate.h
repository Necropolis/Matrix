//
//  __FSMatrixPrivate.h
//  Matrix
//
//  Created by Christopher Miller on 12/15/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#ifndef __FSMatrixPrivate_h__
#define __FSMatrixPrivate_h__

#define kVirtualMethodCalledException @"Called a virtual method"
#define kVirtualMethodCalledExceptionDetail @"Son, I don't know how the Sam Hill you managed to mess up this much, but I'm willing to bet it was pretty awesome. Slap on the debugger and have yourself some fun, 'ya hear?"
#define kUnkeyedArchiveException @"Deprecated Stuff"
#define kUnkeyedArchiveExceptionDetail @"You seriously shouldn't be using unkeyed coding man. It's not cool."
#define kVirtualCodingCalledException @"What is this I don't even?"
#define kVritualCodingCalledExceptionDetail @"How did you even get this object, man? This is an imaginary pure-virtual class. I'm not sure how you managed to fail this bad, but simply bravo sir. Bravo."

@interface FSMatrix (InitializeAsObject)
- (id)initAsObject;
@end

@interface FSMatrixImpl : FSMatrix {
@private
    NSArray* _data;
    NSUInteger _rowCount;
    NSUInteger _columnCount;
}
- (NSArray*)data;
@end

@interface FSMutableMatrix () {
    NSMutableArray* _data;
    NSUInteger _rowCount;
    NSUInteger _columnCount;
}
- (NSMutableArray*)data;
- (void)growToRowCount:(NSUInteger)rowCount columnCount:(NSUInteger)columnCount;
@end

#endif
