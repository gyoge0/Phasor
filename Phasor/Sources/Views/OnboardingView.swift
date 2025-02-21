//
//  OnboardingView.swift
//  Phasor
//
//  Created by YOGESH THAMBIDURAI (875367) on 2/14/25.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void = {}

    @Environment(\.modelContext) private var modelContext: ModelContext
    @State private var viewModel = ViewModel()

    var body: some View {
        TabView {
            Tab {
                Text("Welcome to Phasor!")
                    .font(.largeTitle)
                    .padding()
            }
            Tab {
                Image(systemName: "waveform")
                    .hero()
                Caption(text: "Import audio into your library")
            }
            Tab {
                Image(systemName: "folder")
                    .hero()
                Caption(text: "Create new projects with your audio sources")
            }
            Tab {
                Image("ARKit")
                    .hero(width: 150, height: 150)
                Caption(text: "Use headphones and augmented reality to experience your projects")
            }
            Tab {
                Image(systemName: "airpods.max")
                    .hero()
                Caption(
                    text:
                        "Connect headphones that support head-tracked spatial audio for the best experience"
                )
            }
            Tab {
                Button("Get started", action: onFinish)
                    .font(.largeTitle)
                    .padding()
            }
        }
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .errorMessage(errorMessageComponent: viewModel.errorMessageComponent)
        .task {
            await viewModel.loadDemoProject()
        }
        .onAppear {
            viewModel.modelContext = modelContext
        }
    }
}

struct Caption: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.callout)
            .multilineTextAlignment(.center)
            .padding()
    }
}

extension Image {
    func hero(width: Double = 100, height: Double = 100) -> some View {
        return
            self
            .resizable()
            .scaledToFit()
            .frame(width: .init(width), height: .init(height))
            .padding()
    }
}

#Preview {
    VStack {
    }.fullScreenCover(isPresented: Binding.constant(true)) {
        OnboardingView()
    }
}
