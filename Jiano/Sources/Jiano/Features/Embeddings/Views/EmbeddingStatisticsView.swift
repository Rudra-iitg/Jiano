import SwiftUI
import SwiftData

struct EmbeddingStatisticsView: View {
    let dimension: Int
    let norm: Double
    let mean: Double
    let variance: Double
    let nonZero: Double
    let maxVal: Double
    
    // Theme colors
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Statistics")
                    .font(.system(size: 15, weight: .semibold))
            } icon: {
                Image(systemName: "chart.bar")
                    .foregroundStyle(accentBlue)
            }
            
            // 2x3 Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                statCard(title: "Dimensions", value: "\(dimension)")
                statCard(title: "Magnitude", value: String(format: "%.3f", norm))
                statCard(title: "Mean", value: String(format: "%.4f", mean))
                statCard(title: "Std Dev", value: String(format: "%.3f", sqrt(variance)))
                statCard(title: "Non-zero", value: String(format: "%.1f%%", (1.0 - nonZero) * 100))
                statCard(title: "Max value", value: String(format: "%.3f", maxVal))
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
    
    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)
                .lineLimit(1)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(red: 28/255, green: 28/255, blue: 30/255))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(borderSubtle, lineWidth: 1)
        )
    }
}
