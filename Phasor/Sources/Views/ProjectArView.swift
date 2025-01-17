//
//  ProjectArView.swift
//  SData
//
//  Created by YOGESH THAMBIDURAI (875367) on 1/13/25.
//

import ARKit
import PHASE
import RealityKit
import SwiftData
import SwiftUI

struct ProjectArView: View {
    @State var project: PhasorProject
    @Environment(\.modelContext) var modelContext: ModelContext
    @State var viewModel: ViewModel

    init(project: PhasorProject) {
        self.project = project
        self.viewModel = ViewModel(project: project)
    }

    var body: some View {
        ZStack {
            ArPlaceObjectsViewRepresentable(delegate: viewModel.delegate)
                .ignoresSafeArea(SafeAreaRegions.all)

            VStack {
                Spacer()
                Slider(
                    value: $viewModel.delegate.distance,
                    in: 0.0...3.0
                )
                Menu {
                    ForEach($project.soundEventAssets, id: \.id) { $item in
                        Button(item.name) {
                            viewModel.placeSoundSource(playing: item)
                        }
                    }
                } label: {
                    Image(systemName: "plus.viewfinder")
                        .font(.custom("SF", size: 100.0, relativeTo: .title))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.primary, Color.accentColor)
                }
            }
            .padding()
        }
        .errorMessage(errorMessageComponent: viewModel.errorMessageComponent)
        .onAppear {
            viewModel.modelContextComponent.modelContext = modelContext
            viewModel.startPlayer()
        }
        .onDisappear {
            viewModel.stopPlayer()
        }
    }

}

// UIViewRepresentable creates and has direct access to ARView
// Also is the SwiftUI element with the camera feed for AR
struct ArPlaceObjectsViewRepresentable: UIViewRepresentable {
    // Not sure why this has to be @ObservedObject and not just regular property
    // Setting the delegate's arView property connects SwiftUI and ARKit
    @State var delegate: ProjectArDelegate

    func makeUIView(context: Context) -> some UIView {
        let arView = ARView()

        delegate.arView = arView
        arView.session.delegate = delegate

        return arView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
