import Foundation

open class NetService: NSObject {

    open var txtData:Data? {
        return nil
    }

    let lockQueue:DispatchQueue = DispatchQueue(label: "com.haishinkit.HaishinKit.NetService.lock")
    var networkQueue:DispatchQueue = DispatchQueue(label: "com.haishinkit.HaishinKit.NetService.network")

    fileprivate(set) var domain:String
    fileprivate(set) var name:String
    fileprivate(set) var port:Int32
    fileprivate(set) var type:String
    fileprivate(set) var running:Bool = false
    fileprivate(set) var clients:[NetClient] = []
    fileprivate(set) var service:Foundation.NetService!

    public init(domain:String, type:String, name:String, port:Int32) {
        self.domain = domain
        self.name = name
        self.port = port
        self.type = type
    }

    func disconnect(_ client:NetClient) {
        lockQueue.sync {
            guard let index:Int = clients.index(of: client) else {
                return
            }
            clients.remove(at: index)
            client.delegate = nil
            client.close(isDisconnected: true)
        }
    }

    func willStartRunning() {
        networkQueue.async {
            self.initService()
        }
    }

    func willStopRunning() {
        service.stop()
        service.delegate = nil
        service = nil
    }

    fileprivate func initService() {
        service = Foundation.NetService(domain: domain, type: type, name: name, port: port)
        service.delegate = self
        service.setTXTRecord(txtData)
        if (type.contains("._udp")) {
            service.publish()
        } else {
            service.publish(options: Foundation.NetService.Options.listenForConnections)
        }
    }
}

extension NetService: NetServiceDelegate {
    // MARK: NSNetServiceDelegate
    public func netService(_ sender: Foundation.NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        lockQueue.sync {
            let client:NetClient = NetClient(service: sender, inputStream: inputStream, outputStream: outputStream)
            clients.append(client)
            client.delegate = self
            client.acceptConnection()
        }
    }
}

extension NetService: NetClientDelegate {
    // MARK: NetClientDelegate
}

extension NetService: Runnable {
    // MARK: Runnbale
    final public func startRunning() {
        lockQueue.async {
            if (self.running) {
                return
            }
            self.willStartRunning()
            self.running = true
        }
    }

    final public func stopRunning() {
        lockQueue.async {
            if (!self.running) {
                return
            }
            self.willStopRunning()
            self.running = false
        }
    }
}
