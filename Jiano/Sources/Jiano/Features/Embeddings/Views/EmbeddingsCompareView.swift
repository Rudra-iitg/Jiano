import SwiftUI
import SwiftData

struct EmbeddingsCompareLeftView: View {
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
                    textCard(title: "Text A", text: $viewModel.compareSourceText, icon: "text.bubble")
                    textCard(title: "Text B", text: $viewModel.compareTargetText, icon: "text.bubble.fill")
                    
                    Button {
                        // Future: Add functionality for additional texts
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Text C")
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(cardBG)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                .foregroundStyle(borderSubtle)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            actionArea
        }
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [Color(red: 28/255, green: 28/255, blue: 30/255).opacity(0), Color(red: 28/255, green: 28/255, blue: 30/255)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)
            .offset(y: -100)
            .allowsHitTesting(false)
        }
    }
    
    private func textCard(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(accentBlue)
            }
            
            TextEditor(text: text)
                .font(.system(size: 14))
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 100)
                .background(inputBG)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
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
                Task { await viewModel.runComparison() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                    Text("Compare All")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background((viewModel.compareSourceText.isEmpty || viewModel.compareTargetText.isEmpty) ? Color.gray.opacity(0.3) : accentBlue)
                .foregroundStyle((viewModel.compareSourceText.isEmpty || viewModel.compareTargetText.isEmpty) ? textSecondary : .white)
                .cornerRadius(10)
                .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isButtonPressed)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.compareSourceText.isEmpty || viewModel.compareTargetText.isEmpty || viewModel.isProcessing)
            ._onButtonGesture { pressing in
                isButtonPressed = pressing
            } perform: {
                Task { await viewModel.runComparison() }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 24)
        .background(
            Color(red: 28/255, green: 28/255, blue: 30/255)
        )
        .overlay(
            Rectangle()
                .fill(borderSubtle)
                .frame(height: 1),
            alignment: .top
        )
    }
}

// MARK: - Explore Right View
struct EmbeddingsCompareRightView: View {
    @Bindable var viewModel: EmbeddingWorkspaceViewModel
    
    // Theme colors
    private let primaryBG = Color(red: 28/255, green: 28/255, blue: 30/255)
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if viewModel.isProcessing {
                    loadingState
                } else if !viewModel.comparisonMetrics.isEmpty {
                    populatedState
                } else {
                    emptyState
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(primaryBG)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 100)
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 40))
                .foregroundStyle(textSecondary)
            Text("Enter texts on the left to calculate similarity metrics")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(textSecondary)
        }
    }
    
    private var loadingState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 100)
            ProgressView()
                .controlSize(.large)
            Text("Calculating vector similarities...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(textSecondary)
        }
    }
    
    private var populatedState: some View {
        VStack(alignment: .leading, spacing: 32) {
            
            // Primary Score Card
            VStack(spacing: 8) {
                Text("Cosine Similarity")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(textSecondary)
                
                let cosine = viewModel.comparisonMetrics[.cosine] ?? 0.0
                Text(String(format: "%.4f", cosine))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(viewModel.comparisonColor)
                
                Text(viewModel.comparisonLabel)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(viewModel.comparisonColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(viewModel.comparisonColor.opacity(0.2))
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(cardBG)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderSubtle, lineWidth: 1))
            
            // Advanced Metrics Grid
            VStack(alignment: .leading, spacing: 16) {
                Label("Distance Metrics", systemImage: "ruler")
                    .font(.system(size: 16, weight: .semibold))
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    if let l2 = viewModel.comparisonMetrics[.euclidean] {
                        metricCard(title: "L2 (Euclidean)", value: l2)
                    }
                    if let l1 = viewModel.comparisonMetrics[.manhattan] {
                        metricCard(title: "L1 (Manhattan)", value: l1)
                    }
                    if let dot = viewModel.comparisonMetrics[.dotProduct] {
                        metricCard(title: "Dot Product", value: dot)
                    }
                }
            }
        }
        .frame(maxWidth: 800)
    }
    
    private func metricCard(title: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(textSecondary)
            
            Text(String(format: "%.4f", value))
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cardBG)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderSubtle, lineWidth: 1))
    }
}
