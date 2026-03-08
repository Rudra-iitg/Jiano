import SwiftUI
import SwiftData

struct VectorWaveformView: View {
    let vector: [Double]
    @State private var showAll = false
    
    // Theme colors
    private let primaryBG = Color(red: 28/255, green: 28/255, blue: 30/255)
    private let cardBG = Color(red: 44/255, green: 44/255, blue: 46/255)
    private let borderSubtle = Color.white.opacity(0.08)
    private let textSecondary = Color(red: 142/255, green: 142/255, blue: 147/255)
    private let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label {
                    Text("Vector Waveform")
                        .font(.system(size: 15, weight: .semibold))
                } icon: {
                    Image(systemName: "waveform")
                        .foregroundStyle(accentBlue)
                }
                
                Spacer()
                
                Toggle("Show all", isOn: $showAll)
                    .font(.system(size: 12))
                    .toggleStyle(SwitchToggleStyle(tint: accentBlue))
                    .scaleEffect(0.8)
            }
            
            let displayCount = showAll ? vector.count : min(256, vector.count)
            let displayVector = Array(vector.prefix(displayCount))
            
            // Background Canvas for drawing
            GeometryReader { geometry in
                let midY = geometry.size.height / 2
                let width = geometry.size.width
                
                Canvas { context, size in
                    guard !displayVector.isEmpty else { return }
                    
                    // Normalize vector values to max abstract
                    let maxAbs = displayVector.map { abs($0) }.max() ?? 1.0
                    let safeMax = maxAbs > 0 ? maxAbs : 1.0
                    
                    let spacing: CGFloat = displayVector.count > 100 ? 1 : 2
                    let barWidth = max(0.5, (width - (CGFloat(displayVector.count) * spacing)) / CGFloat(displayVector.count))
                    
                    for (index, value) in displayVector.enumerated() {
                        let normalizedValue = (abs(value) / safeMax) * Double(midY * 0.8) // 80% height padding
                        let x = CGFloat(index) * (barWidth + spacing)
                        
                        let path = Path { p in
                            if value > 0 {
                                p.move(to: CGPoint(x: x + barWidth/2, y: midY))
                                p.addLine(to: CGPoint(x: x + barWidth/2, y: midY - CGFloat(normalizedValue)))
                            } else {
                                p.move(to: CGPoint(x: x + barWidth/2, y: midY))
                                p.addLine(to: CGPoint(x: x + barWidth/2, y: midY + CGFloat(normalizedValue)))
                            }
                        }
                        
                        let color = value >= 0 ? accentBlue : Color.orange
                        
                        context.stroke(
                            path,
                            with: .color(color),
                            style: StrokeStyle(lineWidth: barWidth, lineCap: .round)
                        )
                    }
                    
                    // Center Line
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: 0, y: midY))
                            p.addLine(to: CGPoint(x: width, y: midY))
                        },
                        with: .color(Color.white.opacity(0.1)),
                        lineWidth: 1
                    )
                }
            }
            .frame(height: 180)
            .padding(12)
            .background(primaryBG)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderSubtle, lineWidth: 1)
            )
            
            Text("Showing \(displayCount) of \(vector.count) dimensions")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
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
