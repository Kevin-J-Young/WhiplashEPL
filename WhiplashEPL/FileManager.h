//
//  FileManager.h
//  WhiplashEPL
//
//  Created by Kevin Young on 9/2/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject {
    NSArray *_watchedFolders;
//    NSString *_logPath;
}

@property (nonatomic, strong) NSArray *watchedFolders;
//@property (nonatomic, strong) NSString *logPath;

+(FileManager*)sharedInstance;


-(void)savePreferences;
-(void)loadPreferences;
-(void)deletePreferences;
-(void)buildDefaultPreferences;

-(void)createLogfile;
-(void)writeToLog:(NSString*)line;

@end
