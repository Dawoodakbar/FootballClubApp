
import SwiftUI

// MARK: - Chart Data Models
struct MonthlyPerformance: Identifiable {
    let id = UUID()
    let month: Int
    let wins: Int
    let draws: Int
    let losses: Int
    let goalsFor: Int
    let goalsAgainst: Int
}

struct GoalsChartData: Identifiable {
    let id = UUID()
    let month: String
    let goalsFor: Int
    let goalsAgainst: Int
}

// MARK: - Analytics Card Component
struct AnalyticsCard: View {
    let title: String
    let value: String
    let trend: TrendDirection
    let color: Color
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .stable: return .orange
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Custom Bar Chart Component
struct CustomBarChart: View {
    let data: [MonthlyPerformance]
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Match Results by Month")
                .font(.headline)
                .foregroundColor(.primary)
            
            chartContent
            
            chartLegend
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var chartContent: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(data.prefix(6).enumerated()), id: \.offset) { index, point in
                VStack(spacing: 2) {
                    barStack(for: point)
                    monthLabel(for: point)
                }
            }
        }
        .frame(height: 150)
    }
    
    private func barStack(for point: MonthlyPerformance) -> some View {
        VStack(spacing: 1) {
            // Wins (Green)
            Rectangle()
                .fill(Color.green)
                //.frame(width: 25, height: CGFloat(point.wins) * 15 * animationProgress)
            
            // Draws (Orange)
            Rectangle()
                .fill(Color.orange)
               // .frame(width: 25, height: CGFloat(point.draws) * 15 * animationProgress)
            
            // Losses (Red)
            Rectangle()
                .fill(Color.red)
//.frame(width: 25, height: CGFloat(point.losses) * 15 * animationProgress)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
    
    private func monthLabel(for point: MonthlyPerformance) -> some View {
        Text("M\(point.month)")
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    
    private var chartLegend: some View {
        HStack(spacing: 16) {
            legendItem(color: .green, label: "Wins")
            legendItem(color: .orange, label: "Draws")
            legendItem(color: .red, label: "Losses")
        }
        .padding(.top, 8)
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .clipShape(RoundedRectangle(cornerRadius: 2))
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Custom Line Chart Component
struct CustomLineChart: View {
    let data: [GoalsChartData]
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Goals For vs Against")
                .font(.headline)
                .foregroundColor(.primary)
            
            chartContent
            
            chartLegend
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var chartContent: some View {
        ZStack {
            backgroundGrid
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(data.prefix(6).enumerated()), id: \.offset) { index, point in
                    dataPoint(for: point)
                }
            }
        }
        .frame(height: 120)
    }
    
    private var backgroundGrid: some View {
        VStack {
            ForEach(0..<5) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                Spacer()
            }
        }
    }
    
    private func dataPoint(for point: GoalsChartData) -> some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                // Goals For (Blue)
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .offset(y: -CGFloat(point.goalsFor) * 4 * animationProgress)
                
                // Goals Against (Red)
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(y: -CGFloat(point.goalsAgainst) * 4 * animationProgress)
            }
            .frame(height: 80)
            
            Text(point.month)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var chartLegend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Text("Goals For")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                Text("Goals Against")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }
}
