//
//  ARMapExpView.swift
//  LibraryResearchAssist
//
//  Created by Brandon Williams on 4/29/26.
//

import SwiftUI

struct ARMapExpView: View {
    
    @StateObject var arState = ARStateModel()
    
    // MARK: - YOUR LIBRARY DATA
    let locations: [LocationDataModel] = LibraryData.sampleLocations
    
    var body: some View {
        ZStack {
            
            ARViewContainer(
                arState: arState,
                locations: locations
            )
            .edgesIgnoringSafeArea(.all)
            
            // Overlay UI
            VStack {
                
                Text(arState.statusMessage)
                    .padding()
                    .background(.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 50)
                
                Spacer()
                
                if arState.showPlacementPrompt {
                    Text("Tap surface to place map")
                        .padding()
                        .background(.white.opacity(0.8))
                        .cornerRadius(12)
                }
            }
        }
    }
}
