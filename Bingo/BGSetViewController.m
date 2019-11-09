//
//  BGSet.m
//  Bingo
//
//  Created by 林宗毅 on 25/04/2018.
//  Copyright © 2018 ClassroomM. All rights reserved.
//

#import "BGSetViewController.h"

@interface BGSetViewController ()
{
    
}
@property (nonatomic, assign) id <BGSetViewControllerDelegate> m_delegate;
@property (retain, nonatomic) IBOutlet UIButton *m_Btn;

- (IBAction)touchBtn:(id)sender;

- (BOOL)isError;//檢查是否含有非法字元
- (void)errorMessege:(NSString*)str;//錯誤訊息

@end

@interface BGSetViewController(UITextField_Delegate)<UITextFieldDelegate>
@end

@implementation BGSetViewController
- (void)dealloc {
    [_m_TextField release];
    [_m_Btn release];
    [super dealloc];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.m_TextField.delegate = self;
    self.m_Btn.enabled = FALSE;
    self.m_TextField.enabled = TRUE;
    self.m_isWrong = NO;
}
#pragma mark - Public Function
- (void)bgSetMode:(BOOL)bMode{
    if(1 == bMode){
        //game mode
        self.m_Btn.enabled = TRUE;
        self.m_TextField.enabled = FALSE;
    }
    else{
        //edit mode
        self.m_Btn.enabled = FALSE;
        self.m_TextField.enabled = TRUE;
        self.m_Btn.backgroundColor = [UIColor whiteColor];
    }
}
- (void) bgSetDelegate:(id<BGSetViewControllerDelegate>) delegate{
    _m_delegate = delegate;
}
- (instancetype) bgInitWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.view.frame = frame;
    }
    return self;
}
- (UIColor*) bgGetBtnColor{
    return self.m_Btn.backgroundColor;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Private Function

- (IBAction)touchBtn:(id)sender {
    if([self.m_Btn.backgroundColor isEqual:[UIColor whiteColor]])
        self.m_Btn.backgroundColor = [UIColor redColor];
    else
        self.m_Btn.backgroundColor = [UIColor whiteColor];
    [self.m_delegate BGBtnTouchDownByBGSetViewController:self];
}

- (BOOL)isError{
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    //strTest從頭到尾是否包含myCharSet 無則回傳TRUE 代表含有非法字元
    for (int i = 0; i < [self.m_TextField.text length]; i++) {
        unichar c = [self.m_TextField.text characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            self.m_TextField.text = @"";
            return TRUE;
        }
    }
    return FALSE;
}

- (void)errorMessege:(NSString*)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告!!" message:str preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *button = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:button];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

@implementation BGSetViewController(UITextField_Delegate)

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    [self.m_delegate BGTextFieldShouldReturnBySetViewController:self];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.m_delegate BGTextFieldDidBeginBySetViewController:self];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(TRUE == [self isError]){
        [self errorMessege:@"含不合法字元"];
        self.m_isWrong = YES;
    }
    else
        self.m_isWrong = NO;
    [self.m_delegate BGTextFieldDidEndBySetViewController:self];
}


@end
