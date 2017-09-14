//
//  ViewController2.swift
//  ARKitDemo1
//
//  Created by 刘文 on 2017/9/3.
//  Copyright © 2017年 刘文. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController2: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var node: SCNNode!
    
    fileprivate lazy var imageNames = ["earth", "jupiter", "mars", "venus"]
    fileprivate var currentIndex: Int = 0
    
    var beginLocation: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 平面移动
        guard let touch = touches.first else {
            return
        }
        let preLocation = touch.previousLocation(in: sceneView)
        let location = touch.location(in: sceneView)

        let x = Float(location.x - preLocation.x)
        let y = Float(location.y - preLocation.y)

        let position = node.position
        node.position = SCNVector3(position.x + x/1000, position.y - y/1000, -0.5) // 垂直方向是反的
        
        // 3D 移动
//        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
//            return
//        }
//        let nodeTransform = node.simdTransform
//        let value = nodeTransform[0] * nodeTransform[0] + nodeTransform[1] * nodeTransform[1] + nodeTransform[2] * nodeTransform[2]
    }
}

// MARK: 设置UI及其事件
extension ViewController2 {
    
    fileprivate func setupUI() {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        btn.setTitle("<-back", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        
        btn.frame = CGRect(x: 20, y: 20, width: 60, height: 28)
        
        btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
        
        sceneView.addSubview(btn)
    }
    
    @objc fileprivate func btnClick(_ btn: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: 设置AR
extension ViewController2: ARSCNViewDelegate {
    
    fileprivate func setupAR() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // 1、创建scene
        let scene = SCNScene()
        
        // 4、创建几何形
        let sphere = SCNSphere(radius: 0.1)
        
        // 5、制作几何形的材料
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "earth")
        sphere.materials = [material]
        
        // 3、创建节点，设置节点位置，添加进scene
        node = SCNNode(geometry: sphere)
        node.position = SCNVector3(0, -0.05, -0.5)
        scene.rootNode.addChildNode(node)
        
        // 2、将scene设置为sceneView的scene
        sceneView.scene = scene
        
        currentIndex += 1
        
        // 添加手势
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesAction(_:)))
        sceneView.addGestureRecognizer(tapGes)
    }
    
    @objc fileprivate func tapGesAction(_ tapGes: UITapGestureRecognizer) {
        let sceneView = tapGes.view as! ARSCNView
        let touchLocation = tapGes.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        if !hitResults.isEmpty {
            if currentIndex == imageNames.count {
                currentIndex = 0
            }
            
            guard let hitResult = hitResults.first else {
                return
            }
            
            let node = hitResult.node
            node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageNames[currentIndex])
            
            currentIndex += 1
        }
    }
    
    // MARK: - ARSCNViewDelegate
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
