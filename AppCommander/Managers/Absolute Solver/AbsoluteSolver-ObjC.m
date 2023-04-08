//
//  AbsoluteSolver-ObjC.m
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-08.
//

#import <Foundation/Foundation.h>
#import "AbsoluteSolver-ObjC.h"

@implementation AbsoluteSolver_ObjC
- (NSString *)readFromFileAtPath:(NSString *)filePath {
    NSError *error = nil;
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error reading file: %@", error.localizedDescription];
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:errorMessage userInfo:nil];
    }
    
    return fileContent;
}
@end
