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

- (void)bm_imageScaleWithMaxSize:(CGSize)size complete:(void (^)(UIImage *scaledImage, CGFloat scale))complete {
    CGFloat cgImageWidth = CGImageGetWidth(self.CGImage);
    CGFloat cgImageHeight = CGImageGetHeight(self.CGImage);
    UIImage *scaledImage = self;
    CGFloat scale = 1.0;
    if (cgImageWidth > size.width || cgImageHeight > size.height) {
        if (cgImageWidth > size.width) {
            scale = size.width / cgImageWidth;
        }
        else {
            scale = size.height / cgImageHeight;
        }
        UIGraphicsBeginImageContext(CGSizeMake(self.size.width * scale, self.size.height * scale));
        [self drawInRect:CGRectMake(0, 0, self.size.width * scale, self.size.height * scale)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return complete(scaledImage, scale);
}

@end
