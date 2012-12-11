# Matrices for Cocoa

A quick two-dimensional matrix implementation for Cocoa.

Code speaks louder than words:

``` objective-c
FSMatrix* matrix = [[FSMatrix alloc] init];
NSLog(@"Matrix: %@", matrix);
/*
 * Matrix: (
 * )
 */

FSMutableMatrix* mutableMatrix = [[FSMutableMatrix alloc] initWithRowCount:10 columnCount:10 initializer:FSNullInitializer];
for (NSUInteger i=0; i<10; ++i)
  for (NSUInteger j=0; j<10; ++j)
    [mutableMatrix setObject:[NSString stringWithFormat:@"(%2lu,%2lu)", i,j] atRowIndex:i columnIndex:j];
NSLog(@"Mutable Matrix: %@", mutableMatrix);
/*
 * Mutable Matrix: (
 *         ( "( 0, 0)", "( 0, 1)", "( 0, 2)", "( 0, 3)", "( 0, 4)",
 *           "( 0, 5)", "( 0, 6)", "( 0, 7)", "( 0, 8)", "( 0, 9)"
 *     ),
 *         ( "( 1, 0)", "( 1, 1)", "( 1, 2)", "( 1, 3)", "( 1, 4)",
 *           "( 1, 5)", "( 1, 6)", "( 1, 7)", "( 1, 8)", "( 1, 9)"
 *     ),
 *         ( "( 2, 0)", "( 2, 1)", "( 2, 2)", "( 2, 3)", "( 2, 4)",
 *           "( 2, 5)", "( 2, 6)", "( 2, 7)", "( 2, 8)", "( 2, 9)"
 *     ),
 *         ( "( 3, 0)", "( 3, 1)", "( 3, 2)", "( 3, 3)", "( 3, 4)",
 *           "( 3, 5)", "( 3, 6)", "( 3, 7)", "( 3, 8)", "( 3, 9)"
 *     ),
 *         ( "( 4, 0)", "( 4, 1)", "( 4, 2)", "( 4, 3)", "( 4, 4)",
 *           "( 4, 5)", "( 4, 6)", "( 4, 7)", "( 4, 8)", "( 4, 9)"
 *     ),
 *         ( "( 5, 0)", "( 5, 1)", "( 5, 2)", "( 5, 3)", "( 5, 4)",
 *           "( 5, 5)", "( 5, 6)", "( 5, 7)", "( 5, 8)", "( 5, 9)"
 *     ),
 *         ( "( 6, 0)", "( 6, 1)", "( 6, 2)", "( 6, 3)", "( 6, 4)",
 *           "( 6, 5)", "( 6, 6)", "( 6, 7)", "( 6, 8)", "( 6, 9)"
 *     ),
 *         ( "( 7, 0)", "( 7, 1)", "( 7, 2)", "( 7, 3)", "( 7, 4)",
 *           "( 7, 5)", "( 7, 6)", "( 7, 7)", "( 7, 8)", "( 7, 9)"
 *     ),
 *         ( "( 8, 0)", "( 8, 1)", "( 8, 2)", "( 8, 3)", "( 8, 4)",
 *           "( 8, 5)", "( 8, 6)", "( 8, 7)", "( 8, 8)", "( 8, 9)"
 *     ),
 *         ( "( 9, 0)", "( 9, 1)", "( 9, 2)", "( 9, 3)", "( 9, 4)",
 *           "( 9, 5)", "( 9, 6)", "( 9, 7)", "( 9, 8)", "( 9, 9)"
 *     )
 * )
 */

matrix = [mutableMatrix copy];

NSLog(@"Matrix: %@", matrix);
/*
 * Really it's the same as the mutable matrix. Just trust me on this one. :)
 */

FSMatrix* deadFolks = [[FSMatrix alloc] initWithRows:
  [NSArray arrayWithObjects:
    @"Franklin Roosevelt",
	@"Lyndon Johnson",
	@"Ronald Reagan", nil],
  [NSArray arrayWithObjects:
    @"Josef Stalin",
	@"Vladimir Lenin",
	@"Leon Trotsky", nil],
  nil];

NSLog(@"Dead folks: %@", deadFolks);
/*
 * Dead folks: (
 *         (
 *         "Franklin Roosevelt",
 *         "Lyndon Johnson",
 *         "Ronald Reagan"
 *     ),
 *         (
 *         "Josef Stalin",
 *         "Vladimir Lenin",
 *         "Leon Trotsky"
 *     )
 * )
*/
```