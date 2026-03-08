import SwiftUI
import SwiftData

struct EmbeddingsGenerateLeftView: View {
    @Bindable var viewModel: EmbeddingWorkspaceViewModel
    
    // Theme Colors
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let inputBG = Color(red: 58/255, green: 58/255, blue: 60/255)
    
    @State private var isButtonPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    modelConfigurationCard
                    textInputCard
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                // Add bottom padding equal to sticky footer height + extra
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Sticky Footer
            actionArea
        }
        .overlay(alignment: .bottom) {
            // Adds a gradient fade to the bottom of the scroll view
            LinearGradient(
                colors: [Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0), Color(red: 28/255, green: 28/255, blue: 30/255)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .offset(y: -100) // Positioned above the sticky footer
            .allowsHitTesting(false)
        }
    }
    
    private var modelConfigurationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Model Configuration")
                    .font(.system(size: 15, weight: .semibold))
            } icon: {
                Image(systemName: "square.grid.2x2")
                    .foregroundStyle(accentBlue)
            }
            
            // Custom Dropdown
            Menu {
                ForEach(viewModel.availableModels, id: \.self) { model in
                    Button(model) {
                        viewModel.selectedModel = model
                    }
                }
            } label: {
                HStack {
                    // Placeholder provider icon (you can map this to real providers later)
                    Image(systemName: "cpu.fill")
                        .foregroundStyle(textSecondary)
                        .frame(width: 24)
                    
                    Text(viewModel.selectedModel.isEmpty ? "Select a model" : viewModel.selectedModel)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(inputBG)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderSubtle, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Stats Row
            Text("1536 dimensions  ·  8192 token limit  ·  $0.02/1M tokens")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .background(cardBG)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderSubtle, lineWidth: 1)
        )
    }
    
    private var textInputCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Text Input")
                    .font(.system(size: 15, weight: .semibold))
            } icon: {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(accentBlue)
            }
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.generateInputText)
                    .font(.system(size: 14))
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 180)
                    .background(inputBG)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                if viewModel.generateInputText.isEmpty {
                    Text("Enter text to generate embeddings...\nSupports up to 8,192 tokens.")
                        .font(.system(size: 14))
                        .foregroundStyle(textSecondary)
                        .padding(16)
                        .padding(.top, 4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .allowsHitTesting(false)
                }
                
                // Character Counter
                Text("\(viewModel.generateInputText.count) / 8,192 tokens")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textSecondary)
                    .padding(12)
            }
            
            // Toggle
            HStack {
                Toggle("Normalize vectors", isOn: .constant(true))
                    .font(.system(size: 13))
                    .toggleStyle(SwitchToggleStyle(tint: accentBlue))
                Spacer()
            }
        }
        .padding(16)
        .background(cardBG)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderSubtle, lineWidth: 1)
        )
    }
    
    private var actionArea: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.generateSingleEmbedding() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "waveform")
                    }
                    Text("Generate Embedding")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(viewModel.generateInputText.isEmpty ? Color.gray.opacity(0.3) : accentBlue)
                .foregroundStyle(viewModel.generateInputText.isEmpty ? textSecondary : .white)
                .cornerRadius(10)
                .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isButtonPressed)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.generateInputText.isEmpty || viewModel.isProcessing)
            // Capture button press for scale animation
            ._onButtonGesture { pressing in
                isButtonPressed = pressing
            } perform: {
                Task { await viewModel.generateSingleEmbedding() }
            }
            
            // Last Generated text
            if viewModel.processingTime > 0 {
                let timeStr = String(format: "%.0f ms", viewModel.processingTime * 1000)
                Text("Last generated: \(timeStr) ago  ·  \(viewModel.currentEmbedding?.dimension ?? 0) dims")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textSecondary)
            } else {
                Text("Ready to generate")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(textSecondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(
            Color(red: 28/255, green: 28/255, blue: 30/255)
        )
        // Top border for action area
        .overlay(
            Rectangle()
                .fill(borderSubtle)
                .frame(height: 1),
            alignment: .top
        )
    }
}
