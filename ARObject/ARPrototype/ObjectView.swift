//
//  ObjectView.swift
//  ARObject
//
//  Created by Bogdan Petkanych on 27.07.2024.
//

import UIKit
import ARKit
import SceneKit
import SceneKit.ModelIO
import simd

final class ObjectView: UIView {
  lazy private var sceneView: ARSCNView = {
    let view = ARSCNView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    
    return view
  }()
  
  lazy private var placeButton: UIButton = {
    let placeButton = UIButton()
    placeButton.translatesAutoresizingMaskIntoConstraints = false
    placeButton.addTarget(self, action: #selector(didTapPlaceButton), for: .touchUpInside)
    var configuration = UIButton.Configuration.plain()
    configuration.title = "Place"
    configuration.background.backgroundColor = .link
    configuration.baseForegroundColor = .white
    placeButton.configuration = configuration
    
    return placeButton
  }()
  
  var cameraDirection: simd_float3? {
    guard let transform = sceneView.session.currentFrame?.camera.transform else {
      return nil
    }
    
    return simd_float3(transform.columns.3.x * -1, transform.columns.3.y * -1, transform.columns.3.z * -1)
  }
  
  private var objectNode: SCNNode?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    loadView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func runSession() {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = [.horizontal, .vertical]
    sceneView.session.delegate = self
    sceneView.session.run(configuration)
  }
  
  func loadObject(by url: URL, with completion: @escaping (Result<Void, Error>) -> Void) {
    Task { [weak self] in
      do {
        let fileName = Data(url.lastPathComponent.utf8).base64EncodedString()
        let fileExtension = url.pathExtension
        let modelPath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        let model: MDLAsset
        if !FileManager.default.fileExists(atPath: modelPath.path) {
          let data = try Data(contentsOf: url)
          try data.write(to: modelPath)
        }
        model = MDLAsset(url: modelPath)
        model.loadTextures()
        self?.objectNode = SCNNode(mdlObject: model.object(at: 0))
        await MainActor.run {
          completion(.success(()))
        }
      } catch {
        await MainActor.run {
          completion(.failure(error))
        }
      }
    }
  }
  
  private func createTextNode(text: String, color: UIColor) -> SCNText {
    let textNode = SCNText(string: text, extrusionDepth: 1)
    textNode.font = .systemFont(ofSize: 20, weight: .bold)
    textNode.firstMaterial?.diffuse.contents = color
    return textNode
  }
  
  @IBAction private func didTapPlaceButton(_ sender: UIButton) {
    guard let objectNode, let poi = sceneView.pointOfView else {
      return
    }
    let distance: Float = 10
    let scale: Float = 0.3
    let simdPosition = poi.simdPosition + normalize(poi.simdWorldFront) * distance
    
    objectNode.simdTransform = simd_float4x4.translation(m: .identityMatrix, tx: simdPosition.x, ty: simdPosition.y, tz: simdPosition.z)
    objectNode.simdTransform = simd_float4x4.sclale(m: objectNode.simdTransform, sx: scale, sy: scale, sz: scale)
    let rootNode = sceneView.scene.rootNode
    objectNode.simdPosition = simdPosition
   	var objectEulerAngles = SCNVector3(0, 0, 0)
    objectEulerAngles.x = 0
    objectEulerAngles.y = 0
    objectEulerAngles.z = .pi
    objectNode.eulerAngles = objectEulerAngles
    if objectNode.parent == nil {
      rootNode.addChildNode(objectNode)
    }
    printTransform(of: objectNode)
  }
  
  private func loadView() {
    addSubview(sceneView)
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
      topAnchor.constraint(equalTo: sceneView.topAnchor),
      trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
      bottomAnchor.constraint(equalTo: sceneView.bottomAnchor),
    ])
    addSubview(placeButton)
    NSLayoutConstraint.activate([
      placeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      placeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      placeButton.widthAnchor.constraint(equalToConstant: 100),
      placeButton.heightAnchor.constraint(equalToConstant: 50),
    ])
  }
  
  private func printTransform(of node: SCNNode) {
    print("\(node.simdTransform)")
  }
}

extension ObjectView: ARSessionDelegate {
  
}


extension ObjectView: ARSCNViewDelegate {
  
}
