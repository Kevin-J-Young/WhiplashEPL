//
//  PrintManager.h
//  WhiplashEPL
//
//  Created by Kevin Young on 8/28/15.
//  Copyright (c) 2015 Whiplash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrintManager : NSObject

+(PrintManager*)sharedInstance;

-(NSArray*)printersAvailable;
-(void)sendFile:(NSString*)filePath toPrinter:(NSString*)printerName;

@end
