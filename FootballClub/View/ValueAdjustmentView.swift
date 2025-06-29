//
//  ValueAdjustmentView.swift
//  FootballClub
//
//  Created by Dawood Akbar on 29/06/2025.
//

import SwiftUI

struct ValueAdjustmentView: View {
    @Binding var isPresented: Bool
    let title: String
    @State private var values: [String: Int]
    let onSave: ([String: Int]) -> Void
    
    private let valueLabels: [String: String]
    private let minValues: [String: Int]
    private let maxValues: [String: Int]
    
    init(
        isPresented: Binding<Bool>,
        title: String,
        values: [String: Int],
        valueLabels: [String: String] = [:],
        minValues: [String: Int] = [:],
        maxValues: [String: Int] = [:],
        onSave: @escaping ([String: Int]) -> Void
    ) {
        self._isPresented = isPresented
        self.title = title
        self._values = State(initialValue: values)
        self.valueLabels = valueLabels
        self.minValues = minValues
        self.maxValues = maxValues
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        instructionText
                        
                        // Value adjustment controls
                        ForEach(Array(values.keys.sorted()), id: \.self) { key in
                            valueAdjustmentRow(for: key)
                        }
                        
                        // Quick adjustment buttons
                        quickAdjustmentButtons
                        
                        // Summary
                        summaryView
                    }
                    .padding()
                }
                
                // Footer
                footerView
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var headerView: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .leading,
                endPoint: .trailing
            )
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Save") {
                    onSave(values)
                    isPresented = false
                }
                .foregroundColor(.white)
                .fontWeight(.semibold)
            }
            .padding()
        }
        .frame(height: 100)
    }
    
    private var instructionText: some View {
        Text("Adjust the values below using the +/- buttons or by entering values directly")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
    
    private func valueAdjustmentRow(for key: String) -> some View {
        VStack(spacing: 12) {
            Text(valueLabels[key] ?? key.capitalized)
                .font(.headline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Decrease button
                Button(action: { adjustValue(for: key, by: -1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
                .disabled(values[key, default: 0] <= minValues[key, default: 0])
                
                // Value display and input
                TextField("Value", value: Binding(
                    get: { values[key, default: 0] },
                    set: { newValue in
                        let clampedValue = max(minValues[key, default: 0], min(maxValues[key, default: 999], newValue))
                        values[key] = clampedValue
                    }
                ), format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.semibold)
                .frame(width: 80)
                .keyboardType(.numberPad)
                
                // Increase button
                Button(action: { adjustValue(for: key, by: 1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .disabled(values[key, default: 0] >= maxValues[key, default: 999])
            }
            
            // Range indicator
            Text("Range: \(minValues[key, default: 0]) - \(maxValues[key, default: 999])")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var quickAdjustmentButtons: some View {
        VStack(spacing: 12) {
            Text("Quick Adjustments")
                .font(.headline)
                .fontWeight(.medium)
            
            HStack(spacing: 16) {
                Button(action: { adjustAllValues(by: 5) }) {
                    Label("+5 All", systemImage: "plus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Button(action: { adjustAllValues(by: -5) }) {
                    Label("-5 All", systemImage: "minus")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Button(action: resetValues) {
                    Text("Reset")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var summaryView: some View {
        VStack(spacing: 8) {
            Text("Summary")
                .font(.headline)
                .fontWeight(.medium)
            
            HStack {
                VStack {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(values.values.reduce(0, +))")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack {
                    Text("Average")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(values.isEmpty ? 0 : values.values.reduce(0, +) / values.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var footerView: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                isPresented = false
            }
            .font(.headline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button("Save Changes") {
                onSave(values)
                isPresented = false
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func adjustValue(for key: String, by amount: Int) {
           let currentValue = values[key] ?? 0
           let newValue = currentValue + amount
           let min = minValues[key] ?? 0
           let max = maxValues[key] ?? 999
           
           values[key] = Swift.max(min, Swift.min(max, newValue))
       }
    
    private func adjustAllValues(by amount: Int) {
        for key in values.keys {
            adjustValue(for: key, by: amount)
        }
    }
    
    private func resetValues() {
        // Reset to original values (you might want to pass original values as parameter)
        for key in values.keys {
            values[key] = 0
        }
    }
}

