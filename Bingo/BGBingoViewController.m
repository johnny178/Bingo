//
//  BGBingoViewController.m
//  Bingo
//
//  Created by 林宗毅 on 21/02/2018.
//  Copyright © 2018 ClassroomM. All rights reserved.
//

#import "BGBingoViewController.h"
#import "BGSetViewController.h"

#define NUMBERS 9
@interface BGBingoViewController ()<UITextFieldDelegate>
{
    NSString *m_strRange;
    int m_iFnum ,m_iBnum;
    BOOL m_bsuccess;//無錯誤則值為TRUE 有錯誤則值為FALSE
    BOOL m_bMode;
}

@property (retain, nonatomic) IBOutlet UISwitch *m_choiceSwitch;
@property (retain, nonatomic) IBOutlet UITextField *m_rangeTextField;
@property (retain, nonatomic) IBOutlet UILabel *m_linesNumLabel;
@property (retain, nonatomic) IBOutlet UIButton *m_setButton;
@property (retain, nonatomic) NSMutableArray* m_arySets;
@property (retain, nonatomic) IBOutletCollection(UIView) NSArray *m_aryView;

@property(retain, nonatomic) UITextField *m_currentTextField;

- (IBAction)switchMode:(id)sender;
- (IBAction)enterRange:(id)sender;
- (IBAction)setNumber:(id)sender;

- (BOOL) isText;//檢查有無text
- (BOOL) isError:(NSString*)str;//檢查是否含有非法字元
- (void) checkRange;//檢查範圍是否合乎規格
- (int) calLines;//計算行數
- (void) checkRangeNums;//檢查九宮格數字是否有不合乎範圍
- (void) checkSameNums;//檢查九宮格數字是否有重複
- (void) errorMessege:(NSString*)str;
- (void) setDefault;
- (void) setZero;
- (void) createRandomNums:(int*)num;//建立亂數
@end

@interface BGBingoViewController(BGSetVC_delegate)<BGSetViewControllerDelegate>
@end

@implementation BGBingoViewController

