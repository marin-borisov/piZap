//
//  PZEditToolCollectionViewFlowLayout.m
//  piZap
//
//  Created by Assure Developer on 8/25/15.
//  Copyright (c) 2015 Digital Palette LLC. All rights reserved.
//

#import "PZEditToolCollectionViewFlowLayout.h"

@implementation PZEditToolCollectionViewFlowLayout

- (void)awakeFromNib
{
    self.itemSize = CGSizeMake(58, 58);
    self.minimumInteritemSpacing = 5;
    self.minimumLineSpacing = 6;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(8, 3.f, 8, 3.f);
}

#pragma mark - Pagination
//- (CGFloat)pageWidth {
//    return 320.f - self.minimumLineSpacing;
//    //return self.itemSize.width + self.minimumLineSpacing;
//}
//
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
//{
//    CGFloat rawPageValue = self.collectionView.contentOffset.x / self.pageWidth;
//    CGFloat currentPage = (velocity.x > 0.0) ? floor(rawPageValue) : ceil(rawPageValue);
//    CGFloat nextPage = (velocity.x > 0.0) ? ceil(rawPageValue) : floor(rawPageValue);
//    
//    BOOL pannedLessThanAPage = fabs(1 + currentPage - rawPageValue) > 0.5;
//    BOOL flicked = fabs(velocity.x) > [self flickVelocity];
//    if (pannedLessThanAPage && flicked) {
//        proposedContentOffset.x = nextPage * self.pageWidth;
//    } else {
//        proposedContentOffset.x = round(rawPageValue) * self.pageWidth;
//    }
//    
//    return proposedContentOffset;
//}
//
//- (CGFloat)flickVelocity {
//    return 1.0;
//}

@end
