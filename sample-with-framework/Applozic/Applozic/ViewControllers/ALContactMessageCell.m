//
//  ALContactMessageCell.m
//  Applozic
//
//  Created by devashish on 12/03/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

// Constants
#define MT_INBOX_CONSTANT "4"
#define MT_OUTBOX_CONSTANT "5"

#define DATE_LABEL_SIZE 12
#define MESSAGE_TEXT_SIZE 14

#import "ALContactMessageCell.h"
#import "ALUtilityClass.h"
#import "UIImageView+WebCache.h"
#import "ALApplozicSettings.h"
#import "ALConstant.h"
#import "ALContact.h"
#import "ALColorUtility.h"
#import "ALContactDBService.h"
#import "ALMessageService.h"
#import "ALMessageInfoViewController.h"
#import "ALChatViewController.h"
#import "ALVCardClass.h"

@interface ALContactMessageCell ()

@end

@implementation ALContactMessageCell
{
    NSURL *theUrl;
    CGFloat msgFrameHeight;
    ALVCardClass *alVCard;
}
-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0 alpha:1];
        self.contentView.userInteractionEnabled = YES;
        
        self.contactProfileImage = [[UIImageView alloc] init];
        [self.contactProfileImage setBackgroundColor:[UIColor whiteColor]];
        [self.contactProfileImage setImage:[ALUtilityClass getImageFromFramworkBundle:@"ic_contact_picture_holo_light.png"]];
        [self.contentView addSubview:self.contactProfileImage];
        
        self.userContact = [[UILabel alloc] init];
        [self.userContact setBackgroundColor:[UIColor clearColor]];
        [self.userContact setTextColor:[UIColor blackColor]];
        [self.userContact setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.userContact setNumberOfLines:2];  [self.userContact setText:@"PHONE NO"];
        [self.contentView addSubview:self.userContact];

        self.emailId = [[UILabel alloc] init];
        [self.emailId setBackgroundColor:[UIColor clearColor]];
        [self.emailId setTextColor:[UIColor blackColor]];
        [self.emailId setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.emailId setNumberOfLines:2];  [self.emailId setText:@"EMAIL ID"];
        [self.contentView addSubview:self.emailId];

        self.contactPerson = [[UILabel alloc] init];
        [self.contactPerson setBackgroundColor:[UIColor clearColor]];
        [self.contactPerson setTextColor:[UIColor blackColor]];
        [self.contactPerson setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.contactPerson setText:@"CONTACT NAME"];
        [self.contentView addSubview:self.contactPerson];
        
        self.addContactButton = [[UIButton alloc] init];
        [self.addContactButton setTitle:@"ADD CONTACT" forState:UIControlStateNormal];
        [self.addContactButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.addContactButton.titleLabel setFont:[UIFont fontWithName:[ALApplozicSettings getFontFace] size:14]];
        [self.addContactButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.addContactButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.addContactButton setBackgroundColor:[UIColor grayColor]];
        [self.contentView addSubview:self.addContactButton];
        
        self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2.0 - 50 , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height/2.0 - 20 , 100, 40);
        
        [self.mDowloadRetryButton addTarget:self action:@selector(dowloadRetryActionButton) forControlEvents:UIControlEventTouchUpInside];

    }
    return self;
}

