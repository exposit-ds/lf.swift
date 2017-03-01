import Foundation
import AVFoundation

protocol BytesConvertible {
    var bytes:[UInt8] { get set }
}

// MARK: -
protocol Runnable: class {
    var running:Bool { get }
    func startRunning()
    func stopRunning()
}

// MARK: -
protocol Iterator {
    associatedtype T
    func hasNext() -> Bool
    func next() -> T?
}

protocol AdditionalOutput {
    func addOutput(output: LFCaptureOutput!)
    func removeOutput(output: LFCaptureOutput!)
}

public protocol LFCaptureDevice: class {
    var localizedName: String { get }
    var uniqueID: String { get }
    var videoWidth: Int { get }
    var videoHeight: Int { get }
    var position:AVCaptureDevicePosition { get }
    var torchMode: AVCaptureTorchMode { get set }
    var focusMode: AVCaptureFocusMode { get set }
    var exposureMode: AVCaptureExposureMode { get set }
    var videoSupportedFrameRateRanges: [Any] { get }
    var isExposurePointOfInterestSupported: Bool { get }
    var isFocusPointOfInterestSupported: Bool { get }
    var focusPointOfInterest: CGPoint { get set }
    var exposurePointOfInterest: CGPoint { get set }
    var activeVideoMinFrameDuration: CMTime { get set }
    var activeVideoMaxFrameDuration: CMTime { get set }
    
    func lockForConfiguration() throws
    func unlockForConfiguration()
    func isTorchModeSupported(_ torchMode: AVCaptureTorchMode) -> Bool
    func isFocusModeSupported(_ focusMode: AVCaptureFocusMode) -> Bool
    func isExposureModeSupported(_ exposureMode: AVCaptureExposureMode) -> Bool
    func hasMediaType(_ mediaType: String) -> Bool
    
    func createCaptureDeviceInput() throws -> LFCaptureDeviceInput
    func createCaptureAudioDataOutput() -> LFCaptureAudioDataOutput
    func createCaptureVideoDataOutput() -> LFCaptureVideoDataOutput
}

public protocol LFCaptureInput: class {
    var device: LFCaptureDevice { get }
    var input: AVCaptureInput? { get }
}

public protocol LFCaptureOutput: class {
    var output: AVCaptureOutput { get }
}

public protocol LFCaptureVideoDataOutput: LFCaptureOutput {
    var videoSettings: [AnyHashable : Any] { get set }
    var alwaysDiscardsLateVideoFrames: Bool { get set }
    var connections: [Any] { get }
    func setSampleBufferDelegate(_ sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate!, queue sampleBufferCallbackQueue: DispatchQueue!)
}

public protocol LFCaptureConnection: class {
    
}

public protocol LFCaptureAudioDataOutput: LFCaptureOutput {
    func setSampleBufferDelegate(_ sampleBufferDelegate: AVCaptureAudioDataOutputSampleBufferDelegate!, queue sampleBufferCallbackQueue: DispatchQueue!)
}

public protocol LFCaptureScreenInput: LFCaptureInput {
}

public protocol LFCaptureDeviceInput: LFCaptureInput {
    init(_ device: LFCaptureDevice) throws
    var device: LFCaptureDevice { get }
}

public protocol LFCaptureSession: class {
    var sessionPreset: String { get set }
    var isRunning: Bool { get }
    
    func beginConfiguration()
    func commitConfiguration()
    func canAddOutput(_ output: LFCaptureOutput) -> Bool
    func addOutput(_ output: LFCaptureOutput)
    func addInput(_ input: LFCaptureInput)
    func removeOutput(_ output: LFCaptureOutput)
    func removeInput(_ input: LFCaptureInput)
    func startRunning()
    func stopRunning()
}

public protocol LFDelegate: class {
    
    func createCaptureSession() -> LFCaptureSession
    func getDevices() -> Array<LFCaptureDevice>
}
