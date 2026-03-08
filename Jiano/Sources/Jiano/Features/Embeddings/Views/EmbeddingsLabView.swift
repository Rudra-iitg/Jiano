import SwiftUI
import SwiftData
import Charts

struct EmbeddingsLabLeftView: View {
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Batch Clustering")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Process multiple embeddings into semantic clusters")
                            .font(.system(size: 13))
                            .foregroundStyle(textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Batch Input Card
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text("Text Batch (one per line)")
                                .font(.system(size: 14, weight: .semibold))
                        } icon: {
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundStyle(accentBlue)
                        }
                        
                        TextEditor(text: $viewModel.labBatchInput)
                            .font(.system(size: 14))
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(minHeight: 200)
                            .background(inputBG)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                    .padding(16)
                    .background(cardBG)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderSubtle, lineWidth: 1))
                    
                    // Parameters Card
                    VStack(alignment: .leading, spacing: 16) {
                        Label {
                            Text("Parameters")
                                .font(.system(size: 14, weight: .semibold))
                        } icon: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(accentBlue)
                        }
                        
                        HStack {
                            Text("Clusters (K)")
                                .font(.system(size: 14))
                                .foregroundStyle(textSecondary)
                            Spacer()
                            Stepper("", value: $viewModel.labClusterCount, in: 2...10)
                                .labelsHidden()
                            Text("\(viewModel.labClusterCount)")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(width: 30, alignment: .trailing)
                        }
                        
                        HStack {
                            Text("Reduction Method")
                                .font(.system(size: 14))
                                .foregroundStyle(textSecondary)
                            Spacer()
                            Picker("", selection: $viewModel.labReductionMethod) {
                                ForEach(ReductionMethod.allCases, id: \.self) { method in
                                    Text(method.rawValue).tag(method)
                                }
                            }
                            .frame(width: 100)
                        }
                    }
                    .padding(16)
                    .background(cardBG)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderSubtle, lineWidth: 1))
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
    
    private var actionArea: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.runBatchAnalysis() }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isProcessing {
                        ProgressView()
                            .controlSize(.small)
                            .tint(.white)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text("Run Analysis")
                        .font(.system(size: 15, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background((viewModel.labBatchInput.isEmpty) ? Color.gray.opacity(0.3) : accentBlue)
                .foregroundStyle((viewModel.labBatchInput.isEmpty) ? textSecondary : .white)
                .cornerRadius(10)
                .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isButtonPressed)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.labBatchInput.isEmpty || viewModel.isProcessing)
            ._onButtonGesture { pressing in
                isButtonPressed = pressing
            } perform: {
                Task { await viewModel.runBatchAnalysis() }
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

// MARK: - Lab Right View
struct EmbeddingsLabRightView: View {
    @Bindable var viewModel: EmbeddingWorkspaceViewModel
    
    // Theme colors
    private let primaryBG = Color(red: 28/255, green: 28/255, blue: 30/255)
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    
    let colors: [Color] = [.blue, .purple, .orange, .green, .red, .pink, .cyan, .yellow, .mint, .indigo]
    
    var body: some View {
        VStack {
            if viewModel.isProcessing {
                loadingState
            } else if !viewModel.labPoints.isEmpty {
                populatedState
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(primaryBG)
    }
    
    // MARK: - States
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bubble")
                .font(.system(size: 40))
                .foregroundStyle(textSecondary)
            Text("Enter a batch of texts on the left to cluster them")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(textSecondary)
        }
    }
    
    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Running clustering & dimensionality reduction...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(textSecondary)
        }
    }
    
    private var populatedState: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cluster Visualization")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(viewModel.labPoints.count) items into \(viewModel.labClusterCount) clusters")
                        .font(.system(size: 13))
                        .foregroundStyle(textSecondary)
                }
                
                Spacer()
                
                Button {
                    if let json = viewModel.getExportJSON() {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(json, forType: .string)
                    }
                } label: {
                    Label("Export JSON", systemImage: "doc.on.doc")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(cardBG)
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderSubtle, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            
            // Scatter Plot
            Chart {
                ForEach(viewModel.labPoints) { point in
                    PointMark(
                        x: .value("X", point.x),
                        y: .value("Y", point.y)
                    )
                    .foregroundStyle(colors[point.clusterIndex % colors.count].opacity(point.isAnomaly ? 0.3 : 1.0))
                    .symbol {
                        if point.isAnomaly {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red)
                        } else {
                            Circle()
                                .fill(colors[point.clusterIndex % colors.count])
                                .frame(width: 8, height: 8)
                        }
                    }
                    .annotation(position: .overlay, alignment: .center, spacing: 0) {
                        Text(point.text)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.white.opacity(0.7))
                            .offset(y: -12)
                    }
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(cardBG.opacity(0.5))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderSubtle, lineWidth: 1))
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
