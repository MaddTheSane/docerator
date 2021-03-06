// makeicns
// Converts images to Apple's icns format.
// Written by nicolasweber@gmx.de, released under MIT license.
// Belongs to docerator, http://code.google.com/p/docerator/

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import <Cocoa/Cocoa.h>

#include "IconFamily.h"

#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_4
// This is defined in 10.5 and beyond in IconStorage.h
enum {
  kIconServices512PixelDataARGB = 'ic09' /* non-premultiplied 512x512 ARGB bitmap*/
};
#endif

#define VERSION "1.1 (20090413)"

void usage() {
  fprintf(stderr,
"makeicns v%s\n\n", VERSION);
  fprintf(stderr,
"Usage: makeicns [k1=v1] [k2=v2] ...\n\n");
  fprintf(stderr,
"Keys and values include:\n");
  fprintf(stderr,
"   1024: Name of input image for 1024x1024 variant of icon\n");
  fprintf(stderr,
"    512: Name of input image for 512x512 variant of icon\n");
  fprintf(stderr,
"    256: Name of input image for 256x256 variant of icon\n");
  fprintf(stderr,
"    128: Name of input image for 128x128 variant of icon\n");
  fprintf(stderr,
"     32: Name of input image for 32x32 variant of icon\n");
  fprintf(stderr,
"     16: Name of input image for 16x16 variant of icon\n");
  fprintf(stderr,
"     in: Name of input image for all variants not having an explicit name\n");
  fprintf(stderr,
"    out: Name of output file, defaults to first nonempty input name,\n"
"         but with icns extension\n\n");
  fprintf(stderr,
"Examples:\n\n"
"  makeicns -512 image.png -32 image.png\n"
"      Creates image.icns with only a 512x512 and a 32x32 variant.\n\n"
"  makeicns -in myfile.jpg -32 otherfile.png -out outfile.icns\n"
"      Creates outfile.icns with sizes 512, 256, 128, and 16 containing data\n"
"      from myfile.jpg and with size 32 containing data from otherfile.png.\n");
  exit(1);
}


NSBitmapImageRep* getBitmapImageRepOfSize(NSImage* img, int size) {

  // Don't resample if it's not necessary
#if 0
  // IconFamily does not work correctly with
  // NSAlphaNonpremultipliedBitmapFormat images, so this has to stay disabled
  // until IconFamily is fixed (if ever).
  NSEnumerator* e = [[img representations] objectEnumerator];
  NSImageRep* ir;
  while ((ir = [e nextObject])) {
    if (![ir isKindOfClass:[NSBitmapImageRep class]]) continue;

    NSBitmapImageRep* br = (NSBitmapImageRep*)ir;
    //NSLog(@"%@", br);
    if ([br pixelsWide] == size && [br pixelsHigh] == size
        && ([[br colorSpaceName] isEqualToString:NSDeviceRGBColorSpace]
          || [[br colorSpaceName] isEqualToString:NSCalibratedRGBColorSpace])
        && ([br bitsPerPixel] == 24 || [br bitsPerPixel] == 32)
       )
      return br;
  }
#endif

  NSLog(@"Resampling for size %d", size);
  NSBitmapImageRep* r = [[NSBitmapImageRep alloc]
    initWithBitmapDataPlanes:NULL
                       pixelsWide:size
                       pixelsHigh:size
                    bitsPerSample:8
                  samplesPerPixel:4
                         hasAlpha:YES
                         isPlanar:NO
                   colorSpaceName:NSDeviceRGBColorSpace
                     bitmapFormat:0
                      bytesPerRow:0
                     bitsPerPixel:0];

  [NSGraphicsContext saveGraphicsState];
  NSGraphicsContext* context = [NSGraphicsContext
    graphicsContextWithBitmapImageRep:r];
  [context setShouldAntialias:YES];
  [context setImageInterpolation:NSImageInterpolationHigh];
  [NSGraphicsContext setCurrentContext:context];

  [img drawInRect:NSMakeRect(0, 0, size, size)
         fromRect:NSZeroRect
        operation:NSCompositeCopy
         fraction:1.0];

  [NSGraphicsContext restoreGraphicsState];

  return r;
}


int main(int argc, char* argv[]) {
  int i;

  @autoreleasepool {
  NSApplicationLoad();

  struct {
    NSString* paramName;
    OSType type, mask;
    int size;
    NSString* inputName;
  } inputs[] = {
    { @"1024", kIconServices1024PixelDataARGB, 0, 1024, nil },
    { @"512", kIconServices512PixelDataARGB, 0, 512, nil },
    { @"256", kIconServices256PixelDataARGB, 0, 256, nil },
    { @"128", kIconServices128PixelDataARGB, 0, 128, nil },
    { @"32", kIconServices32PixelDataARGB, 0, 32, nil },
    { @"16", kIconServices16PixelDataARGB, 0, 16, nil },
  };
  const int N = sizeof(inputs)/sizeof(inputs[0]);

  // Process arguments -- Thanks Greg!
  //http://unixjunkie.blogspot.com/2006/07/command-line-processing-in-cocoa.html
  NSUserDefaults* args = [NSUserDefaults standardUserDefaults];

  BOOL foundInputParam = NO;
  NSString* outputName = [args stringForKey:@"out"];
  NSString* defaultIn = [args stringForKey:@"in"];
  for (i = 0; i < N; ++i) {
    inputs[i].inputName = [args stringForKey:inputs[i].paramName];
    if (inputs[i].inputName == nil)
      inputs[i].inputName = defaultIn;
    foundInputParam = foundInputParam || inputs[i].inputName != nil;

    // Create default output name if necessary
    if (outputName == nil && inputs[i].inputName != nil)
      outputName = [[inputs[i].inputName stringByDeletingPathExtension]
          stringByAppendingPathExtension:@"icns"];
  }

  if (!foundInputParam)
    usage();

  // Create output
  IconFamily* output = [IconFamily iconFamily];

  for (i = 0; i < N; ++i) {
    if (inputs[i].inputName == nil) continue;
    NSImage* img = [[[NSImage alloc] initWithContentsOfFile:inputs[i].inputName]
      autorelease];

    NSBitmapImageRep* rep = getBitmapImageRepOfSize(img, inputs[i].size);
    [output setIconFamilyElement:inputs[i].type fromBitmapImageRep:rep];
    if (inputs[i].mask != 0)
      [output setIconFamilyElement:inputs[i].mask fromBitmapImageRep:rep];
  }

  // Write output
  if ([output writeToFile:outputName])
    NSLog(@"Wrote output file \"%@\"", outputName);
  else
    NSLog(@"Failed to write \"%@\"", outputName);

  }
  return 0;
}
