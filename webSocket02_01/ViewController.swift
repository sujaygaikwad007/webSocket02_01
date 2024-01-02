import UIKit
import Starscream

class ViewController: UIViewController {
    var socket: WebSocket!
    var isConnected = false
    
    @IBOutlet weak var lblSocketMessage: UILabel!
    @IBOutlet weak var lblSocketConnection: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = URLRequest(url: URL(string: "wss://echo.websocket.org")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    
    
    func sendMessage() {
        if isConnected {
            let message = "hello there!"
            lblSocketMessage.text = message
            socket.write(string: message)
        }
        else
        {
            lblSocketMessage.text = "Nothing to show"
        }
    }
}

extension ViewController: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("WebSocket is connected: \(headers)")
            lblSocketConnection.text = "Connect"
            sendMessage()
        case .disconnected(let reason, let code):
            isConnected = false
            print("WebSocket is disconnected: \(reason) with code: \(code)")
            lblSocketConnection.text = "Disconnect"
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            lblSocketConnection.text = "Disconnect"
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("WebSocket encountered an error: \(e.message)")
        } else if let e = error {
            print("WebSocket encountered an error: \(e.localizedDescription)")
        } else {
            print("WebSocket encountered an error")
        }
    }
}
