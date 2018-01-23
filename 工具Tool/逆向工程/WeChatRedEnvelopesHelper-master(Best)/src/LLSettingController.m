//
//  LLSettingController.m
//  test
//
//  Created by fqb on 2017/12/15.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLSettingController.h"
#import "WCRedEnvelopesHelper.h"
#import "LLRedEnvelopesMgr.h"
#import <objc/runtime.h>

static NSString * const kSettingControllerKey = @"SettingControllerKey";

@interface LLSettingController () <MMPickLocationViewControllerDelegate>

@property (nonatomic, strong) ContactsDataLogic *contactsDataLogic;

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;
@property (nonatomic, strong) MMPickLocationViewController *pickLocationController;
@property (strong, nonatomic) MMLoadingView *loadingView;

@end

@implementation LLSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self setTableView];
    [self reloadTableData];
}

- (void)commonInit{
    self.title = @"微信小助手";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
    
    _contactsDataLogic = [[NSClassFromString(@"ContactsDataLogic") alloc] initWithScene:0x0 delegate:nil sort:0x1 extendChatRoom:0x0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfirmFilterChatRoom:) name:@"kConfirmFilterChatRoomNotification" object:nil];
}

- (void)setTableView{
    _tableViewInfo = [[NSClassFromString(@"MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    [self.view addSubview:[_tableViewInfo getTableView]];
    [_tableViewInfo setDelegate:self];
    if (@available(iOS 11, *)) {         
        [_tableViewInfo getTableView].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;             
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
}

- (void)reloadTableData{
    [self.tableViewInfo clearAllSection];

    [self createRedView];
    [self createLocationView];
    [self createStepView];
    [self createPayView];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}
- (void)createRedView{
    //红包辅助
    MMTableViewCellInfo *openRedEnvelopesCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openRedEnvelopesSwitchHandler:) target:self title:@"是否开启红包助手" on:[LLRedEnvelopesMgr shared].isOpenRedEnvelopesHelper];
    MMTableViewCellInfo *backgroundModeCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openBackgroundMode:) target:self title:@"是否开启后台模式" on:[LLRedEnvelopesMgr shared].isOpenBackgroundMode];
    MMTableViewCellInfo *openAlertCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openRedEnvelopesAlertHandler:) target:self title:@"是否开启红包提醒" on:[LLRedEnvelopesMgr shared].isOpenRedEnvelopesAlert];
    
    NSInteger delaySeconds = [LLRedEnvelopesMgr shared].openRedEnvelopesDelaySecond;
    NSString *delayString = delaySeconds == 0 ? @"不延迟" : [NSString stringWithFormat:@"%ld 秒", (long)delaySeconds];
    MMTableViewCellInfo *delayTimeCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingDelay) target:self title:@"延迟抢红包" rightValue: delayString accessoryType:1];
    
    MMTableViewCellInfo *filterRoomCell = [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(onfilterRoomCellClicked) target:self title:@"过滤群聊" rightValue:[LLRedEnvelopesMgr shared].filterRoomDic.count?[NSString stringWithFormat:@"已选%ld个群聊",(long)[LLRedEnvelopesMgr shared].filterRoomDic.count]:@"暂未选择" accessoryType:1];
    objc_setAssociatedObject(delayTimeCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);
    MMTableViewCellInfo *openAutoReplyCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openAutoReplySwitchHandler:) target:self title:@"红包领取后自动回复" on:[LLRedEnvelopesMgr shared].isOpenAutoReply];
    
    MMTableViewCellInfo *autoReplyTextCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingAutoReplyText) target:self title:@"自动回复内容" rightValue: [LLRedEnvelopesMgr shared].autoReplyText?[LLRedEnvelopesMgr shared].autoReplyText:@"请输入自动回复内容" accessoryType:1];
    
    MMTableViewCellInfo *openAutoLeaveMessageCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openAutoLeaveMessageSwitchHandler:) target:self title:@"红包领取后自动留言" on:[LLRedEnvelopesMgr shared].isOpenAutoLeaveMessage];
    
    MMTableViewCellInfo *autoLeaveMessageTextCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingAutoLeaveMessageText) target:self title:@"自动留言内容" rightValue: [LLRedEnvelopesMgr shared].autoLeaveMessageText?[LLRedEnvelopesMgr shared].autoLeaveMessageText:@"请输入自动留言内容" accessoryType:1];
    
    MMTableViewCellInfo *openKeywordFilterCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openKeywordFilterSwitchHandler:) target:self title:@"是否打开关键字过滤" on:[LLRedEnvelopesMgr shared].isOpenKeywordFilter];
    
    MMTableViewCellInfo *keywordFilterTextCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingKeywordFilterText) target:self title:@"关键字过滤" rightValue: [LLRedEnvelopesMgr shared].keywordFilterText?[LLRedEnvelopesMgr shared].keywordFilterText:@"多个关键字以英文逗号分隔" accessoryType:1];
    
    MMTableViewCellInfo *isSnatchSelfCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(isSnatchSelfRedEnvelopesSwitchHandler:) target:self title:@"是否抢自己发的红包" on:[LLRedEnvelopesMgr shared].isSnatchSelfRedEnvelopes];
    
    MMTableViewSectionInfo *redEnvelopesSection = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"红包辅助"];
    [redEnvelopesSection addCell:openRedEnvelopesCell];
    if ([LLRedEnvelopesMgr shared].isOpenRedEnvelopesHelper) {
        [redEnvelopesSection addCell:backgroundModeCell];
        [redEnvelopesSection addCell:openAlertCell];
        [redEnvelopesSection addCell:delayTimeCell];
        [redEnvelopesSection addCell:filterRoomCell];
        [redEnvelopesSection addCell:openAutoReplyCell];
        [redEnvelopesSection addCell:autoReplyTextCell];
        [redEnvelopesSection addCell:openAutoLeaveMessageCell];
        [redEnvelopesSection addCell:autoLeaveMessageTextCell];
        [redEnvelopesSection addCell:openKeywordFilterCell];
        [redEnvelopesSection addCell:keywordFilterTextCell];
        [redEnvelopesSection addCell:isSnatchSelfCell];
    }
    [_tableViewInfo addSection:redEnvelopesSection];
}
- (void)settingDelay {
    NSInteger delaySeconds = [LLRedEnvelopesMgr shared].openRedEnvelopesDelaySecond;
    [self alertControllerWithTitle:@"延迟抢红包(秒)" message:nil content:[NSString stringWithFormat:@"%ld", (long)delaySeconds] placeholder:@"延迟时长" keyboardType:UIKeyboardTypeNumberPad blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setOpenRedEnvelopesDelaySecond:textField.text.integerValue];
        [self reloadTableData];
    }];
}
- (void)settingAutoReplyText {
    [self alertControllerWithTitle:@"自动回复内容" message:@"自动领完红包后发出的消息" content:[LLRedEnvelopesMgr shared].autoReplyText placeholder:@"请输入自动回复内容" keyboardType:UIKeyboardTypeDefault blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setAutoReplyText:textField.text];
        [self reloadTableData];
    }];
}
- (void)settingAutoLeaveMessageText{
    [self alertControllerWithTitle:@"自动留言内容" message:@"自动领完红包后给主人的留言信息" content:[LLRedEnvelopesMgr shared].autoLeaveMessageText placeholder:@"请输入自动留言内容" keyboardType:UIKeyboardTypeDefault blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setAutoLeaveMessageText:textField.text];
        [self reloadTableData];
    }];
}
- (void)settingKeywordFilterText{
    [self alertControllerWithTitle:@"关键字过滤" message:@"多个关键字以英文逗号分隔" content:[LLRedEnvelopesMgr shared].keywordFilterText placeholder:@"请输入关键字" keyboardType:UIKeyboardTypeDefault blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setKeywordFilterText:textField.text];
        [self reloadTableData];
    }];
}

