//
//  ARViewContainer.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var arState: ARStateModel
    var locations: [LocationDataModel]

    func makeCoordinator() -> ARCoordinator {
        ARCoordinator(
            arState: arState,
            locations: locations
        )
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        configureARSession(for: arView)

        context.coordinator.setupARView(arView)

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(ARCoordinator.handleTap(_:))
        )

        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        
        // Handle floor changes
        context.coordinator.updateFloorIfNeeded(arState.currentFloor)

        // Handle reset/reposition logic
        if arState.interactionState == .placingMap &&
            context.coordinator.mapManager.currentMap == nil {
            context.coordinator.prepareForMapPlacement()
        }
    }

    private func configureARSession(for arView: ARView) {
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic

        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }

        arView.session.run(
            configuration,
            options: [.resetTracking, .removeExistingAnchors]
        )

        arView.automaticallyConfigureSession = false
    }
}