-(instancetype)populateCell:(ALMessage *) alMessage viewSize:(CGSize)viewSize
{
    self.mUserProfileImageView.alpha = 1;
    self.progresLabel.alpha = 0;
    self.mDowloadRetryButton.alpha = 0;
    [self.mDowloadRetryButton setHidden:NO];
    [self.contentView bringSubviewToFront:self.mDowloadRetryButton];

    [self.addContactButton setEnabled:NO];
    
    BOOL today = [[NSCalendar currentCalendar] isDateInToday:[NSDate dateWithTimeIntervalSince1970:[alMessage.createdAtTime doubleValue]/1000]];
    
    NSString * theDate = [NSString stringWithFormat:@"%@",[alMessage getCreatedAtTimeChat:today]];
    
    CGSize theDateSize = [ALUtilityClass getSizeForText:theDate maxWidth:150 font:self.mDateLabel.font.fontName fontSize:self.mDateLabel.font.pointSize];

    self.mMessage = alMessage;
    
    [self.mChannelMemberName setHidden:YES];
    [self.mNameLabel setHidden:YES];
    [self.mMessageStatusImageView setHidden:YES];
    
    if ([alMessage.type isEqualToString:@MT_INBOX_CONSTANT])
    {
        if([ALApplozicSettings isUserProfileHidden])
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 0, 45);
        }
        else
        {
            self.mUserProfileImageView.frame = CGRectMake(8, 0, 45, 45);
        }
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getReceiveMsgColor];
        
        self.mNameLabel.frame = self.mUserProfileImageView.frame;
        
        [self.mNameLabel setText:[ALColorUtility getAlphabetForProfileImage:alMessage.to]];
        
        [self.mBubleImageView setFrame:CGRectMake(self.mUserProfileImageView.frame.size.width + 13 , 0, viewSize.width - 120, viewSize.width - 180)];
        
        [self.contactProfileImage setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 10, self.mBubleImageView.frame.origin.y + 10, 50, 50)];
        [self.contactPerson setFrame:CGRectMake(self.contactProfileImage.frame.origin.x + self.contactProfileImage.frame.size.width + 10, self.contactProfileImage.frame.origin.y, 180, 20)];
        [self.userContact setFrame:CGRectMake(self.contactPerson.frame.origin.x, self.contactPerson.frame.origin.y + self.contactPerson.frame.size.height + 5, 180, 50)];
        [self.emailId setFrame:CGRectMake(self.userContact.frame.origin.x, self.userContact.frame.origin.y + self.userContact.frame.size.height + 5, 180, 50)];
        [self.addContactButton setFrame:CGRectMake(self.contactProfileImage.frame.origin.x, self.emailId.frame.origin.y + self.emailId.frame.size.height, self.mBubleImageView.frame.size.width - 20, 45)];
         [self setupProgress];
     
        self.mDateLabel.frame = CGRectMake(self.mBubleImageView.frame.origin.x , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width , 21);
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];

        self.mDowloadRetryButton.alpha = 1;
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        
        if (alMessage.imageFilePath == NULL)
        {
            NSLog(@" file path not found making download button visible ....ALContactMessageCell");
            
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
        }
        else
        {
            self.mDowloadRetryButton.alpha = 0;
        }
        if (alMessage.inProgress == YES)
        {
//            NSLog(@" In progress making download button invisible ....");
            self.progresLabel.alpha = 1;
            self.mDowloadRetryButton.alpha = 0;
        }
        else
        {
            self.progresLabel.alpha = 0;
        }
        
        ALContactDBService *theContactDBService = [[ALContactDBService alloc] init];
        ALContact *alContact = [theContactDBService loadContactByKey:@"userId" value: alMessage.to];
        
        if(alContact.contactImageUrl)
        {
            NSURL * theUrl1 = [NSURL URLWithString:alContact.contactImageUrl];
            [self.mUserProfileImageView sd_setImageWithURL:theUrl1];
        }
        else
        {
            [self.mNameLabel setHidden:NO];
            self.mUserProfileImageView.backgroundColor = [ALColorUtility getColorForAlphabet:alMessage.to];
        }

        
    }
    else
    {
        self.mUserProfileImageView.frame = CGRectMake(viewSize.width - 50, 5, 0, 45);
        
        self.mBubleImageView.backgroundColor = [ALApplozicSettings getSendMsgColor];
        self.mBubleImageView.frame = CGRectMake((viewSize.width - self.mUserProfileImageView.frame.origin.x + 60), 0, viewSize.width - 120, viewSize.width - 180);
        
        [self.contactProfileImage setFrame:CGRectMake(self.mBubleImageView.frame.origin.x + 10, self.mBubleImageView.frame.origin.y + 10, 50, 50)];
        [self.contactPerson setFrame:CGRectMake(self.contactProfileImage.frame.origin.x + self.contactProfileImage.frame.size.width + 10, self.contactProfileImage.frame.origin.y, 180, 20)];
        [self.userContact setFrame:CGRectMake(self.contactPerson.frame.origin.x, self.contactPerson.frame.origin.y + self.contactPerson.frame.size.height + 5, 180, 50)];
        [self.emailId setFrame:CGRectMake(self.userContact.frame.origin.x, self.userContact.frame.origin.y + self.userContact.frame.size.height + 5, 180, 50)];
        [self.addContactButton setFrame:CGRectMake(self.contactProfileImage.frame.origin.x, self.emailId.frame.origin.y + self.emailId.frame.size.height, self.mBubleImageView.frame.size.width - 20, 45)];
        
        [self.mDowloadRetryButton setHidden:NO];
        [self.mMessageStatusImageView setHidden:NO];

        msgFrameHeight = self.mBubleImageView.frame.size.height;
        
        self.mDateLabel.textAlignment = NSTextAlignmentLeft;
        self.mDateLabel.textColor = [UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:.5];
        
        self.mDateLabel.frame = CGRectMake((self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width) - theDateSize.width - 20, self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height, theDateSize.width, 21);
        
        self.mMessageStatusImageView.frame = CGRectMake(self.mDateLabel.frame.origin.x + self.mDateLabel.frame.size.width, self.mDateLabel.frame.origin.y, 20, 20);
        [self setupProgress];
        
        self.progresLabel.alpha = 0;
        self.mDowloadRetryButton.alpha = 0;
        
        if (alMessage.inProgress == YES)
        {
            self.progresLabel.alpha = 1;
//            NSLog(@"calling you progress label....");
        }
        else if( !alMessage.imageFilePath && alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"downloadI6.png"] forState:UIControlStateNormal];
            
        }
        else if (alMessage.imageFilePath && !alMessage.fileMeta.blobKey)
        {
            self.mDowloadRetryButton.alpha = 1;
            [self.mDowloadRetryButton setTitle:[alMessage.fileMeta getTheSize] forState:UIControlStateNormal];
            [self.mDowloadRetryButton setImage:[ALUtilityClass getImageFromFramworkBundle:@"uploadI1.png"] forState:UIControlStateNormal];
        }
        
    }
    
    self.mDowloadRetryButton.frame = CGRectMake(self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2.0 - 45 , self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height/2.0 - 20 , 90, 40);
    
    if ([alMessage.type isEqualToString:@MT_OUTBOX_CONSTANT]) {
        
        self.mMessageStatusImageView.hidden = NO;
        NSString * imageName;
        
        switch (alMessage.status.intValue) {
            case DELIVERED_AND_READ :{
                imageName = @"ic_action_read.png";
            }break;
            case DELIVERED:{
                imageName = @"ic_action_message_delivered.png";
            }break;
            case SENT:{
                imageName = @"ic_action_message_sent.png";
            }break;
            default:{
                imageName = @"ic_action_about.png";
            }break;
        }
        self.mMessageStatusImageView.image = [ALUtilityClass getImageFromFramworkBundle:imageName];
    }
    
    self.mDateLabel.text = theDate;
    
    theUrl = nil;
    if (alMessage.imageFilePath != NULL)
    {
        NSString * docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString * filePath = [docDir stringByAppendingPathComponent:alMessage.imageFilePath];
        theUrl = [NSURL fileURLWithPath:filePath];
       
//        NSLog(@"VCF_FILE_PATH : %@",filePath);
        
        alVCard = [ALVCardClass new];
        [alVCard vCardParser:filePath];
        
        [self.contactPerson setText:alVCard.fullName];
        [self.mUserProfileImageView setImage:alVCard.contactImage];
        [self.emailId setText:alVCard.userEMAIL_ID];
        [self.userContact setText:alVCard.userPHONE_NO];
        [self.addContactButton setEnabled:YES];
        
//         NSLog(@"DATA_IMAGE :%@",alVCard.contactImage);
    }
    
    self.contactProfileImage.layer.cornerRadius = self.contactProfileImage.frame.size.width/2;
    self.contactProfileImage.layer.masksToBounds = YES;
    
    self.mBubleImageView.layer.shadowOpacity = 0.3;
    self.mBubleImageView.layer.shadowOffset = CGSizeMake(0, 2);
    self.mBubleImageView.layer.shadowRadius = 1;
    self.mBubleImageView.layer.masksToBounds = NO;
    
    return self;
}

