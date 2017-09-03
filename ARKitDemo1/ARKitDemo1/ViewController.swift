//
//  ViewController.swift
//  ARKitDemo1
//
//  Created by 刘文 on 2017/9/2.
//  Copyright © 2017年 刘文. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    fileprivate lazy var titleArr = ["earth", "shotSnap", "box", "pyramid", "cylinder",
                                     "cone", "tube", "capsule", "torus", "floor",
                                     "text", "shape", "gif", "video"]
    fileprivate lazy var btnArr: [UIButton] = []
    fileprivate var selectedIndex: Int = 0
    
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


}

// MARK: 设置UI及其事件
extension ViewController {
    
    fileprivate func setupUI() {
        for (index, title) in titleArr.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = index
            
            btn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setTitleColor(UIColor.red, for: .selected)
            
            let margin = 15
            let width = 90
            let height = 28
            let y = margin + index * (margin + height)
            btn.frame = CGRect(x: margin, y: y, width: width, height: height)
            
            btn.layer.cornerRadius = 3
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.black.cgColor
            btn.layer.masksToBounds = true
            
            btn.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
            
            if index == 0 {
                btn.isSelected = true
            }
            
            sceneView.addSubview(btn)
            btnArr.append(btn)
        }
        
        let nextBtn = UIButton(type: .custom)
        
        nextBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        nextBtn.setTitle("next->", for: .normal)
        nextBtn.setTitleColor(UIColor.white, for: .normal)
        
        nextBtn.frame = CGRect(x: sceneView.bounds.size.width - 80, y: 20, width: 60, height: 28)
        
        nextBtn.addTarget(self, action: #selector(nextBtnClick(_:)), for: .touchUpInside)
        
        sceneView.addSubview(nextBtn)
    }
    
    @objc fileprivate func btnClick(_ btn: UIButton) {
        if self.selectedIndex == btn.tag {
            return
        } else {
            btn.isSelected = true
            btnArr[self.selectedIndex].isSelected = false
            self.selectedIndex = btn.tag
        }
    }
    
    @objc fileprivate func nextBtnClick(_ btn: UIButton) {
        let vc2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController2")
        present(vc2, animated: true, completion: nil)
    }
    
}

// MARK: 设置AR
extension ViewController: ARSCNViewDelegate {
    
    fileprivate func setupAR() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // 1、创建scene
        let scene = SCNScene()
        
        // 4、创建几何形
        let sphere = SCNSphere(radius: 0.05)
        
