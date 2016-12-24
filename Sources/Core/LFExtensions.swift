//
//  LFExtensions.swift
//  Pods
//
//  Created by Pavel Dyakov on 10/13/16.
//
//

import Cocoa

extension AVMixer: AdditionalOutput {
    
    func addOutput(output: LFCaptureOutput!) {
        
        if session != nil && session!.canAddOutput(output) {
            session!.beginConfiguration()
            session!.addOutput(output)
            session!.commitConfiguration()
        }
    }
    
    func removeOutput(output: LFCaptureOutput!) {
        if let session = session {
            session.beginConfiguration()
            session.removeOutput(output)
            session.commitConfiguration()
        }
    }
}

extension HTTPStream: AdditionalOutput {
    
    public func addOutput(output: LFCaptureOutput!) {
        self.mixer.addOutput(output: output)
    }
    
    public func removeOutput(output: LFCaptureOutput!) {
        self.mixer.removeOutput(output: output)
    }
}

protocol TSWriterDelegate: class {
    func tsWriterReady(tsWriter: TSWriter)
}

public protocol HTTPStreamDelegate: class {
    func httpStreamReady(httpStream: HTTPStream)
}

extension HTTPStream: TSWriterDelegate {
    
    func tsWriterReady(tsWriter: TSWriter) {
        delegate?.httpStreamReady(httpStream: self)
    }
}