-(void)addButtonAction
{
    NSLog(@"BUTTON_ADD_SELECTOR_CALLED");
    if(!alVCard)
    {
        return;
    }
    [alVCard addContact:alVCard];
}

#pragma mark - KAProgressLabel Delegate Methods -

-(void)cancelAction
{
    if ([self.delegate respondsToSelector:@selector(stopDownloadForIndex:andMessage:)])
    {
        [self.delegate stopDownloadForIndex:(int)self.tag andMessage:self.mMessage];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)dowloadRetryActionButton
{
    [super.delegate downloadRetryButtonActionDelegate:(int)self.tag andMessage:self.mMessage];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    ALFileMetaInfo *metaInfo = (ALFileMetaInfo *)object;
    [self setNeedsDisplay];
    self.progresLabel.startDegree = 0;
    self.progresLabel.endDegree = metaInfo.progressValue;
//     NSLog(@"##observer is called....%f",self.progresLabel.endDegree );
}

-(void)setupProgress
{
    self.progresLabel = [[KAProgressLabel alloc] initWithFrame:CGRectMake(self.mBubleImageView.frame.origin.x + self.mBubleImageView.frame.size.width/2.0 - 25, self.mBubleImageView.frame.origin.y + self.mBubleImageView.frame.size.height/2.0 - 25, 50, 50)];
    self.progresLabel.delegate = self;
    [self.progresLabel setTrackWidth: 4.0];
    [self.progresLabel setProgressWidth: 4];
    [self.progresLabel setStartDegree:0];
    [self.progresLabel setEndDegree:0];
    [self.progresLabel setRoundedCornersWidth:1];
    self.progresLabel.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.3];
    self.progresLabel.trackColor = [UIColor colorWithRed:104.0/255 green:95.0/255 blue:250.0/255 alpha:1];
    self.progresLabel.progressColor = [UIColor whiteColor];
    [self.contentView addSubview:self.progresLabel];
    
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if([self.mMessage.type isEqualToString:@MT_OUTBOX_CONSTANT])
    {
        return (action == @selector(delete:)|| action == @selector(msgInfo:));
    }
    
    return (action == @selector(delete:));
}

-(void) delete:(id)sender
{
    //UI
//    NSLog(@"message to deleteUI %@",self.mMessage.message);
    
    [self.delegate deleteMessageFromView:self.mMessage];
    
    //serverCall
    [ALMessageService deleteMessage:self.mMessage.key andContactId:self.mMessage.contactIds withCompletion:^(NSString* string,NSError* error) {
        
        if(!error )
        {
            NSLog(@"No Error");
        }
        else{
            NSLog(@"some error");
        }
        
    }];
    
}

- (void)msgInfo:(id)sender
{
    UIStoryboard* storyboardM = [UIStoryboard storyboardWithName:@"Applozic" bundle:[NSBundle bundleForClass:ALChatViewController.class]];
    ALMessageInfoViewController *launchChat = (ALMessageInfoViewController *)[storyboardM instantiateViewControllerWithIdentifier:@"ALMessageInfoView"];
    
    [launchChat setMessage:self.mMessage andHeaderHeight:msgFrameHeight  withCompletionHandler:^(NSError *error) {
        
        if(!error)
        {
            [self.delegate loadView:launchChat];
        }
    }];
}

@end