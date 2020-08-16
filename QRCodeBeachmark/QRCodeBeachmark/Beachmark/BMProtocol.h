//
//  BMProtocol.h
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/16.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#ifndef BMProtocol_h
#define BMProtocol_h

@protocol BMProtocol <NSObject>

- (void)benchmark:(void (^)(int total, int count, NSString *imagePath, NSString *beachmarkPath))block;

@end

#endif /* BMProtocol_h */
