//
//  ChatViewController.m
//  iPhoneXMPP
//
//  Created by Zhe Zhang on 8/29/16.
//  Copyright © 2016 XMPPFramework. All rights reserved.
//

#import "ChatViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "iPhoneXMPPAppDelegate.h"
#import "XMPPFramework.h"
#import "JSQSystemSoundPlayer.h"
#import "DDLog.h"

@implementation ChatViewController


-(void) viewDidLoad
{
    [super viewDidLoad];
    iPhoneXMPPAppDelegate *appDelegate = (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[appDelegate xmppStream] addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
    self.messages = [[NSMutableArray alloc] init];
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *context = storage.mainThreadManagedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr like %@ " argumentArray:@[self.user.jidStr]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = entityDescription;
    request.predicate = predicate;
    
    NSError *error=nil;;
    NSArray *msgFetchArray = [context executeFetchRequest:request error:&error];
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in msgFetchArray) {
        
        JSQMessage *jsqm = [[JSQMessage alloc] initWithSenderId:(message.isOutgoing? self.senderId:message.bareJidStr) senderDisplayName:(message.isOutgoing? self.senderId:message.bareJidStr) date:message.timestamp text:message.body];
        [self.messages addObject:jsqm];
    }
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell*)collectionView:(JSQMessagesCollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    JSQMessage* msg = [self.messages objectAtIndex:indexPath.item];

    JSQMessagesCollectionViewCell* cell = (JSQMessagesCollectionViewCell*)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    printf("msg user id: %s  self user id: %s msg: %s\n", msg.senderId.UTF8String, self.senderId.UTF8String, msg.text.UTF8String);
    
    if (msg.isMediaMessage == NO) {
        if ([self isIncomingMessage:msg]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
    }
    return cell;
}

- (id <JSQMessageData> )collectionView:(JSQMessagesCollectionView*)collectionView messageDataForItemAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id <JSQMessageBubbleImageDataSource> )collectionView:(JSQMessagesCollectionView*)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath*)indexPath
{
    JSQMessage* msg = [self.messages objectAtIndex:indexPath.item];
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    if ([self isIncomingMessage: msg]) {
        return [bubbleFactory incomingMessagesBubbleImageWithColor: [UIColor greenColor]];
    }
    else
    {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor: [UIColor lightGrayColor]];
    }
}

- (id <JSQMessageAvatarImageDataSource> )collectionView:(JSQMessagesCollectionView*)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath*)indexPath
{
    JSQMessage* msg = [self.messages objectAtIndex:indexPath.item];
    iPhoneXMPPAppDelegate *appDelegate = (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIImage *userImage = nil;
    if ([self isIncomingMessage:msg])  {
        NSData *photoData = [[appDelegate xmppvCardAvatarModule] photoDataForJID: [XMPPJID jidWithString: msg.senderId]];
        userImage = [UIImage imageWithData:photoData];
    }
    else {
        if (self.user.photo != nil)
        {
            userImage = self.user.photo;
        }
        else
        {
            NSData *photoData = [[appDelegate xmppvCardAvatarModule] photoDataForJID:self.user.jid];
            userImage = [UIImage imageWithData:photoData];
        }
    }
    
    if (userImage) {
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:userImage diameter:30];
    }
    else {
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"defaultPerson"] diameter:30];        ;
    }
}

- (BOOL) isIncomingMessage:(JSQMessage *)msg
{
    return ![msg.senderId isEqualToString:self.senderId];
}


#pragma mark - JSQMessagesViewController method overrides
- (void)didPressSendButton:(UIButton*)button
           withMessageText:(NSString*)text
                  senderId:(NSString*)senderId
         senderDisplayName:(NSString*)senderDisplayName
                      date:(NSDate*)date
{
    iPhoneXMPPAppDelegate *appDelegate = (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate sendMessage:text fromUser:self.user.jidStr];

    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:[NSDate date] text:text];
    [self.messages addObject:message];
    [self finishSendingMessageAnimated:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStreamDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
//    JSQMessage *jsqm = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] text:message.body];
//    [self.messages addObject:jsqm];
//    [self.collectionView reloadData];
//  
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    if ([message isChatMessageWithBody]) {
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        
        NSString *senderId = [message from].bare;
        JSQMessage *msg = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderId date:[NSDate date] text:message.body];

        [self.messages addObject:msg];
        [self finishReceivingMessageAnimated:YES];
    }
}

@end
