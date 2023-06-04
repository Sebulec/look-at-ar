
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var arView: ARSCNView!
    var particleSystem: SCNParticleSystem!
    let lightNode = SCNNode()
    var sphereNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        createParticleSystem()
        createSceneAndSphere()
        createLighting()
        
        setupDelegates()
    }
    
    private func createParticleSystem() {
        particleSystem = SCNParticleSystem(named: "FireParticles.scnp", inDirectory: nil)
        particleSystem.birthRate = 60
        particleSystem.particleLifeSpan = 1.5
        particleSystem.particleSize = 0.05
        particleSystem.emissionDuration = 0.5
        particleSystem.particleVelocity = 2
        particleSystem.particleVelocityVariation = 1
        particleSystem.emitterShape = SCNSphere(radius: 0.0001)
        particleSystem.particleColor = UIColor.orange
    }
    
    private func setupDelegates() {
        arView.delegate = self
        arView.session.delegate = self
    }
    
    private func createSceneAndSphere() {
        let scene = SCNScene()
        
        let sphere = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        let image = UIImage(named: "golden_ball")
        material.diffuse.contents = image
        
        sphere.materials = [material]
        sphereNode = SCNNode(geometry: sphere)
        
        // Position the sphere in front of the camera
        let cameraPosition = SCNVector3(x: 0, y: 0, z: -1.5) // Adjust the z value to move the sphere closer or farther from the camera
        let cameraNode = arView.pointOfView!
        let spherePosition = cameraNode.convertPosition(cameraPosition, to: nil)
        sphereNode.position = spherePosition
        
        arView.scene = scene
        
        sphereNode.addParticleSystem(particleSystem)
        scene.rootNode.addChildNode(sphereNode)
    }
    
    private func createLighting() {
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.white
        light.intensity = 1000
        light.attenuationStartDistance = 1
        light.attenuationEndDistance = 10
        lightNode.light = light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        arView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arView.session.pause()
    }
}

extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let camera = frame.camera
        
        let cameraNode = arView.pointOfView
        lightNode.position = SCNVector3(x: 0, y: 1, z: -1)
        cameraNode?.addChildNode(lightNode)

        let cameraPosition = SCNVector3(x: 0, y: 0, z: -1.5)
        let spherePosition = cameraNode!.convertPosition(cameraPosition, to: nil)

        let moveAction = SCNAction.move(to: spherePosition, duration: 2)

        sphereNode.runAction(moveAction)

    }
}
