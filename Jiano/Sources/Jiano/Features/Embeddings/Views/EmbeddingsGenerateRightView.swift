import SwiftUI
import SwiftData

struct EmbeddingsGenerateRightView: View {
    @Bindable var viewModel: EmbeddingWorkspaceViewModel
    
    // Theme colors
    private let primaryBG = Color(red: 28/255, green: 28/255, blue: 30/255)
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    
    @State private var showRawVector = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isProcessing {
                    loadingState
                } else if let stats = viewModel.currentStats, let item = viewModel.currentEmbedding {
                    populatedState(stats: stats, item: item)
                } else {
                    emptyState
                }
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(primaryBG)
    }
    
    // MARK: - States
    
    private var emptyState: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 8) {
                Text("Embeddings Workspace")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                Text("Transform text into high-dimensional vector representations")
                    .font(.system(size: 15))
                    .foregroundStyle(textSecondary)
            }
            .padding(.top, 40)
            
            // Feature Cards
            HStack(spacing: 16) {
                featureCard(
                    title: "Vector Visualization",
                    desc: "See your text as a 1536-dimensional waveform heatmap",
                    icon: "waveform"
                )
                featureCard(
                    title: "Semantic Analysis",
                    desc: "Statistics, magnitude, sparsity, and distribution",
                    icon: "chart.bar"
                )
                featureCard(
                    title: "Similarity Compare",
                    desc: "Compare multiple texts to find semantic distance",
                    icon: "arrow.left.arrow.right"
                )
            }
            
            // Dashed Box
            VStack(spacing: 12) {
                Image(systemName: "waveform")
                    .font(.system(size: 32))
                    .foregroundStyle(textSecondary)
                Text("Generate your first embedding to see visualization")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(cardBG.opacity(0.3))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                    .foregroundStyle(borderSubtle)
            )
        }
        .frame(maxWidth: 800)
    }
    
    private var loadingState: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 100)
            
            Image(systemName: "waveform")
                .font(.system(size: 40))
                .foregroundStyle(accentBlue)
                // Basic pulsing animation
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Generating vector embeddings...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func populatedState(stats: EmbeddingAnalyticsEngine.VectorStats, item: EmbeddingItem) -> some View {
        VStack(spacing: 24) {
            VectorWaveformView(vector: item.vector)
                .transition(.opacity.combined(with: .move(edge: .top)))
            
            EmbeddingStatisticsView(
                dimension: item.dimension,
                norm: stats.norm,
                mean: stats.mean,
                variance: stats.variance,
                nonZero: stats.sparsity, 
                maxVal: stats.max
            )
            .transition(.opacity.combined(with: .move(edge: .top)))
            
            rawVectorSection(vector: item.vector)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
        .frame(maxWidth: 800)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentEmbedding != nil)
    }
    
    private func featureCard(title: String, desc: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(accentBlue)
                .frame(width: 40, height: 40)
                .background(accentBlue.opacity(0.1))
                .cornerRadius(8)
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            
            Text(desc)
                .font(.system(size: 13))
                .foregroundStyle(textSecondary)
                .lineSpacing(4)
                .frame(maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBG)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderSubtle, lineWidth: 1)
        )
    }
    
    // MARK: - Raw Vector Section
    private func rawVectorSection(vector: [Double]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation { showRawVector.toggle() }
            } label: {
                HStack {
                    Label {
                        Text("Raw Vector")
                            .font(.system(size: 15, weight: .semibold))
                    } icon: {
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(showRawVector ? 90 : 0))
                            .foregroundStyle(textSecondary)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)
            
            if showRawVector {
                VStack(spacing: 8) {
                    HStack {
                        Spacer()
                        Button {
                            let str = "[\(vector.map { String($0) }.joined(separator: ", "))]"
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(str, forType: .string)
                        } label: {
                            Label("Copy Vector", systemImage: "doc.on.doc")
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .background(primaryBG)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderSubtle, lineWidth: 1))
                        
                        Button {
                            // Trigger JSON export here (could be via view model action)
                            // if let json = viewModel.getExportJSON() { ... }
                        } label: {
                            Label("Export as JSON", systemImage: "square.and.arrow.up")
                                .font(.system(size: 11, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .background(primaryBG)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderSubtle, lineWidth: 1))
                    }
                    
                    ScrollView {
                        Text("[\(vector.map { String(format: "%.4f", $0) }.joined(separator: ", "))]")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                    }
                    .frame(height: 150)
                    .background(primaryBG)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderSubtle, lineWidth: 1))
                }
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
}
