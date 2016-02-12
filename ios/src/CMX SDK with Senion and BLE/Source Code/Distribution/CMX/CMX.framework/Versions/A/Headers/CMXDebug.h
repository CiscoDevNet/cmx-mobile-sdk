//
//  CMXDebug.h
//  CMX
//
//  Copyright (c) 2013 Cisco. All rights reserved.
//

#import <Foundation/Foundation.h>

//#if defined(DEBUG)
#   define CMXLog(...) NSLog(@"%@", [NSString stringWithFormat:__VA_ARGS__])
#   define CMXLogD(...) NSLog(@"%s (%d), %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])
//#else // !DEBUG
//#   define CMXLog(...)
//#   define CMXLogD(...)
//#endif // !DEBUG

