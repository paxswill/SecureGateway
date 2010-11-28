//
//  PXConnection.h
//  SStore
//
//  Created by Will Ross on 11/27/10.
//  Copyright (c) 2010 Will Ross. All rights reserved.
//
#import "PXConnection.h"

@interface PXConnection()

@property (readwrite, nonatomic, getter=isConnected) BOOL connected;
@property (readwrite, nonatomic, getter=isSecure) BOOL secure;

@end


@implementation PXConnection

//Sockets
@synthesize mainSocket;
@synthesize port;

//SSL
@synthesize sslContext;
@synthesize sslConnection;
@synthesize bioConnection;
@synthesize pemPassword;

//Status
@synthesize delegate;
@synthesize connected;
@synthesize secure;

- (id)init {
    if ((self = [super init])) {
        //Set a default port
		//6968 is an unregistered port (but within the IANA registered port range)
		//I just chose it as it was my student number in middle school
		port = 6968;
		//Set default/sentinel values to the file handles
		mainSocket = INT_MIN;
		connected = NO;
		
		//Initialize OpenSSL
		SSL_load_error_strings();
		ERR_load_BIO_strings();
		OpenSSL_add_all_algorithms();
		SSL_library_init();
		SSL_METHOD *method = TLSv1_method();
		sslContext = SSL_CTX_new(method);
		secure = NO;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

-(void)send:(NSData *)data{
	//Abstract method!
	//This may seem a bit odd at first, but it's working 
	//around a limitation of Obj-C. Obj-C does not have 
	//native abstract classes. This method forces the runtime
	//to think that this methods doesn't work. Basically, 
	//it must be subclassed. _cmd is the last called selector.
	[self doesNotRecognizeSelector:_cmd];
}

-(void)setRecieve{
	[self doesNotRecognizeSelector:_cmd];
}

#pragma mark -
#pragma mark SSL Methods

//This is a private method, used only in the method below it
int getPemPassword(char *buffer, int size, int rwflag, void *userdata){
	if(userdata != NULL){
		//Userdata is an NSString
		NSString *password = userdata;
		int pwLength = [password length];
		//Convert the password to a C-String
		const char *sourceBuffer = [password UTF8String];
		//Copy the temp buffer to the real buffer
		//This is because sourceBuffer will disappear when password does
		char *destBuffer = malloc(sizeof(char) * (pwLength + 1));
		memcpy((void *)sourceBuffer, (void *)destBuffer, (sizeof(char) * (pwLength + 1)));
		return pwLength;
	}else{
		return 0;
	}
}

-(void)loadKey:(NSURL*)privateKey withPassword:(NSString*)password{
	//Set userdata
	self.pemPassword = password;
	SSL_CTX_set_default_passwd_cb_userdata(self.sslContext, self.pemPassword);
	//This feels a bit hacky
	SSL_CTX_set_default_passwd_cb(self.sslContext, getPemPassword);
	//Actually load the key file in
	SSL_CTX_use_PrivateKey_file(self.sslContext, [[privateKey path] UTF8String], SSL_FILETYPE_PEM);
}

-(void)loadCA:(NSURL*)certificate{
	SSL_CTX_use_certificate_file(self.sslContext, [[certificate path] UTF8String], SSL_FILETYPE_PEM);
}



-(void)prepareSSLConnection{
	//Force client verification, using the default checking
	SSL_CTX_set_verify(self.sslContext, SSL_VERIFY_FAIL_IF_NO_PEER_CERT, NULL);
	//Make the SSL object
	self.sslConnection = SSL_new(self.sslContext);
	//Make and configure the BIO object
	self.bioConnection = BIO_new(BIO_s_socket());
	BIO_set_fd(self.bioConnection, self.mainSocket, BIO_NOCLOSE);
	//Bind the BIO and SSL objects together
	SSL_set_bio(self.sslConnection, self.bioConnection, self.bioConnection);
}

-(BOOL)openSSLConnection{
	//Abstract!
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
