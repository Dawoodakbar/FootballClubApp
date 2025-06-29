//
//  InteractiveChartView.swift
//  FootballClub
//
//  Created by Dawood Akbar on 29/06/2025.
//
import SwiftUI

// MARK: - Chart Data Point
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let color: Color
    let trend: TrendDirection?
    
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
}

// MARK: - Chart Type Enum
enum ChartType {
    case bar, line, pie
}

// MARK: - Interactive Chart View
struct InteractiveChartView: View {
    let data: [ChartDataPoint]
    let title: String
    let type: ChartType
    let onDataPointPress: ((ChartDataPoint, Int) -> Void)?
    
    @State private var selectedIndex: Int? = nil
    @State private var animationProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 20) {
            chartTitle
            chartContent
            selectedDataInfo
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var chartTitle: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
    
    @ViewBuilder
    private var chartContent: some View {
        Group {
            switch type {
            case .bar:
                BarChartContent(
                    data: data,
                    selectedIndex: $selectedIndex,
                    animationProgress: animationProgress,
                    onDataPointPress: handleDataPointTap
                )
            case .line:
                LineChartContent(
                    data: data,
                    selectedIndex: $selectedIndex,
                    animationProgress: animationProgress,
                    onDataPointPress: handleDataPointTap
                )
            case .pie:
                PieChartContent(
                    data: data,
                    selectedIndex: $selectedIndex,
                    animationProgress: animationProgress,
                    onDataPointPress: handleDataPointTap
                )
            }
        }
        .frame(height: 200)
    }
    
    @ViewBuilder
    private var selectedDataInfo: some View {
        if let selectedIndex = selectedIndex {
            SelectedDataInfoView(dataPoint: data[selectedIndex])
        }
    }
    
    private func handleDataPointTap(_ dataPoint: ChartDataPoint, _ index: Int) {
        withAnimation(.spring(response: 0.3)) {
            selectedIndex = selectedIndex == index ? nil : index
        }
        onDataPointPress?(dataPoint, index)
    }
}

// MARK: - Bar Chart Content
struct BarChartContent: View {
    let data: [ChartDataPoint]
    @Binding var selectedIndex: Int?
    let animationProgress: Double
    let onDataPointPress: (ChartDataPoint, Int) -> Void
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                BarChartBar(
                    dataPoint: dataPoint,
                    index: index,
                    isSelected: selectedIndex == index,
                    animationProgress: animationProgress,
                    onTap: { onDataPointPress(dataPoint, index) }
                )
            }
        }
    }
}

// MARK: - Bar Chart Bar
struct BarChartBar: View {
    let dataPoint: ChartDataPoint
    let index: Int
    let isSelected: Bool
    let animationProgress: Double
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(dataPoint.color.opacity(0.3))
                    .frame(width: 30)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(dataPoint.color)
                    .frame(width: 30, height: CGFloat(dataPoint.value * animationProgress * 2))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isSelected)
            }
            .frame(height: 120)
            .onTapGesture(perform: onTap)
            
            Text("\(Int(dataPoint.value))")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(dataPoint.label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let trend = dataPoint.trend {
                Image(systemName: trend.icon)
                    .font(.caption2)
                    .foregroundColor(trend.color)
            }
        }
    }
}

// MARK: - Line Chart Content
struct LineChartContent: View {
    let data: [ChartDataPoint]
    @Binding var selectedIndex: Int?
    let animationProgress: Double
    let onDataPointPress: (ChartDataPoint, Int) -> Void
    
    var body: some View {
        ZStack {
            linePathView
            dataPointsView
        }
    }
    
    private var linePathView: some View {
        Path { path in
            guard !data.isEmpty else { return }
            
            let maxValue = data.map(\.value).max() ?? 1
            let width: CGFloat = 280
            let height: CGFloat = 120
            let stepX = width / CGFloat(data.count - 1)
            
            for (index, dataPoint) in data.enumerated() {
                let x = CGFloat(index) * stepX
                let y = height - (CGFloat(dataPoint.value) / CGFloat(maxValue)) * height * animationProgress
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(Color.blue, lineWidth: 3)
    }
    
    private var dataPointsView: some View {
        HStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                LineChartPoint(
                    dataPoint: dataPoint,
                    index: index,
                    isSelected: selectedIndex == index,
                    animationProgress: animationProgress,
                    onTap: { onDataPointPress(dataPoint, index) }
                )
            }
        }
        .frame(height: 120)
    }
}

// MARK: - Line Chart Point
struct LineChartPoint: View {
    let dataPoint: ChartDataPoint
    let index: Int
    let isSelected: Bool
    let animationProgress: Double
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            Circle()
                .fill(dataPoint.color)
                .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                .scaleEffect(animationProgress)
                .animation(.spring(response: 0.3), value: isSelected)
                .onTapGesture(perform: onTap)
            
            if isSelected {
                Text("\(Int(dataPoint.value))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(4)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Spacer()
            
            Text(dataPoint.label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Pie Chart Content
struct PieChartContent: View {
    let data: [ChartDataPoint]
    @Binding var selectedIndex: Int?
    let animationProgress: Double
    let onDataPointPress: (ChartDataPoint, Int) -> Void
    
    var body: some View {
        HStack {
            pieChartView
            pieLegendView
        }
    }
    
    private var pieChartView: some View {
        ZStack {
            ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                PieSliceView(
                    dataPoint: dataPoint,
                    index: index,
                    data: data,
                    isSelected: selectedIndex == index,
                    animationProgress: animationProgress,
                    onTap: { onDataPointPress(dataPoint, index) }
                )
            }
        }
        .frame(width: 120, height: 120)
        .rotationEffect(.degrees(-90))
        .scaleEffect(animationProgress)
    }
    
    private var pieLegendView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                PieLegendItem(
                    dataPoint: dataPoint,
                    index: index,
                    onTap: { onDataPointPress(dataPoint, index) }
                )
            }
        }
    }
}

// MARK: - Pie Slice View
struct PieSliceView: View {
    let dataPoint: ChartDataPoint
    let index: Int
    let data: [ChartDataPoint]
    let isSelected: Bool
    let animationProgress: Double
    let onTap: () -> Void
    
    var body: some View {
        let total = data.reduce(0) { $0 + $1.value }
        let percentage = dataPoint.value / total
        let startAngle = data.prefix(index).reduce(0) { $0 + $1.value } / total * 360
        let endAngle = startAngle + (percentage * 360)
        
        PieSlice(
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            isSelected: isSelected
        )
        .fill(dataPoint.color)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Pie Legend Item
struct PieLegendItem: View {
    let dataPoint: ChartDataPoint
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(dataPoint.color)
                .frame(width: 12, height: 12)
            
            Text("\(dataPoint.label): \(Int(dataPoint.value))")
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Pie Slice Shape
struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let isSelected: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Selected Data Info View
struct SelectedDataInfoView: View {
    let dataPoint: ChartDataPoint
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dataPoint.label)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Value: \(Int(dataPoint.value))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

//struct InteractiveChartView_Previews: PreviewProvider {
//    
//    
//    static var previews: some View {
//        InteractiveChartView(
//            data: [
//                ChartDataPoint(label: "Wins", value: 15, color: .green, trend: .up),
//                ChartDataPoint(label: "Draws", value: 8, color: .orange, trend: .stable),
//                ChartDataPoint(label: "Losses", value: 4, color: .red, trend: .down)
//            ],
//            title: "Team Performance",
//            type: .bar,
//            onDataPointPress: { dataPoint, index in
//                print("Tapped: \(dataPoint.label) at index \(index)")
//                )
//                    .padding()
//  
//    }
//}
//        }
