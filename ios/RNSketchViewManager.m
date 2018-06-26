#import "RNSketchViewManager.h"

@implementation RNSketchViewManager

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_CUSTOM_VIEW_PROPERTY(selectedTool, NSInteger, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView.subviews[0] : view.subviews[0];
    [currentView.sketchView setToolType:[RCTConvert NSInteger:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(toolColor, UIColor, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView.subviews[0] : view.subviews[0];
    [currentView.sketchView setToolColor:[RCTConvert UIColor:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(toolThickness, NSInteger, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView.subviews[0] : view.subviews[0];
    [currentView.sketchView setToolThickness:[RCTConvert NSInteger:json]];
}

RCT_CUSTOM_VIEW_PROPERTY(localSourceImagePath, NSString, SketchViewContainer)
{
    SketchViewContainer *currentView = !view ? defaultView.subviews[0] : view.subviews[0];
    NSString *localFilePath = [RCTConvert NSString:json];
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentView openSketchFile:localFilePath];
    });
}

RCT_EXPORT_MODULE(RNSketchView)

-(UIView *)view
{
    // Must wrap in parent view since RN messes up the frame: https://github.com/facebook/react-native/issues/2948
    self.sketchViewContainer = [[[NSBundle mainBundle] loadNibNamed:@"SketchViewContainer" owner:self options:nil] firstObject];
    UIView *parent = [[UIView alloc]initWithFrame:self.sketchViewContainer.bounds];
    [self.sketchViewContainer setBackgroundColor:[UIColor clearColor]];
    [parent setBackgroundColor:[UIColor clearColor]];
    [parent addSubview:self.sketchViewContainer];
    return parent;
}

RCT_EXPORT_METHOD(saveSketch:(nonnull NSNumber *)reactTag) {
    dispatch_async(dispatch_get_main_queue(), ^{
        SketchFile *sketchFile = [self.sketchViewContainer saveToLocalCache];
        [self onSaveSketch:sketchFile];
    });
}

RCT_EXPORT_METHOD(clearSketch:(nonnull NSNumber *)reactTag) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sketchViewContainer.sketchView clear];
    });
}

RCT_EXPORT_METHOD(changeTool:(nonnull NSNumber *)reactTag toolId:(NSInteger) toolId) {
    [self.sketchViewContainer.sketchView setToolType:toolId];
}

-(void)onSaveSketch:(SketchFile *) sketchFile
{
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"onSaveSketch" body:
  @{
    @"localFilePath": sketchFile.localFilePath,
    @"imageWidth": [NSNumber numberWithFloat:sketchFile.size.width],
    @"imageHeight": [NSNumber numberWithFloat:sketchFile.size.height]
    }];
}

@end
