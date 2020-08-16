//
//  UIImage+scale.m
//  QRCodeBeachmark
//
//  Created by GuHaiJun on 2020/8/17.
//  Copyright © 2020 GuHaiJun. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)

- (UIImage *)bm_imageScale:(CGFloat)scale {
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scale, self.size.height * scale));
    [self drawInRect:CGRectMake(0, 0, self.size.width * scale, self.size.height * scale)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