- (void)createLocationView{
    MMTableViewCellInfo *openVirtualLocationCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openVirtualLocationSwitchHandler:) target:self title:@"是否开启虚拟定位" on:[LLRedEnvelopesMgr shared].isOpenVirtualLocation];
    
    MMTableViewSectionInfo *virtualLocationSection = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"装逼必备之修改定位"];
    [virtualLocationSection addCell:openVirtualLocationCell];
    if ([LLRedEnvelopesMgr shared].isOpenVirtualLocation) {
        [virtualLocationSection addCell:[self createadLatitudeCell]];
        [virtualLocationSection addCell:[self createadLongitudeCell]];
        [virtualLocationSection addCell:[self selectVirtualLocationCell]];
    }
    [_tableViewInfo addSection:virtualLocationSection];
}

- (MMTableViewCellInfo *)createadLatitudeCell {
    double latitude = [[LLRedEnvelopesMgr shared] latitude];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(updateLatitude) target:self title:@"修改的纬度(latitude)" rightValue:[NSString stringWithFormat:@"%f", latitude] accessoryType:1];
    
    return cellInfo;
}

- (MMTableViewCellInfo *)createadLongitudeCell {
    double longitude = [[LLRedEnvelopesMgr shared] longitude];
    MMTableViewCellInfo *cellInfo = [objc_getClass("MMTableViewCellInfo")  normalCellForSel:@selector(updateLongitude) target:self title:@"修改的经度(longitude)" rightValue:[NSString stringWithFormat:@"%f", longitude] accessoryType:1];
    
    return cellInfo;
}
- (MMTableViewCellInfo *)selectVirtualLocationCell{
    return [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(onVirtualLocationCellClicked) target:self title:@"选择虚拟位置" rightValue:[LLRedEnvelopesMgr shared].poiName?[LLRedEnvelopesMgr shared].poiName:@"暂未选择" accessoryType:1];
}
/// 更新经度
- (void)updateLatitude {
    double latitude = [[LLRedEnvelopesMgr shared] latitude];
    [self alertControllerWithTitle:@"修改纬度(latitude)"
                           message:@"请同时修改经度和纬度，若其中一个小于0则无效，关于经纬度的获取可去高德地图或百度地图，并转换为Wgs84"
                           content:[NSString stringWithFormat:@"%f", latitude]
                       placeholder:@"请输入纬度"
                      keyboardType:UIKeyboardTypeDecimalPad
                               blk:^(UITextField *textField) {
                                   [[LLRedEnvelopesMgr shared] setLatitude:MAX(0.0, textField.text.doubleValue)];
                                   [self reloadTableData];
                               }];
}

