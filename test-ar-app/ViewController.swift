//
//  ViewController.swift
//  test-ar-app
//
//  Created by Daniel Mansour on 12/8/21.
//

import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    private let arEntityArr:[String] = [
        "FREE_1972_Datsun_240k_GT",
        "FREE_1975_Porsche_911_930_Turbo",
        "Chook"
    ]
    
    private let choiceNum:Int = 1
    
    private var arEntityName:String {
        return arEntityArr[choiceNum]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        arView.addGestureRecognizer(gestureRecognizer)
    }
    
    // Setup Methods
    
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    
    // Object Placement
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) -> Void {
        let location = recognizer.location(in: arView)
        
        let horizontalSurfaces = arView.raycast(
            from: location,
            allowing: .estimatedPlane,
            alignment: .horizontal)
        
        if let firstResult = horizontalSurfaces.first {
            let anchor = ARAnchor(name: arEntityName, transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        } else {
            print("Object placement failed - couldn't find surface.")
        }
    }
    
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.loadModel(named: entityName)
        
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation, .scale], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name, anchorName == arEntityName {
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
    
    
}
