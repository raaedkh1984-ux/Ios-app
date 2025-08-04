import SwiftUI
import AVFoundation

struct QRCodeScanner: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool
    let onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {
        if isScanning {
            uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QRScannerViewControllerDelegate {
        let parent: QRCodeScanner
        
        init(_ parent: QRCodeScanner) {
            self.parent = parent
        }
        
        func qrScannerViewController(_ controller: QRScannerViewController, didScanCode code: String) {
            parent.scannedCode = code
            parent.onCodeScanned(code)
            parent.isScanning = false
        }
        
        func qrScannerViewController(_ controller: QRScannerViewController, didFailWith error: Error) {
            print("QR Scanner failed: \(error.localizedDescription)")
        }
    }
}

protocol QRScannerViewControllerDelegate: AnyObject {
    func qrScannerViewController(_ controller: QRScannerViewController, didScanCode code: String)
    func qrScannerViewController(_ controller: QRScannerViewController, didFailWith error: Error)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isScanning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isScanning {
            startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.qrScannerViewController(self, didFailWith: NSError(domain: "QRScanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Camera not available"]))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.qrScannerViewController(self, didFailWith: error)
            return
        }
        
        captureSession = AVCaptureSession()
        
        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        } else {
            delegate?.qrScannerViewController(self, didFailWith: NSError(domain: "QRScanner", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot add video input"]))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession?.canAddOutput(metadataOutput) == true {
            captureSession?.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            delegate?.qrScannerViewController(self, didFailWith: NSError(domain: "QRScanner", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot add metadata output"]))
            return
        }
        
        setupPreviewLayer()
    }
    
    private func setupPreviewLayer() {
        guard let captureSession = captureSession else { return }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        // Add overlay view for scanning area
        let overlayView = createOverlayView()
        view.addSubview(overlayView)
        view.bringSubviewToFront(overlayView)
    }
    
    private func createOverlayView() -> UIView {
        let overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let scanAreaSize: CGFloat = 250
        let scanArea = UIView(frame: CGRect(x: (view.bounds.width - scanAreaSize) / 2,
                                          y: (view.bounds.height - scanAreaSize) / 2,
                                          width: scanAreaSize,
                                          height: scanAreaSize))
        scanArea.backgroundColor = UIColor.clear
        scanArea.layer.borderColor = UIColor.white.cgColor
        scanArea.layer.borderWidth = 2
        scanArea.layer.cornerRadius = 12
        
        // Create transparent hole in overlay
        let path = UIBezierPath(rect: overlayView.bounds)
        let scanAreaPath = UIBezierPath(roundedRect: scanArea.frame, cornerRadius: 12)
        path.append(scanAreaPath.reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        overlayView.addSubview(scanArea)
        
        // Add scanning line animation
        let scanningLine = UIView(frame: CGRect(x: 0, y: 0, width: scanAreaSize, height: 2))
        scanningLine.backgroundColor = UIColor.systemBlue
        scanArea.addSubview(scanningLine)
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            scanningLine.frame.origin.y = scanAreaSize - 2
        })
        
        return overlayView
    }
    
    func startScanning() {
        guard let captureSession = captureSession, !captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
            DispatchQueue.main.async {
                self?.isScanning = true
            }
        }
    }
    
    func stopScanning() {
        guard let captureSession = captureSession, captureSession.isRunning else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
            DispatchQueue.main.async {
                self?.isScanning = false
            }
        }
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.qrScannerViewController(self, didScanCode: stringValue)
        }
    }
}

// MARK: - SwiftUI Wrapper
struct QRScannerView: View {
    @Binding var isPresented: Bool
    @Binding var scannedCode: String
    let onCodeScanned: (String) -> Void
    
    @State private var isScanning = true
    
    var body: some View {
        ZStack {
            QRCodeScanner(scannedCode: $scannedCode, isScanning: $isScanning) { code in
                onCodeScanned(code)
                isPresented = false
            }
            
            VStack {
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                Text("Scan QR Code to Unlock Scooter")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}