/// 更新纬度
- (void)updateLongitude {
    double longitude = [[LLRedEnvelopesMgr shared] longitude];
    [self alertControllerWithTitle:@"修改经度(longitude)"
                           message:@"请同时修改经度和纬度，若其中一个小于0则无效"
                           content:[NSString stringWithFormat:@"%f", longitude]
                       placeholder:@"请输入经度"
                      keyboardType:UIKeyboardTypeDecimalPad
                               blk:^(UITextField *textField) {
                                   [[LLRedEnvelopesMgr shared] setLongitude:MAX(0.0, textField.text.doubleValue)];
                                   [self reloadTableData];
                               }];
}

- (void)createStepView{
    MMTableViewCellInfo *openStepCountCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openStepCountSwitchHandler:) target:self title:@"是否开启运动助手" on:[LLRedEnvelopesMgr shared].isOpenSportHelper];
    MMTableViewCellInfo *stepCountModeCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(stepCountModeSwitchHandler:) target:self title:@"范围随机Y/固定步数N" on:[LLRedEnvelopesMgr shared].sportStepCountMode];
    
    NSInteger stepNumber = [LLRedEnvelopesMgr shared].wantSportStepCount;
    NSString *stepNumberString = stepNumber == 0 ? @"请输入想要的运动步数" : [NSString stringWithFormat:@"%ld 步", (long)stepNumber];
    MMTableViewCellInfo *stepCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingStepNumber) target:self title:@"固定运动步数" rightValue: stepNumberString accessoryType:1];
    
    NSInteger stepMaxNumber = [LLRedEnvelopesMgr shared].sportStepCountUpperLimit;
    NSString *stepMaxNumberString = stepMaxNumber == 0 ? @"请输入运动步数上限" : [NSString stringWithFormat:@"%ld 步", (long)stepMaxNumber];
    MMTableViewCellInfo *stepUpperLimitCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingStepMaxNumber) target:self title:@"随机运动步数上限" rightValue: stepMaxNumberString accessoryType:1];
    
    NSInteger stepMinNumber = [LLRedEnvelopesMgr shared].sportStepCountLowerLimit;
    NSString *stepMinNumberString = stepMinNumber == 0 ? @"请输入运动步数下限" : [NSString stringWithFormat:@"%ld 步", (long)stepMinNumber];
    MMTableViewCellInfo *stepLowerLimitCell = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingStepMinNumber) target:self title:@"随机运动步数下限" rightValue: stepMinNumberString accessoryType:1];
    
    MMTableViewSectionInfo *stepCountSection = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"装逼必备之运动助手"];
    [stepCountSection addCell:openStepCountCell];
    if ([LLRedEnvelopesMgr shared].isOpenSportHelper) {
        [stepCountSection addCell:stepCountModeCell];
        if([LLRedEnvelopesMgr shared].sportStepCountMode){
            [stepCountSection addCell:stepUpperLimitCell];
            [stepCountSection addCell:stepLowerLimitCell];
        } else {
            [stepCountSection addCell:stepCell];
        }
    }
    [_tableViewInfo addSection:stepCountSection];
}
- (void)settingStepNumber{
    NSInteger delaySeconds = [LLRedEnvelopesMgr shared].wantSportStepCount;
    [self alertControllerWithTitle:@"固定运动步数" message:@"步数需比之前设置的步数大才能生效，最大值为98800" content:[NSString stringWithFormat:@"%ld", (long)delaySeconds] placeholder:@"请输入想要的运动步数" keyboardType:UIKeyboardTypeNumberPad blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setWantSportStepCount:textField.text.integerValue];
        [self reloadTableData];
    }];
}
- (void)settingStepMaxNumber{
    NSInteger delaySeconds = [LLRedEnvelopesMgr shared].sportStepCountUpperLimit;
    [self alertControllerWithTitle:@"随机运动步数上限" message:@"最终步数将从最大数和最小数之间随机" content:[NSString stringWithFormat:@"%ld", (long)delaySeconds] placeholder:@"请输入运动步数下限" keyboardType:UIKeyboardTypeNumberPad blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setSportStepCountUpperLimit:textField.text.integerValue];
        [self reloadTableData];
    }];
}
- (void)settingStepMinNumber{
    NSInteger delaySeconds = [LLRedEnvelopesMgr shared].sportStepCountLowerLimit;
    [self alertControllerWithTitle:@"随机运动步数下限" message:@"最终步数将从最大数和最小数之间随机" content:[NSString stringWithFormat:@"%ld", (long)delaySeconds] placeholder:@"请输入运动步数下限" keyboardType:UIKeyboardTypeNumberPad blk:^(UITextField *textField) {
        [[LLRedEnvelopesMgr shared] setSportStepCountLowerLimit:textField.text.integerValue];
        [self reloadTableData];
    }];
}
- (void)createPayView{
    MMTableViewCellInfo *openAvoidRevokeMessageCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openAvoidRevokeMessageSwitchHandler:) target:self title:@"消息防撤回" on:[LLRedEnvelopesMgr shared].isOpenAvoidRevokeMessage];
    MMTableViewSectionInfo *revokeMessageSection = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"附加功能"];
    [revokeMessageSection addCell:openAvoidRevokeMessageCell];
