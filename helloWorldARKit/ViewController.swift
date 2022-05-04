import UIKit
import ARKit

let larguraTela = UIScreen.main.bounds.width
let alturaTela = UIScreen.main.bounds.height

class ViewController: UIViewController {
    

    var scene: SCNScene!
    var isActionPlaying: Bool = false
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let minhaArView = ARSCNView()
    let configuracao = ARWorldTrackingConfiguration()
    let myText = UILabel()
    let myText2 = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        minhaArView.frame = self.view.frame
        minhaArView.autoenablesDefaultLighting = true
        minhaArView.session.run(configuracao)
        self.view.addSubview(minhaArView)
        
        myText.frame = CGRect(x: 10, y: 45, width: larguraTela - 20, height: 120)
        myText.numberOfLines = 0
        myText.text = "Toque no cubo azul para mudar sua cor\n ou no vermelho"
        myText.textAlignment = .center
        myText.font = UIFont.systemFont(ofSize: 32,weight: .light)
        
        myText2.frame = CGRect(x: 10, y: 119, width: larguraTela - 20, height: 120)
        myText2.numberOfLines = 0
        myText2.text = "para movê-lo"
        myText2.textAlignment = .center
        myText2.font = UIFont.systemFont(ofSize: 32,weight: .light)
        
        self.view.addSubview(myText)
        self.view.addSubview(myText2)
        addTapGestureToSceneView()
        addBox1()
        
    }
    
    func addBox1(x:Float = 0, y:Float = 0, z:Float = -0.2){
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode1 = SCNNode(geometry: box1)
        boxNode1.position = SCNVector3(x,y,z)
        
        box1.firstMaterial?.lightingModel = .physicallyBased
        box1.firstMaterial?.diffuse.contents = UIColor.systemBlue
        box1.firstMaterial?.roughness.contents = 0.1
        box1.firstMaterial?.metalness.contents = 0.95
        boxNode1.name = "blueBox"
        
        let box2 = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        let boxNode2 = SCNNode(geometry: box2)
        boxNode2.position = SCNVector3(x: x, y: y, z:z+0.07)
        
        box2.firstMaterial?.lightingModel = .physicallyBased
        box2.firstMaterial?.diffuse.contents = UIColor.systemRed
        box2.firstMaterial?.roughness.contents = 0.1
        box2.firstMaterial?.metalness.contents = 0.95
        boxNode2.name = "redBox"
      
        
        minhaArView.scene.rootNode.addChildNode(boxNode1)
        minhaArView.scene.rootNode.addChildNode(boxNode2)
    }
    
    
    func addTapGestureToSceneView() {
      let tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action:  #selector(ViewController.didTap(withGesGestureRecognizer:)))
      minhaArView.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func didTap(withGesGestureRecognizer recognizer:UIGestureRecognizer){
        let tapLocation = recognizer.location(in:minhaArView)
        let hitTestResults = minhaArView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            
            let hitTestResultsWithFeaturePoints = minhaArView.hitTest(tapLocation,types: .featurePoint)
            
            if let hitTestResultsWithFeaturePoints = hitTestResultsWithFeaturePoints.first{
                let translation = hitTestResultsWithFeaturePoints.worldTransform.translation
                print(translation.x,translation.y,translation.z)
                addBox1(x:translation.x,y:translation.y,z:translation.z)
            }
            return
        }
          
        if node.name == "blueBox"{
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemGreen
            node.geometry?.firstMaterial?.roughness.contents = 0.1
            node.geometry?.firstMaterial?.metalness.contents = 0.95
            node.name = "greenBox"
        }
        else if node.name == "greenBox"{
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemBlue
            node.geometry?.firstMaterial?.roughness.contents = 0.1
            node.geometry?.firstMaterial?.metalness.contents = 0.95
            node.name = "blueBox"
        }
        else if node.name == "redBox"{
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.systemRed
            node.geometry?.firstMaterial?.roughness.contents = 0.1
            node.geometry?.firstMaterial?.metalness.contents = 0.95

            if node.animationKeys.isEmpty{
                self.animationNode(node: node)
            }
            
        }
       
    }
    
    func animationNode(node:SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x,node.presentation.position.y,node.presentation.position.z - 0.045)
        spin.duration = 1
        spin.autoreverses = true
        node.addAnimation(spin, forKey: "position")
    }
}


extension float4x4{
    var translation: SIMD3<Float>{
        let translation = self.columns.3
        return SIMD3<Float> (translation.x,translation.y,translation.z)
    }
}
