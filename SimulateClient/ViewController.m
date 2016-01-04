//
//  ViewController.m
//  SimulateClient
//
//  Created by leiiwang on 15/12/30.
//  Copyright © 2015年 wangleo. All rights reserved.
//

#import "ViewController.h"
#import "MyButton.h"
#import <Foundation/Foundation.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>
#include <netinet/tcp.h>
#include <netinet/in.h>

@interface ViewController ()


@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;

@property (nonatomic, retain) IBOutlet UITextField	*inputNameField;

@property (nonatomic, retain) NSMutableArray *messages;
@property (strong, nonatomic) IBOutletCollection(MyButton) NSArray *btns;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *codes;
@property (nonatomic, strong) NSTimer *timer;

- (IBAction)toggleCode:(id)sender;
- (IBAction) connect;

- (void) initNetworkCommunication;
- (void) sendMessage;
- (void) messageReceived:(NSString *)message;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inputNameField.text = @"10.72.141.25";
    _messages = [[NSMutableArray alloc] init];
    for (MyButton *btn in self.btns) {
        btn.delegate = self;
    }
}

- (void)disableNaglesAlgorithmForStream:(NSStream *)stream {

    CFDataRef socketData;

    // Get socket data
    if ([stream isKindOfClass:[NSOutputStream class]]) {
        socketData = CFWriteStreamCopyProperty((__bridge CFWriteStreamRef)((NSOutputStream *)stream), kCFStreamPropertySocketNativeHandle);
    } else if ([stream isKindOfClass:[NSInputStream class]]) {
        socketData = CFReadStreamCopyProperty((__bridge CFReadStreamRef)((NSInputStream *)stream), kCFStreamPropertySocketNativeHandle);
    }

    // get a handle to the native socket
    CFSocketNativeHandle rawsock;

    CFDataGetBytes(socketData, CFRangeMake(0, sizeof(CFSocketNativeHandle)), (UInt8 *)&rawsock);
    CFRelease(socketData);

    // Disable Nagle's algorythm

    // Debug info
    BOOL isInput = [stream isKindOfClass:[NSInputStream class]];
    NSString * streamType = isInput ? @"INPUT" : @"OUTPUT";

    int err;
    static const int kOne = 1;
    err = setsockopt(rawsock, IPPROTO_TCP, TCP_NODELAY, &kOne, sizeof(kOne));
    if (err < 0) {
        err = errno;
        NSLog(@"Could Not Disable Nagle for %@ stream", streamType);
    } else {
        NSLog(@"Nagle Is Disabled for %@ stream", streamType);
    }
}

- (void) initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.inputNameField.text, 9999, &readStream, &writeStream);
    
    _inputStream = (__bridge NSInputStream *)readStream;
    _outputStream = (__bridge NSOutputStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    
    
}

- (IBAction) connect {
    [self.inputNameField resignFirstResponder];
    [self initNetworkCommunication];
}



- (void) sendMessage:(NSString*)s {
    if (s.length == 0) {
        return;
    }
    NSData *data = [[NSData alloc] initWithData:[s dataUsingEncoding:NSASCIIStringEncoding]];
    [_outputStream write:[data bytes] maxLength:[data length]];
}


- (void)showAlert:(NSString*)alertmsg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:alertmsg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %i", streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            if (theStream == _outputStream){
                [self disableNaglesAlgorithmForStream:_outputStream];
                [self showAlert:@"连接成功"];
            }
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            if (theStream == _inputStream) {
                uint8_t buffer[1024];
                int len;
                
                while ([_inputStream hasBytesAvailable]) {
                    len = [_inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            
                            NSLog(@"server said: %@", output);
                            [self messageReceived:output];
                            
                        }
                    }
                }
            }
            break;
            
            
        case NSStreamEventErrorOccurred:
            [self showAlert:@"连接失败"];
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            
            break;
        default:
            NSLog(@"Unknown event");
    }
    
}

- (void) messageReceived:(NSString *)message{
    NSLog(@"%@", message);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)touchBegin:(MyButton*)btn{
    NSString *codes = btn.codeFiled.text;
    int codei = codes.integerValue;
    if (codei == 0) {
        codei = 54;
    }
    NSString *codec = [NSString stringWithFormat:@"%d:" , codei];
    NSLog(@"touchBegin%d", codei);
    [self sendMessage:codec];
}

-(void)touchEnd:(MyButton*)btn{
    NSString *codes = btn.codeFiled.text;
    int codei = codes.integerValue;
    if (codei == 0) {
        codei = 54;
    }
    NSString *codec = [NSString stringWithFormat:@"%d:" , codei + 127];
     NSLog(@"touchEnd%d", codei);
    [self sendMessage:codec];
}


- (IBAction)toggleCode:(id)sender {
    for (UITextField *field in self.codes){
        field.hidden = !field.isHidden;
    }
}
@end
