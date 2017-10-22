extension HTTP2Client {
    func processSettings(from frame: Frame) throws {
        guard frame.streamIdentifier == 0 else {
            throw Error(.invalidStreamIdentifier)
        }
        
        if frame.flags & 0x01 == 0x01 {
            // Acknowledgement
            self.updatingSettings = false
        } else {
            do {
                try self.remoteSettings.update(to: frame)
            } catch {
                self.frameSerializer.inputStream(ResetFrame(code: .frameSizeError, stream: frame.streamIdentifier).frame)
                return
            }
            self.frameSerializer.inputStream(HTTP2Settings.acknowledgeFrame)
            
            if !self.future.isCompleted {
                self.promise.complete(self)
            }
        }
    }
    
    func processTopLevelStream(from frame: Frame) throws {
        guard
            frame.type == .settings || frame.type == .ping  ||
            frame.type == .priority || frame.type == .reset ||
            frame.type == .goAway   || frame.type == .windowUpdate
        else {
            throw Error(.invalidStreamIdentifier)
        }
        
        switch frame.type {
        case .settings:
            try self.processSettings(from: frame)
        case .ping:
            fatalError()
        case .priority:
            fatalError()
        case .reset:
            fatalError()
        case .goAway:
            fatalError()
        case .windowUpdate:
            let update = try WindowUpdate(frame: frame, errorsTo: frameSerializer)
            
            if let windowSize = windowSize {
                self.windowSize = windowSize &+ numericCast(update.windowSize) as UInt64
            } else {
                windowSize = numericCast(update.windowSize)
            }
        default:
            throw Error(.invalidStreamIdentifier)
        }
    }
}
