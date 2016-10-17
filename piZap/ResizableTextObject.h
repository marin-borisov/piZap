//
//  IQLabelView.h
//  Created by Martin

#import <UIKit/UIKit.h>

@protocol ResizableTextObjectDelegate;

@interface ResizableTextObject : UIView
{
    UIImageView *rotateView;
    UIImageView *closeView;
    UIImageView *okView;
    UIImageView *menuView;

    BOOL isShowingEditingHandles;
}

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, strong) UIColor *growColor;

@property (nonatomic, strong) UIImage *closeImage;
@property (nonatomic, strong) UIImage *rotateImage;
@property (nonatomic, strong) UIImage *okImage;
@property (nonatomic, strong) UIImage *menuImage;

@property (nonatomic, strong) UILabel *lblText;
@property (nonatomic, strong) UIImageView *imgBubble;
@property (nonatomic, strong) NSArray *insetsForBubble;

@property (nonatomic, strong) UIFont *labelFont;
@property                     BOOL isTextOrBubble;

@property (nonatomic, assign) id <ResizableTextObjectDelegate> delegate;

@property (nonatomic) BOOL showContentShadow;     //Default is YES.
@property (nonatomic) BOOL enableClose;           //Default is YES. if set to NO, user can't delete the view
@property (nonatomic) BOOL enableRotate;          //Default is YES. if set to NO, user can't Rotate the view
@property (nonatomic) BOOL enableMoveRestriction; //Default is NO.

@property CGSize originalImageSize;

- (void)refresh;

- (void)hideEditingHandles;
- (void)showEditingHandles;

- (void)setTextFont:(UIFont*)font;
- (void)setTextLabel:(NSString*)strText;
- (void)setSuperViewSize:(CGSize)size;

- (void)setBubbleImage:(UIImage*)image withInsetTop:(float)top  withInsetLeft:(float)left  withInsetBottom:(float)bottom  withInsetRight:(float)right;
- (void)setTextGrowEffect:(UIColor*)color;
- (void)setLabelTextColor:(UIColor *)textColor;

- (void)setEditText;

@end

@protocol ResizableTextObjectDelegate <NSObject>

@optional

- (void)resizableTextObjectViewDidClose:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidOk:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidMenu:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidShowEditingHandles:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidHideEditingHandles:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidStartEditing:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidBeginEditing:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidChangeEditing:(ResizableTextObject *)label;
- (void)resizableTextObjectViewDidEndEditing:(ResizableTextObject *)label;

@end


