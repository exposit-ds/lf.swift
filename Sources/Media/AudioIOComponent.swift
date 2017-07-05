import Foundation
import AVFoundation

final class AudioIOComponent: IOComponent {
    var encoder:AACEncoder = AACEncoder()
    var playback:AudioStreamPlayback = AudioStreamPlayback()
    let lockQueue:DispatchQueue = DispatchQueue(label: "com.haishinkit.HaishinKit.AudioIOComponent.lock")

#if os(iOS) || os(macOS)
    var input:LFCaptureDeviceInput? = nil {
        didSet {
            guard let mixer:AVMixer = mixer, oldValue !== input else {
                return
            }
            if let oldValue:LFCaptureDeviceInput = oldValue {
                mixer.session.removeInput(oldValue)
            }
            if let input:LFCaptureDeviceInput = input, mixer.session.canAddInput(input) {
                mixer.session.addInput(input)
            }
        }
    }

    private var _output:LFCaptureAudioDataOutput? = nil
    var output:LFCaptureAudioDataOutput? {
        get {
            return _output
        }
        set {
            if (_output === newValue) {
                return
            }
            if let output:LFCaptureAudioDataOutput = _output {
                output.setSampleBufferDelegate(nil, queue: nil)
                mixer?.session.removeOutput(output)
            }
            _output = newValue
        }
    }
#endif

    override init(mixer: AVMixer) {
        super.init(mixer: mixer)
        encoder.lockQueue = lockQueue
    }

#if os(iOS) || os(macOS)
    func attachAudio(_ audio:LFCaptureDevice?, automaticallyConfiguresApplicationAudioSession:Bool) throws {
        guard let mixer:AVMixer = mixer else {
            return
        }

        mixer.session.beginConfiguration()
        defer {
            mixer.session.commitConfiguration()
        }

        output = nil
        encoder.invalidate()

        guard let audio:LFCaptureDevice = audio else {
            input = nil
            return
        }

        input = try audio.createCaptureDeviceInput()
        output = audio.createCaptureAudioDataOutput()
        #if os(iOS)
        mixer.session.automaticallyConfiguresApplicationAudioSession = automaticallyConfiguresApplicationAudioSession
        #endif
        mixer.session.addOutput(output!)
        output!.setSampleBufferDelegate(self, queue: lockQueue)
    }

    func dispose() {
        input = nil
        output = nil
    }
#else
    func dispose() {
    }
#endif
}

extension AudioIOComponent: AVCaptureAudioDataOutputSampleBufferDelegate {
    // MARK: AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ captureOutput:AVCaptureOutput!, didOutputSampleBuffer sampleBuffer:CMSampleBuffer!, from connection:AVCaptureConnection!) {
        mixer?.recorder.appendSampleBuffer(sampleBuffer, mediaType: AVMediaTypeAudio)
        encoder.encodeSampleBuffer(sampleBuffer)
    }
}

