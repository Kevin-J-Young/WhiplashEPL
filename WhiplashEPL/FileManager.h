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
}

@property (nonatomic, strong) NSArray *watchedFolders;

+(FileManager*)sharedInstance;


-(void)savePreferences;
-(void)loadPreferences;
-(void)deletePreferences;
-(void)buildDefaultPreferences;

@end
