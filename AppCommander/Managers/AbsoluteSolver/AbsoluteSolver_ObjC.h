//
//  AbsoluteSolver-ObjC.h
//  AppCommander
//
//  Created by Hariz Shirazi on 2023-04-08.
//


@interface AbsoluteSolver_ObjC : NSObject;
- (NSData *)readFromFileAtPath:(NSString *)filePath;
- (NSData *)readRawDataFromFileAtPath:(NSString *)filePath;
@end
