//
//  KMSetAddressVc.m
//  InstantCare
//
//  Created by KM on 2016/12/1.
//  Copyright © 2016年 omg. All rights reserved.
//

#import "KMSetAddressVc.h"
#import "KMCostomTextView.h"
#import "UIBarButtonItem+Extension.h"

/// 只能输入数字、字母、汉字
#define DEF_NUMBERCHARCHINA [self specialSymbolsAction]

@interface KMSetAddressVc ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet KMCostomTextView *textView;

@end

@implementation KMSetAddressVc

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView.delegate = self;
    [self setupUI];
}

- (void)setupUI
{
//    self.view.backgroundColor = RGB(247, 247, 246);
    self.navigationItem.title = kLoadStringWithKey(@"Reg_VC_tip_address");
//    self.CardTextField.text = self.text;
    //左边导航栏按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTitle:kLoadStringWithKey(@"Common_cancel") target:self action:@selector(cancelAction)];
    
    //右边导航栏按钮
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTitle:kLoadStringWithKey(@"Common_save") target:self action:@selector(saveAction)];
    
    self.textView.placeholder = kLoadStringWithKey(@"Address");
}

#pragma mark -Action

- (void)saveAction
{
    //    DMLog(@"self.nameTextField.text = %@",self.nameTextField.text);
    
    [[NSUserDefaults standardUserDefaults]setObject:self.textView.text forKey:@"Address"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textView becomeFirstResponder];
}

#pragma mark - <UITextViewDelegate>
- (void)textViewDidChange:(UITextView *)textView
{
    self.navigationItem.rightBarButtonItem.enabled = textView.hasText;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:DEF_NUMBERCHARCHINA]invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [text isEqualToString:filtered];
    if(basicTest){
        if([text isEqualToString:@""]){
            return YES;
        }
        return NO;
    }
    
    return YES;
}

/// 特殊符号
- (NSString *)specialSymbolsAction{
    //数学符号
    NSString *matSym = @" ﹢﹣×÷±/=≌∽≦≧≒﹤﹥≈≡≠=≤≥<>≮≯∷∶∫∮∝∞∧∨∑∏∪∩∈∵∴⊥∥∠⌒⊙√∟⊿㏒㏑%‰⅟½⅓⅕⅙⅛⅔⅖⅚⅜¾⅗⅝⅞⅘≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩⊰⊱⋛⋚∫∬∭∮∯∰∱∲∳%℅‰‱øØπ";
    
    //标点符号
    NSString *punSym = @"。，、＇：∶；?‘’“”〝〞ˆˇ﹕︰﹔﹖﹑·¨….¸;！´？！～—ˉ｜‖＂〃｀@﹫¡¿﹏﹋﹌︴々﹟#﹩$﹠&﹪%*﹡﹢﹦﹤‐￣¯―﹨ˆ˜﹍﹎+=<＿_-ˇ~﹉﹊（）〈〉‹›﹛﹜『』〖〗［］《》〔〕{}「」【】︵︷︿︹︽_﹁﹃︻︶︸﹀︺︾ˉ﹂﹄︼❝❞!():,'[]｛｝^・.·．•＃＾＊＋＝＼＜＞＆§⋯`－–／—|\"\\";
    
    //单位符号＊·
    NSString *unitSym = @"°′″＄￥〒￠￡％＠℃℉﹩﹪‰﹫㎡㏕㎜㎝㎞㏎m³㎎㎏㏄º○¤%$º¹²³";
    
    //货币符号
    NSString *curSym = @"₽€£Ұ₴$₰¢₤¥₳₲₪₵元₣₱฿¤₡₮₭₩ރ円₢₥₫₦zł﷼₠₧₯₨Kčर₹ƒ₸￠";
    
    //制表符
    NSString *tabSym = @"─ ━│┃╌╍╎╏┄ ┅┆┇┈ ┉┊┋┌┍┎┏┐┑┒┓└ ┕┖┗ ┘┙┚┛├┝┞┟┠┡┢┣ ┤┥┦┧┨┩┪┫┬ ┭ ┮ ┯ ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻┼ ┽ ┾ ┿ ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╪ ╫ ╬═║╒╓╔ ╕╖╗╘╙╚ ╛╜╝╞╟╠ ╡╢╣╤ ╥ ╦ ╧ ╨ ╩ ╳╔ ╗╝╚ ╬ ═ ╓ ╩ ┠ ┨┯ ┷┏ ┓┗ ┛┳ ⊥ ﹃ ﹄┌ ╮ ╭ ╯╰";
    
    return [NSString stringWithFormat:@"%@%@%@%@%@",matSym,punSym,unitSym,curSym,tabSym];
}

@end
