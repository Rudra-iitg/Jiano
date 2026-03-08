import SwiftUI
import SwiftData

struct EmbeddingWorkspaceView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: EmbeddingWorkspaceViewModel
    @Namespace private var tabNamespace
    
    let diContainer: AppDIContainer
    
    init(diContainer: AppDIContainer) {
        self.diContainer = diContainer
        self._viewModel = State(initialValue: EmbeddingWorkspaceViewModel(diContainer: diContainer))
    }
    
    // Theme Colors
    private let primaryBG = Color(red: 28/255, green: 28/255, blue: 30/255)
    private let secondaryBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let borderSubtle = Color.white.opacity(0.08)
    
    var body: some View {
        HStack(spacing: 0) {
            // LEFT COLUMN
            VStack(spacing: 0) {
                // Tab Bar
                workspaceToolbar
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    .padding(.horizontal, 20)
                
                Divider()
                    .background(borderSubtle)
                
                // Left Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        inputPane
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: 420)
            .background(primaryBG)
            .border(width: 1, edges: [.trailing], color: borderSubtle)
            
            // RIGHT COLUMN
            ZStack {
                primaryBG.ignoresSafeArea()
                
                resultsPane
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.setModelContext(modelContext)
            Task {
                await viewModel.fetchModels()
            }
        }
    }
    
    // MARK: - Tab Bar
    private var workspaceToolbar: some View {
        HStack(spacing: 0) {
            ForEach(EmbeddingWorkspaceMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.currentMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: viewModel.currentMode == mode ? .medium : .regular))
                        .foregroundStyle(viewModel.currentMode == mode ? .white : textSecondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                if viewModel.currentMode == mode {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(secondaryBG)
                                        .matchedGeometryEffect(id: "TabBackground", in: tabNamespace)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.black.opacity(0.2))
        .cornerRadius(20)
        // Center the tab bar
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Input Pane (Left Side)
    @ViewBuilder
    private var inputPane: some View {
        switch viewModel.currentMode {
        case .generate:
            EmbeddingsGenerateLeftView(viewModel: viewModel)
        case .explore:
            EmbeddingsExploreLeftView(viewModel: viewModel)
        case .compare:
            EmbeddingsCompareLeftView(viewModel: viewModel)
        case .lab:
            EmbeddingsLabLeftView(viewModel: viewModel)
        }
    }
    
    // MARK: - Results Pane (Right Side)
    @ViewBuilder
    private var resultsPane: some View {
        switch viewModel.currentMode {
        case .generate:
            EmbeddingsGenerateRightView(viewModel: viewModel)
        case .explore:
            EmbeddingsExploreRightView(viewModel: viewModel)
        case .compare:
            EmbeddingsCompareRightView(viewModel: viewModel)
        case .lab:
            EmbeddingsLabRightView(viewModel: viewModel)
        }
    }
}

// Border Helper
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }
            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }
            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }
            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}
