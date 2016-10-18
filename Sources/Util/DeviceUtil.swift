import Foundation
import AVFoundation

#if os(iOS) || os(macOS)
public final class DeviceUtil {
    private init() {
    }
    
    static public weak var delegate: LFDelegate? = nil

    static public func device(withPosition:AVCaptureDevicePosition) -> LFCaptureDevice? {
        guard let delegate = delegate else { return nil }
        for device in delegate.getDevices() {
            guard let device:LFCaptureDevice = device as? LFCaptureDevice else {
                continue
            }
            if (device.hasMediaType(AVMediaTypeVideo) && device.position == withPosition) {
                return device
            }
        }
        return nil
    }

    static public func device(withLocalizedName:String, mediaType:String) -> LFCaptureDevice? {
        guard let delegate = self.delegate else { return nil }
        for device in delegate.getDevices() {
            guard let device:LFCaptureDevice = device as? LFCaptureDevice else {
                continue
            }
            if (device.hasMediaType(mediaType) && device.localizedName == withLocalizedName) {
                return device
            }
        }
        return nil
    }

    static func getActualFPS(_ fps:Float64, device:LFCaptureDevice) -> (fps:Float64, duration:CMTime)? {
        var durations:[CMTime] = []
        var frameRates:[Float64] = []

        for object:Any in device.videoSupportedFrameRateRanges {
            guard let range:AVFrameRateRange = object as? AVFrameRateRange else {
                continue
            }
            if (range.minFrameRate == range.maxFrameRate) {
                durations.append(range.minFrameDuration)
                frameRates.append(range.maxFrameRate)
                continue
            }
            if (range.minFrameRate <= fps && fps <= range.maxFrameRate) {
                return (fps, CMTimeMake(100, Int32(100 * fps)))
            }
            
            let actualFPS:Float64 = max(range.minFrameRate, min(range.maxFrameRate, fps))
            return (actualFPS, CMTimeMake(100, Int32(100 * actualFPS)))
        }
        
        var diff:[Float64] = []
        for frameRate in frameRates {
            diff.append(abs(frameRate - fps))
        }
        if let minElement:Float64 = diff.min() {
            for i in 0..<diff.count {
                if (diff[i] == minElement) {
                    return (frameRates[i], durations[i])
                }
            }
        }
        
        return nil
    }
}
#endif
