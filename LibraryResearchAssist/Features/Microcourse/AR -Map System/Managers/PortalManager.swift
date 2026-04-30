//
//  PortalManager.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import Foundation
import RealityKit
import ARKit
import AVFoundation
import UIKit

class PortalManager {
    
    // MARK: - Active Portals
    
    private var activePortals: [AnchorEntity] = []
    private var audioPlayer: AVAudioPlayer?
    
    // MARK: - Portal Configuration
    
    let portalWidth: Float = 0.4
    let portalHeight: Float = 0.25
    
    // MARK: - Public Portal Placement
    
    func placePortal(
        in arView: ARView,
        raycastResult: ARRaycastResult,
        locationData: LocationDataModel
    ) {
        let anchor = AnchorEntity(world: raycastResult.worldTransform)
        
        // Create portal screen
        let portalEntity = createPortalEntity(for: locationData)
        
        // Slight lift above floor
        portalEntity.position.y += portalHeight / 2
        
        // Face user approximately
        portalEntity.orientation = simd_quatf(
            angle: 0,
            axis: [0, 1, 0]
        )
        
        anchor.addChild(portalEntity)
        
        arView.scene.addAnchor(anchor)
        
        activePortals.append(anchor)
        
        // Optional audio
        if let audioFile = locationData.audioFileName {
            playAudio(named: audioFile)
        }
    }
    
    // MARK: - Create Portal Entity
    
    private func createPortalEntity(
        for locationData: LocationDataModel
    ) -> ModelEntity {
        
        let mesh = MeshResource.generatePlane(
            width: portalWidth,
            height: portalHeight
        )
        
        let material: Material
        
        if let videoMaterial = generateVideoMaterial(
            videoFileName: locationData.videoFileName
        ) {
            material = videoMaterial
        } else {
            material = SimpleMaterial(
                color: .orange,
                isMetallic: false
            )
        }
        
        let portalEntity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        
        portalEntity.name = "Portal_\(locationData.name)"
        
        // Rotate vertical
        portalEntity.transform.rotation = simd_quatf(
            angle: -.pi / 2,
            axis: [1, 0, 0]
        )
        
        // Add collision for future interaction
        portalEntity.generateCollisionShapes(recursive: true)
        
        return portalEntity
    }
    
    // MARK: - Video Material
    
    private func generateVideoMaterial(
        videoFileName: String
    ) -> VideoMaterial? {
        
        guard let url = Bundle.main.url(
            forResource: videoFileName,
            withExtension: nil
        ) else {
            print("⚠️ Video file not found: \(videoFileName)")
            return nil
        }
        
        let player = AVPlayer(url: url)
        
        player.play()
        
        return VideoMaterial(avPlayer: player)
    }
    
    // MARK: - Audio Playback
    
    private func playAudio(named fileName: String) {
        
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: nil
        ) else {
            print("⚠️ Audio file not found: \(fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
        } catch {
            print("⚠️ Audio playback failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cleanup
    
    func removeAllPortals() {
        for portal in activePortals {
            portal.removeFromParent()
        }
        
        activePortals.removeAll()
        audioPlayer?.stop()
    }
    
    // MARK: - Portal Tap Detection
    
    func detectPortalTap(in arView: ARView, at point: CGPoint) -> Bool {
        if let entity = arView.entity(at: point),
           entity.name.contains("Portal_") {
            return true
        }
        return false
    }
    
    func removeLatestPortal() {
        guard let last = activePortals.last else { return }
        last.removeFromParent()
        activePortals.removeLast()
    }
}
