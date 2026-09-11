/*
 Copyright (c) 2010-2011 Filip Krikava
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <ServiceManagement/ServiceManagement.h>

#import "FMTUtils.h"
#import "FMTDefines.h"
#import "GTMLogger.h"

NSString *FMTGetBundleResourcePath(NSBundle *bundle, NSString *resourceName, NSString *resourceType) {
	FMTAssertNotNil(bundle);
	FMTAssertNotNil(resourceName);
	FMTAssertNotNil(resourceType);
	
	NSString *path = [bundle pathForResource:resourceName ofType:resourceType];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		return path;
	} else {
		return nil;
	}
}

NSString *FMTGetMainBundleResourcePath(NSString *resourceName, NSString *resourceType) {
	return FMTGetBundleResourcePath([NSBundle mainBundle], resourceName, resourceType);
}

NSURL *FMTGetBundleResourceURL(NSBundle *bundle, NSString *resourceName, NSString *resourceType) {	
	NSString *path = FMTGetBundleResourcePath(bundle, resourceName, resourceType);
	
	if (path) {
		return [NSURL fileURLWithPath:path];
	} else {
		return nil;
	}
}

NSURL *FMTGetMainBundleResourceURL(NSString *resourceName, NSString *resourceType) {	
	return FMTGetBundleResourceURL([NSBundle mainBundle], resourceName, resourceType);
}

BOOL FMTIsLoginItemEnabled(void) {
	return [SMAppService mainAppService].status == SMAppServiceStatusEnabled;
}

BOOL FMTSetLoginItemEnabled(BOOL enabled, NSError **error) {
	SMAppService *service = [SMAppService mainAppService];

	if (enabled) {
		return [service registerAndReturnError:error];
	} else {
		return [service unregisterAndReturnError:error];
	}
}
