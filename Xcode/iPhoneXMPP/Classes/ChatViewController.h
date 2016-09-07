//
//  ChatViewController.h
//  iPhoneXMPP
//
//  Created by Zhe Zhang on 8/29/16.
//  Copyright © 2016 XMPPFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "XMPPFramework.h"

@class NSFetchedResultsController;
@class XMPPUserCoreDataStorageObject;
@class JSQMessage;

@interface ChatViewController : JSQMessagesViewController <XMPPStreamDelegate> {
}

@property (nonatomic, strong) NSMutableArray <JSQMessage*> *messages;
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *user;
@end
