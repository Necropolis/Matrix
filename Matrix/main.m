//
//  main.m
//  Matrix
//
//  Created by Christopher Miller on 12/14/11.
//  Copyright (c) 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSMatrix.h"
#import "FSMutableMatrix.h"

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        FSMatrix* matrix = [[FSMatrix alloc] init];
        NSLog(@"Matrix: %@", matrix);
        
        FSMutableMatrix* mutableMatrix = [[FSMutableMatrix alloc] initWithRows:10 columns:10 lambda:NullInitializer];
        for (NSUInteger i=0; i<10; ++i)
            for (NSUInteger j=0; j<10; ++j)
                [mutableMatrix setObject:[NSString stringWithFormat:@"(%2lu,%2lu)", i,j] forRow:i column:j];
        NSLog(@"Mutable Matrix: %@", mutableMatrix);
        
        matrix = [mutableMatrix copy];
        
        NSLog(@"Matrix: %@", matrix);
        
        FSMatrix* deadFolks = [[FSMatrix alloc] initWithRows:
                               [NSArray arrayWithObjects:@"Franklin Roosevelt", @"Lyndon Johnson", @"Ronald Reagan", nil],
                               [NSArray arrayWithObjects:@"Josef Stalin", @"Vladimir Lenin", @"Leon Trotsky", nil],
                               nil,nil];
        
        NSLog(@"Dead folks: %@", deadFolks);
        
        FSMutableMatrix* mutationExample = [[FSMutableMatrix alloc] init];
        NSLog(@"Mutation Example: %@", mutationExample);
        
        [mutationExample setObject:@"Hello, world!" forRow:3 column:3];
        NSLog(@"Mutation Example: %@", mutationExample);
        
    }
    
    return 0;
}