//    [revokeMessageSection addCell:[self createWeChatPayingCell]];
//    [revokeMessageSection addCell:[self createMyGithupCell]];
    [_tableViewInfo addSection:revokeMessageSection];
}
- (MMTableViewCellInfo *)createWeChatPayingCell{
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"支持作者开发" accessoryType:1];
}
- (MMTableViewCellInfo *)createMyGithupCell{
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(payingToAuthor) target:self title:@"我的GitHub" rightValue:@"欢迎Star" accessoryType:1];
}
- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:3];
    scanQRCodeLogic.fromScene = 2;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:3];
    [qrCodeScanner notifyResult:@"wxp://f2f0dIeuFV8yKKpI-obgtf--7HwAaneyxCSd" type:@"QR_CODE" version:6];
}

- (void)openRedEnvelopesSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenRedEnvelopesHelper = openSwitch.on;
}

- (void)openBackgroundMode:(UISwitch *)backgroundMode{
    [LLRedEnvelopesMgr shared].isOpenBackgroundMode = backgroundMode.on;
}

- (void)openRedEnvelopesAlertHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenRedEnvelopesAlert = openSwitch.on;
}

- (void)openAutoReplySwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenAutoReply = openSwitch.on;
}

- (void)openAutoLeaveMessageSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenAutoLeaveMessage = openSwitch.on;
}

- (void)openKeywordFilterSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenKeywordFilter = openSwitch.on;
}

- (void)openVirtualLocationSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenVirtualLocation = openSwitch.on;
    [self reloadTableData];
}

- (void)onVirtualLocationCellClicked{
    _pickLocationController = [[NSClassFromString(@"MMPickLocationViewController") alloc] initWithScene:0 OnlyUseUserLocation:NO];
    _pickLocationController.delegate = self;
    MMUINavigationController *navController = [[NSClassFromString(@"MMUINavigationController") alloc] initWithRootViewController:_pickLocationController];
    [self PresentModalViewController:navController animated:YES];
}

- (void)openStepCountSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenSportHelper = openSwitch.on;
}

- (void)stepCountModeSwitchHandler:(UISwitch *)modeSwitch{
    [LLRedEnvelopesMgr shared].sportStepCountMode = modeSwitch.on;
    [self reloadTableData]; //刷新页面
}

- (void)isSnatchSelfRedEnvelopesSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isSnatchSelfRedEnvelopes = openSwitch.on;
}

