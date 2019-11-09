//
//  BGSet.h
//  Bingo
//
//  Created by 林宗毅 on 25/04/2018.
//  Copyright © 2018 ClassroomM. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGSetViewController;


#pragma mark - 實做「Bingo」畫面之「Output」介面
@protocol BGSetViewControllerDelegate <NSObject>
- (void)BGBtnTouchDownByBGSetViewController:(BGSetViewController *)BGSet;
- (void)BGTextFieldDidBeginBySetViewController: (BGSetViewController *)BGSet;
- (void)BGTextFieldDidEndBySetViewController: (BGSetViewController *)BGSet;
- (void)BGTextFieldShouldReturnBySetViewController: (BGSetViewController *)BGSet;
@end

#pragma mark - 「Bingo」畫面
@interface BGSetViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *m_TextField;
@property (assign, nonatomic) BOOL m_isWrong;

- (instancetype) bgInitWithFrame:(CGRect)frame;
- (void) bgSetDelegate:(id<BGSetViewControllerDelegate>) delegate;
- (void) bgSetMode:(BOOL)bMode;
- (UIColor*) bgGetBtnColor;

@end
