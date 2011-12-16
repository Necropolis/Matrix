//
//  FSMutableMatrix.h
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import "FSMatrix.h"

@interface FSMutableMatrix : FSMatrix

@property (copy) id(^defaultInitializer)();

- (void)setObject:(id)object forColumn:(NSUInteger)column row:(NSUInteger)row;

@end
