//
//  IQLabelView.h
//  Created by kcandr on 17/12/14.

#import <UIKit/UIKit.h>

@protocol ResizableObjectDelegate;

@interface ResizableObject : UIView
{
    UIImageView *imgView;
    UIImageView *rotateView;
    UIImageView *closeView;
    UIImageView *okView;
    UIImageView *menuView;

    BOOL isShowingEditingHandles;
}

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *borderColor;

@property (nonatomic, strong) UIImage *closeImage;
@property (nonatomic, strong) UIImage *rotateImage;
@property (nonatomic, strong) UIImage *okImage;
@property (nonatomic, strong) UIImage *menuImage;

@property (nonatomic, assign) id <ResizableObjectDelegate> delegate;

@property (nonatomic) BOOL showContentShadow;     //Default is YES.
@property (nonatomic) BOOL enableClose;           //Default is YES. if set to NO, user can't delete the view
@property (nonatomic) BOOL enableRotate;          //Default is YES. if set to NO, user can't Rotate the view
@property (nonatomic) BOOL enableMoveRestriction; //Default is NO.

@property (nonatomic, strong) UIImage *imageData;

@property CGSize originalImageSize;

- (void)refresh;

- (void)hideEditingHandles;
- (void)showEditingHandles;

- (void)setImageView:(UIImageView *)imageView;


@end

@protocol ResizableObjectDelegate <NSObject>

@optional

- (void)resizableObjectViewDidClose:(ResizableObject *)label;
- (void)resizableObjectViewDidOk:(ResizableObject *)label;
- (void)resizableObjectViewDidMenu:(ResizableObject *)label;
- (void)resizableObjectViewDidShowEditingHandles:(ResizableObject *)label;
- (void)resizableObjectViewDidHideEditingHandles:(ResizableObject *)label;
- (void)resizableObjectViewDidStartEditing:(ResizableObject *)label;
- (void)resizableObjectViewDidBeginEditing:(ResizableObject *)label;
- (void)resizableObjectViewDidChangeEditing:(ResizableObject *)label;
- (void)resizableObjectViewDidEndEditing:(ResizableObject *)label;

@end


