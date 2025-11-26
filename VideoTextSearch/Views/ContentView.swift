import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TextSearchViewModel()
    @State private var searchText = ""

    var body: some View {
        ZStack {
            // Background color for when camera is not available
            Color.black.edgesIgnoringSafeArea(.all)

            if viewModel.isDemoMode {
                // Demo mode: show static image
                DemoImageView(viewModel: viewModel)
                    .edgesIgnoringSafeArea(.all)
            } else {
                // Camera preview (only when authorized)
                if viewModel.cameraPermissionStatus == .authorized {
                    CameraPreview(viewModel: viewModel)
                        .edgesIgnoringSafeArea(.all)
                }

                // Permission denied overlay
                if viewModel.cameraPermissionStatus == .denied || viewModel.cameraPermissionStatus == .restricted {
                    permissionDeniedView
                }
            }

            // Main UI overlay (show in both demo and camera mode when appropriate)
            if viewModel.isDemoMode || viewModel.cameraPermissionStatus == .authorized {
                mainUIOverlay
            }

            // Demo mode button (always visible)
            demoModeButton
        }
        .onAppear {
            viewModel.startWithDemoMode()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }

    private var mainUIOverlay: some View {
        VStack {
            // Search bar at top
            searchBar

            Spacer()

            // Status indicator
            statusIndicator
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)

            TextField("Search text...", text: Binding(
                get: { searchText },
                set: { newValue in
                    searchText = newValue
                    viewModel.searchQuery = newValue
                }
            ))
                .foregroundColor(.white)
                .accentColor(.white)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 50)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        if !searchText.isEmpty {
            if !viewModel.matchedTexts.isEmpty {
                Text("Found \(viewModel.matchedTexts.count) match\(viewModel.matchedTexts.count == 1 ? "" : "es")")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            } else {
                Text("No matches found")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.bottom, 30)
            }
        }
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("This app needs camera access to search for text in real-time video. Please enable camera access in Settings.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button(action: openSettings) {
                Text("Open Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
    }

    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }

    private var demoModeButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    if viewModel.isDemoMode {
                        viewModel.disableDemoMode()
                    } else {
                        viewModel.enableDemoMode()
                    }
                }) {
                    HStack {
                        Image(systemName: viewModel.isDemoMode ? "camera.fill" : "photo.fill")
                        Text(viewModel.isDemoMode ? "Camera" : "Demo")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(viewModel.isDemoMode ? Color.blue.opacity(0.8) : Color.purple.opacity(0.8))
                    .cornerRadius(20)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
