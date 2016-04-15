//
//  NSString+Trim.m
//  Spotify Notifier
//
//  Created by Moray on 15/04/16.
//  Copyright © 2016 Moray. All rights reserved.
//

#import "NSString+Trim.h"

@implementation NSString (Trim)

-(NSString *)trim:(int)length
{
  if (self.length <= length)
    return self;
  NSMutableString *str = [[self substringToIndex:length - 3] mutableCopy];
  [str appendString:@"..."];
  return str;
}

@end