- (void)dealloc
{
    [m_strRange release];
    [self.m_choiceSwitch release];
    [self.m_rangeTextField release];
    [self.m_linesNumLabel release];
    [self.m_setButton release];
    
    [self.m_currentTextField release];
    [_m_aryView release];
    
    [_m_arySets release];
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
    self.m_linesNumLabel.text = @"";
    self.m_rangeTextField.enabled = TRUE;
    self.m_setButton.enabled = TRUE;
    
    self.m_linesNumLabel.text = [NSString stringWithFormat:@"0"];
    self.m_choiceSwitch.enabled = FALSE;
    self.m_choiceSwitch.on = FALSE;
    
    m_iFnum = 0;
    m_iBnum = 0;
    
    m_bsuccess = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    self.m_rangeTextField.delegate = self;
    self.m_arySets = [[NSMutableArray alloc]init];
    [self.m_arySets release];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    for(UIView *view in self.m_aryView){
        NSInteger iTag = view.tag;
        CGRect cg = view.bounds;
        
        BGSetViewController *blockView = [[[BGSetViewController alloc]bgInitWithFrame:cg]autorelease];
        [blockView bgSetDelegate:self];
        [self.m_arySets insertObject:blockView atIndex:iTag];
        [self addChildViewController:blockView];
        [view addSubview:blockView.view];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (IBAction)switchMode:(id)sender {
    m_bsuccess = TRUE;
    if(self.m_choiceSwitch.on){//切到遊戲模式
        if(![self isText]){
            [self errorMessege:@"九宮格未填滿！"];
            self.m_choiceSwitch.on = FALSE;
        }
        else if(TRUE == m_bsuccess){
            self.m_rangeTextField.enabled = FALSE;
            self.m_setButton.enabled = FALSE;
            
            for(BGSetViewController *set in self.m_arySets){
                [set bgSetMode:1];
            }
        }
    }
    else {//切到編輯模式
        self.m_rangeTextField.enabled = TRUE;
        self.m_setButton.enabled = TRUE;
        for(BGSetViewController *set in self.m_arySets){
            [set bgSetMode:0];
        }
        self.m_linesNumLabel.text = [NSString stringWithFormat:@"0"];
    }
}
- (IBAction)enterRange:(id)sender {
    m_strRange = self.m_rangeTextField.text;
    if(![self.m_currentTextField.text isEqualToString:@""])
        [self checkRange];
    else{
        for(BGSetViewController *set in self.m_arySets){
            set.m_TextField.text = @"";
        }
    }
}

- (IBAction)setNumber:(id)sender {
    m_strRange = self.m_rangeTextField.text;
    [self checkRange];
    self.m_currentTextField = [self.m_arySets.lastObject m_TextField];
    
    if(TRUE == m_bsuccess)
    {
        self.m_choiceSwitch.enabled = TRUE;
        
        int inum[NUMBERS] = {0};
        [self createRandomNums:inum];
        //建立九個不重複數字
        
        int k = 0;
        
        for(BGSetViewController *set in self.m_arySets){
            set.m_TextField.text = [NSString stringWithFormat:@"%d",inum[k]];
            k++;
        }
        //放入數字到button
    }
    [self.view endEditing:YES];//dismiss keyboard
}

- (BOOL)isText{
    for(BGSetViewController *set in self.m_arySets){
        if([set.m_TextField.text isEqualToString:@""])
            return FALSE;
    }
    return TRUE;
}
- (BOOL) isError:(NSString*)str{
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:str];
    
    //strTest從頭到尾是否包含myCharSet 無則回傳TRUE 代表含有非法字元
    for (int i = 0; i < [self.m_currentTextField.text length]; i++) {
        unichar c = [self.m_currentTextField.text characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            self.m_currentTextField.text = @"";
            return TRUE;
        }
    }
    return FALSE;
}

- (void) checkRange{
    NSString *m_strFrontNum = nil, *m_strBackNum = nil;
    
    m_bsuccess = TRUE;
    if(TRUE == [self isError:@"0123456789-"]
       || [m_strRange rangeOfString:@"-"].location == NSNotFound
       || [m_strRange characterAtIndex:m_strRange.length - 1] == '-')
    {
        [self errorMessege:@"格式錯誤"];
        self.m_choiceSwitch.enabled = FALSE;
        m_iBnum = 0;
        m_iFnum = 0;
        self.m_rangeTextField.text = @"";
    }
    else{
        NSRange CutCommand = [m_strRange rangeOfString:@"-"];
        m_strFrontNum = [m_strRange substringToIndex:CutCommand.location];
        m_strBackNum = [m_strRange substringFromIndex:CutCommand.location + 1];
        //處理輸入範圍字串前後數字分割
        
        
        m_iFnum = [m_strFrontNum intValue];
        m_iBnum = [m_strBackNum intValue];//string to int
        
        
        if(m_iBnum - m_iFnum <= 0 || m_iFnum <= 0){
            [self errorMessege:@"範圍有誤"];
            [self setDefault];
        }
        if(m_iBnum - m_iFnum < NUMBERS - 1){
            [self errorMessege:@"輸入範圍不足九數,請重新輸入"];
            [self setDefault];
        }
    }
    if(FALSE == m_bsuccess){
        for(BGSetViewController *set in self.m_arySets){
            set.m_TextField.text = @"";
        }
        self.m_choiceSwitch.on = FALSE;
    }
    [m_strFrontNum release];
    [m_strBackNum release];
}

- (void) checkRangeNums{
    int iCurrentNum = [self.m_currentTextField.text intValue];
    for(int i = 0;i < NUMBERS;i++){
        if((iCurrentNum < m_iFnum || iCurrentNum > m_iBnum)
           && ![self.m_currentTextField.text isEqualToString:@""]
           && ![self.m_rangeTextField.text isEqualToString:@""])
        {
            [self errorMessege:@"輸入不在範圍內"];
            [self setZero];
            break;
        }
        else if (![self.m_rangeTextField.text isEqualToString:@""]){
            [self checkSameNums];
        }
    }
}
- (void) checkSameNums{
    int m_iNumber[NUMBERS];
    for(int i = 0;i < NUMBERS;i++){
        m_iNumber[i] = 0;
    }
    
    int k = 0;
    for(BGSetViewController *set in self.m_arySets){
        m_iNumber[k] = [set.m_TextField.text intValue];
        k++;
    }
    for(int j = 0;j < NUMBERS;j++){
        for(int k = 0;k < NUMBERS;k++){
            if(m_iNumber[j] == m_iNumber[k] && j!=k && m_iNumber[j]!=0){
                [self errorMessege:@"有相同數字"];
                [self setZero];
                m_bsuccess = FALSE;
                break;
            }
        }
    }
    if(TRUE == m_bsuccess)
        self.m_choiceSwitch.enabled = TRUE;
}
- (int) calLines{
    int lines = 0;
    int color[NUMBERS + 1] = {0};//紀錄九宮格顏色 0為白 1為紅
    int i = 0;
    
    for(BGSetViewController *set in self.m_arySets){
        if([[set bgGetBtnColor] isEqual:[UIColor redColor]])
            color[i] = 1;
        i++;
    }
    //列
    for(int i = 0;i <= 6;i += 3){
        if(3 == color[i] + color[i + 1] + color[i + 2])
            lines++;
    }
    
    //行
    for(int i = 0;i <= 2;i++){
        if(3 == color[i] + color[i + 3] + color[i + 6])
            lines++;
    }
    
    //對角線
    if(3 == color[0] + color[4] + color[8])
        lines++;
    if(3 == color[2] + color[4] + color[6])
        lines++;
    
    return lines;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.m_currentTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    m_strRange = self.m_rangeTextField.text;
    if(![self.m_currentTextField.text isEqualToString:@""])
        [self checkRange];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGFloat m_fKeyboardheight = 0;
    CGFloat m_fDisplacement = 0;
    m_fKeyboardheight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect textFieldRect =
    [self.view.window convertRect:self.m_currentTextField.bounds fromView:self.m_currentTextField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    m_fDisplacement = textFieldRect.origin.y + textFieldRect.size.height + m_fKeyboardheight
    - viewRect.size.height;
    
    CGRect viewFrame = self.view.frame;
    if(m_fDisplacement > 0){
        viewFrame.origin.y -= m_fDisplacement;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    CGRect viewFrame = self.view.frame;
    
    viewFrame.origin.y = 0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.5];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

//點擊背景後收起鍵盤
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(self.m_rangeTextField == self.m_currentTextField){
        for(BGSetViewController *set in self.m_arySets){
            set.m_TextField.text = @"";
        }
    }
    else{
        if([self isText])
            self.m_choiceSwitch.enabled = TRUE;
    }
    [self.view endEditing:YES];
}
- (void)errorMessege:(NSString*)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告!!" message:str preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *button = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:button];
    [self presentViewController:alert animated:YES completion:nil];
    m_bsuccess = FALSE;
}

- (void)setDefault{
    self.m_choiceSwitch.enabled = FALSE;
    m_iBnum = 0;
    m_iFnum = 0;
    self.m_rangeTextField.text = @"";
}


- (void)createRandomNums:(int*)num{
    int i = 0;
    int iTemp;
    BOOL bsame_num = FALSE;
    while(i < NUMBERS){
        iTemp = arc4random_uniform(m_iBnum - m_iFnum + 1) + m_iFnum;
        for(int j = 0;j < NUMBERS;j++){
            if(num[j] == iTemp){
                bsame_num = TRUE;
                break;
            }
            bsame_num = FALSE;
        }
        if(!bsame_num){
            num[i] = iTemp;
            i++;
        }
    }
}
- (void)setZero{
    self.m_choiceSwitch.on = FALSE;
    self.m_currentTextField.text = @"";
}
@end

@implementation BGBingoViewController(BGSetVC_delegate)

- (void)BGBtnTouchDownByBGSetViewController:(BGSetViewController *)BGSet {
    self.m_linesNumLabel.text = [NSString stringWithFormat:@"%d",[self calLines]];
}

- (void)BGTextFieldDidBeginBySetViewController:(BGSetViewController *)BGSet {
    self.m_currentTextField = BGSet.m_TextField;
    self.m_choiceSwitch.enabled = FALSE;
}

- (void)BGTextFieldDidEndBySetViewController:(BGSetViewController *)BGSet {
    if(NO == BGSet.m_isWrong)
        [self checkRangeNums];
    else
        self.m_choiceSwitch.enabled = FALSE;
}

- (void)BGTextFieldShouldReturnBySetViewController:(BGSetViewController *)BGSet {
    if([self isText])
        self.m_choiceSwitch.enabled = TRUE;
}

@end
