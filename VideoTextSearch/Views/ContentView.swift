import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TextSearchViewModel()
    @State private var searchText = ""

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Search bar at top
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)

                    TextField("Search text...", text: $searchText)
                        .foregroundColor(.white)
                        .accentColor(.white)
                        .onChange(of: searchText) { newValue in
                            viewModel.searchQuery = newValue
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
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

                Spacer()

                // Status indicator
                if !viewModel.matchedTexts.isEmpty {
                    Text("Found \(viewModel.matchedTexts.count) match\(viewModel.matchedTexts.count == 1 ? "" : "es")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