- (void)onfilterRoomCellClicked{
    LLFilterChatRoomController *chatRoomVC = [[NSClassFromString(@"LLFilterChatRoomController") alloc] init];
    MemberDataLogic *dataLogic = [[NSClassFromString(@"MemberDataLogic") alloc] initWithMemberList:[_contactsDataLogic getChatRoomContacts] admin:0x0];
    [chatRoomVC setMemberLogic:dataLogic];
    chatRoomVC.filterRoomDic = [LLRedEnvelopesMgr shared].filterRoomDic;
    [self.navigationController PushViewController:chatRoomVC animated:YES];
}

- (void)openAvoidRevokeMessageSwitchHandler:(UISwitch *)openSwitch{
    [LLRedEnvelopesMgr shared].isOpenAvoidRevokeMessage = openSwitch.on;
}
- (void)onGithubCellClicked{
    NSURL *myGithubURL = [NSURL URLWithString:@"https://github.com/xiaofu666/WechatPlus"];
    MMWebViewController *githubWebVC = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:myGithubURL presentModal:NO extraInfo:nil delegate:nil];
    [self.navigationController PushViewController:githubWebVC animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)onConfirmFilterChatRoom:(NSNotification *)notify{
    [LLRedEnvelopesMgr shared].filterRoomDic = notify.object;
    [self reloadTableData]; //刷新页面
}

- (void)onPickLocationControllerConfirmClicked{
    [_pickLocationController DismissMyselfAnimated:YES];
    POIInfo *currentPOIInfo = [_pickLocationController getCurrentPOIInfo];
    [[LLRedEnvelopesMgr shared] setPoiName:currentPOIInfo.poiName?currentPOIInfo.poiName:@"上海"];
    [[LLRedEnvelopesMgr shared] setLatitude:MAX(0.0, currentPOIInfo.coordinate.latitude)];
    [[LLRedEnvelopesMgr shared] setLongitude:MAX(0.0, currentPOIInfo.coordinate.longitude)];
    [_pickLocationController reportOnDone];
    [self reloadTableData]; //刷新页面
}

#pragma mark - MMPickLocationViewControllerDelegate

- (UIBarButtonItem *)onGetRightBarButton{
    return [NSClassFromString(@"MMUICommonUtil") getBarButtonWithTitle:@"确定" target:self action:@selector(onPickLocationControllerConfirmClicked) style:0];
}

- (void)onCancelSeletctedLocation{
    [_pickLocationController DismissMyselfAnimated:YES];
    [_pickLocationController reportOnDone];
}

#pragma mark -  alertView
- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType blk:(void (^)(UITextField *))blk  {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (blk) {
                                                        blk(alert.textFields.firstObject);
                                                    }
                                                }]];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeholder;
            textField.text = content;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.keyboardType = keyboardType;
        }];
        
        alert;
    });
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

#pragma mark - Life Cycle

- (void)startLoadingBlocked {
    if (!self.loadingView) {
        self.loadingView = [self createDefaultLoadingView];
        [self.view addSubview:self.loadingView];
    } else {
        [self.view bringSubviewToFront:self.loadingView];
    }
    [self.loadingView setM_bIgnoringInteractionEventsWhenLoading:YES];
    [self.loadingView setFitFrame:1];
    [self.loadingView startLoading];
}

- (void)startLoadingNonBlock {
    if (!self.loadingView) {
        self.loadingView = [self createDefaultLoadingView];
        [self.view addSubview:self.loadingView];
    } else {
        [self.view bringSubviewToFront:self.loadingView];
    }
    [self.loadingView setM_bIgnoringInteractionEventsWhenLoading:NO];
    [self.loadingView setFitFrame:1];
    [self.loadingView startLoading];
}

- (void)startLoadingWithText:(NSString *)text {
    [self startLoadingNonBlock];
    
    [self.loadingView.m_label setText:text];
}

- (MMLoadingView *)createDefaultLoadingView {
    MMLoadingView *loadingView = [[objc_getClass("MMLoadingView") alloc] init];
    
    MMServiceCenter *serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    MMLanguageMgr *languageMgr = [serviceCenter getService:objc_getClass("MMLanguageMgr")];
    NSString *loadingText = [languageMgr getStringForCurLanguage:@"Common_DefaultLoadingText" defaultTo:@"Common_DefaultLoadingText"];
    
    [loadingView.m_label setText:loadingText];
    
    return loadingView;
}

- (void)stopLoading {
    [self.loadingView stopLoading];
}

- (void)stopLoadingWithFailText:(NSString *)text {
    [self.loadingView stopLoadingAndShowError:text];
}

- (void)stopLoadingWithOKText:(NSString *)text {
    [self.loadingView stopLoadingAndShowOK:text];
}

- (void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
