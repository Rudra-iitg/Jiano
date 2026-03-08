import SwiftUI
import SwiftData

struct EmbeddingsExploreLeftView: View {
    @Bindable var viewModel: EmbeddingWorkspaceViewModel
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    // Theme Colors
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let inputBG = Color(red: 58/255, green: 58/255, blue: 60/255)
    
    let filters = ["All", "Recent", "Favorites"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(textSecondary)
                TextField("Search your embedding library...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
            }
            .padding(12)
            .background(inputBG)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderSubtle, lineWidth: 1)
            )
            
            // Filter Row
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: selectedFilter == filter ? .medium : .regular))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(selectedFilter == filter ? accentBlue : Color.clear)
                            .foregroundStyle(selectedFilter == filter ? .white : textSecondary)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedFilter == filter ? Color.clear : borderSubtle, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            
            // Scrollable List
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.exploreItems.isEmpty {
                        Text("No embeddings found")
                            .font(.system(size: 14))
                            .foregroundStyle(textSecondary)
                            .padding(.top, 40)
                    } else {
                        ForEach(viewModel.exploreItems, id: \.id) { item in
                            // Filter logic (Basic)
                            if searchText.isEmpty || item.text.localizedCaseInsensitiveContains(searchText) {
                                ExploreRowView(
                                    item: item,
                                    isSelected: viewModel.selectedPointID == item.id,
                                    cardBG: cardBG,
                                    borderSubtle: borderSubtle,
                                    accentBlue: accentBlue,
                                    textSecondary: textSecondary
                                ) {
                                    Task {
                                        await viewModel.selectExplorePoint(item)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.top, 24)
        .padding(.horizontal, 20)
        .onAppear {
            // Load if empty (the View uses the SwiftData equivalent context passed down)
            // Or load all logic needs to be fired. We rely on the parent or user input.
        }
    }
}

private struct ExploreRowView: View {
    let item: EmbeddingItem
    let isSelected: Bool
    let cardBG: Color
    let borderSubtle: Color
    let accentBlue: Color
    let textSecondary: Color
    let onSelect: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.text)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 4)
                
                HStack(spacing: 12) {
                    // Dimension Badge
                    HStack(spacing: 4) {
                        Image(systemName: "ruler")
                            .font(.system(size: 10))
                        Text("\(item.dimension)d")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(4)
                    
                    Text("·")
                        .foregroundStyle(textSecondary)
                        .font(.system(size: 11))
                    
                    Text(item.createdAt.formatted(.dateTime.month().day().year()))
                        .font(.system(size: 11))
                        .foregroundStyle(textSecondary)
                }
            }
            .padding(16)
            .background(isSelected ? accentBlue.opacity(0.2) : (isHovering ? cardBG.opacity(0.8) : cardBG))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? accentBlue : borderSubtle, lineWidth: 1)
            )
            .onHover { hovering in
                isHovering = hovering
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Explore Right View
struct EmbeddingsExploreRightView: View {
    @Bindable var viewModel: EmbeddingWorkspaceViewModel
    
    // Theme colors
    private let primaryBG = Color(red: 28/255, green: 28/255, blue: 30/255)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    
    var body: some View {
        VStack {
            if let selectedID = viewModel.selectedPointID, let item = viewModel.exploreItems.first(where: { $0.id == selectedID }) {
                // We reuse the right pane populated state from Generate since it looks identical to an embedding detail
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Selected Embedding Detail")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text(item.text)
                            .font(.system(size: 15))
                            .foregroundStyle(textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(red: 44/255, green: 44/255, blue: 46/255))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                        
                        if let stats = viewModel.selectedPointStats {
                            VectorWaveformView(vector: item.vector)
                            
                            EmbeddingStatisticsView(
                                dimension: item.dimension,
                                norm: stats.l2Norm,
                                mean: stats.mean,
                                variance: stats.variance,
                                nonZero: stats.sparsity,
                                maxVal: stats.max
                            )
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(32)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 32))
                        .foregroundStyle(textSecondary)
                    Text("Select an embedding to view details")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(primaryBG)
    }
}