        // 5、制作几何形的材料
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "earth")
        sphere.materials = [material]
        
        // 3、创建节点，设置节点位置，添加进scene
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3Make(0, 0, -1)
        scene.rootNode.addChildNode(node)
        
        // 2、将scene设置为sceneView的scene
        sceneView.scene = scene
        
        // 添加手势
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesAction(_:)))
        sceneView.addGestureRecognizer(tapGes)
    }
    
    @objc fileprivate func tapGesAction(_ tapGes: UITapGestureRecognizer) {
        guard let node = createNodeWithIndex(selectedIndex) else {
            return
        }
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    private func createNodeWithIndex(_ index: Int) -> SCNNode? {
        guard let currentFrame = sceneView.session.currentFrame else {
            return nil
        }
        var geometry: SCNGeometry!
        switch index {
        case 0:
            geometry = SCNSphere(radius: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "earth")
            geometry.firstMaterial?.lightingModel = .constant
        case 1:
            geometry = SCNPlane(width: sceneView.bounds.size.width / 6000, height: sceneView.bounds.size.height / 6000)
            
//            let material = SCNMaterial()
//            material.diffuse.contents = sceneView.snapshot()
//            plane.materials = [material]
            
            geometry.firstMaterial?.diffuse.contents = sceneView.snapshot()
            geometry.firstMaterial?.lightingModel = .constant
        case 2:
            geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
            geometry.firstMaterial?.lightingModel = .blinn
        case 3:
            geometry = SCNPyramid(width: 0.07, height: 0.07, length: 0.07)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
            geometry.firstMaterial?.lightingModel = .lambert
        case 4:
            geometry = SCNCylinder(radius: 0.04, height: 0.2)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
        case 5:
            geometry = SCNCone(topRadius: 0.03, bottomRadius: 0.05, height: 0.06)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
        case 6:
            geometry = SCNTube(innerRadius: 0.006, outerRadius: 0.08, height: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
        case 7:
            geometry = SCNCapsule(capRadius: 0.02, height: 0.05)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
        case 8:
            geometry = SCNTorus(ringRadius: 0.03, pipeRadius: 0.02)
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
        case 9:
            geometry = SCNFloor()
            geometry.firstMaterial?.diffuse.contents = UIImage(named: "brick")
        case 10:
            geometry = createTextGeometry()
        case 11:
            geometry = createPathGeometry()
        case 12:
            geometry = createGitGeometry()
        case 13:
            print("vedio")
        default:
            let alert = UIAlertController(title: "请选择实体", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {
                (UIAlertAction) -> Void in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return nil
        }
        
        let node = SCNNode(geometry: geometry)
        sceneView.scene.rootNode.addChildNode(node)
        
        // 追踪相机位置
        var translate = matrix_identity_float4x4
        translate.columns.3.z = -0.5
        translate.columns.2.y = -0.05
        
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translate)
        
        return node
    }
    
    private func createTextGeometry() -> SCNGeometry? {
//        let attrStrM = NSMutableAttributedString()
//        let attrStr1 = NSAttributedString(string: "Hello, ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30.0), NSAttributedStringKey.backgroundColor: UIColor.purple])
//        attrStrM.append(attrStr1)
//        let attrStr2 = NSAttributedString(string: "world!", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 35.0), NSAttributedStringKey.backgroundColor: UIColor.yellow])
//        attrStrM.append(attrStr2)
        
        let geometry = SCNText(string: "Hello, world", extrusionDepth: 0.003)
        (geometry as! SCNText).font = UIFont.systemFont(ofSize: 30)
        geometry.firstMaterial?.diffuse.contents = UIColor.white
        return geometry
    }
    
    private func createPathGeometry() -> SCNGeometry? {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 10, y: 50))
        path.addCurve(to: CGPoint(x: 100, y: 50), controlPoint1: CGPoint(x: 140, y: 20), controlPoint2: CGPoint(x: 180, y: 80))
        let geometry = SCNShape(path: path, extrusionDepth: 0.01)
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        return geometry
    }
    
    private func createGitGeometry() -> SCNGeometry? {
        guard let path = Bundle.main.path(forResource: "dota.gif", ofType: nil) else {
            return nil
        }
        guard let data = NSData(contentsOfFile: path) else {
            return nil
        }
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        var duration : TimeInterval = 0.0
        var images = [UIImage]()
        for index in 0..<frameCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil) else {
                return nil
            }
            
            // 计算时间
            guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil), let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
                let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else {
                    continue
            }
            duration += frameDuration.doubleValue
            
            let image = UIImage(cgImage: cgImage)
            images.append(image)
        }
        
        let width = images[0].size.width
        let height = images[0].size.height
        let geometry = SCNPlane(width: width/6000, height: height/6000)
        
        // 这种方式在UIImageView可以，但在这不行
//        geometry.firstMaterial?.diffuse.contents = UIImage.animatedImage(with: images, duration: duration)
        
        duration = duration / Double(images.count)
        var index = 0
        let timer = Timer(timeInterval: duration, repeats: true) { (tim) in
            if index == images.count {
                index = 0
            }
            geometry.firstMaterial?.diffuse.contents = images[index]
        }
        RunLoop.main.add(timer, forMode: .commonModes)
        
        return geometry
    }
    
    @objc fileprivate func timerAction(_ userInfo: NSDictionary) {
        
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

