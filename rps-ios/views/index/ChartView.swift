//
//  ChartView.swift
//  rps-ios
//
//  Created by serika on 2023/11/19.
//

import SwiftUI
import DGCharts

struct ChartView: UIViewRepresentable {
    @Binding var curves: [Curve]
    
    
    func makeUIView(context: Context) -> DGCharts.LineChartView {
        print("ChartView makeUIView")
        let chart = LineChartView()
        chart.data = curveToData()
        chart.leftAxis.drawLabelsEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.axisLineDashLengths = [5, 5, 0]
        chart.rightAxis.enabled = false
        chart.xAxis.drawAxisLineEnabled = false
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.labelCount = curves.isEmpty ? 0 : curves[0].values.count - 1
        chart.xAxis.gridLineDashLengths = [5, 5, 0]
        chart.xAxis.drawLabelsEnabled = false
//        chart.xAxis.valueFormatter = XAxisFormatter(labels: curve.xAxisLabels)
        chart.legend.enabled = false
        return chart
    }
    
    private func colorForCurve(index: Int) -> Color {
        if index == 0 {
            return Color.main
        } else {
            return Color.green
        }
    }
    
    private func curveToData() -> LineChartData {
        let data = LineChartData()
        let dataSets = curves.enumerated().map { idx, curve in
            print("ChartView: curve:\(curve)")
            let dataSet = LineChartDataSet(
                entries: curve.values.enumerated().map { idx, value in
                    ChartDataEntry(x: Double(idx), y: value)
                },
                label: "abc"
            )
            dataSet.mode = .cubicBezier
            dataSet.drawValuesEnabled = false
            dataSet.drawCirclesEnabled = false
            let color = colorForCurve(index: idx)
            let colors = [color.cgColor, color.opacity(0).cgColor] as CFArray
            let locations:[CGFloat] = [1.0, 0.0]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: locations)
            if gradient == nil {
                dataSet.fill = ColorFill(color: .magenta)
            } else {
                dataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90)
            }
            dataSet.drawFilledEnabled = true
            dataSet.colors = [colorForCurve(index: idx).uiColor]
            return dataSet
        }
//        data.dataSets = [dataSet]
        data.dataSets = dataSets
        return data
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        print("ChartView updateUIView")
        uiView.data = curveToData()
    }
    
    typealias UIViewType = LineChartView
}

private class XAxisFormatter: NSObject, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: DGCharts.AxisBase?) -> String {
        labels[Int(value)]
    }
    
    let labels: [String]
    
    init(labels: [String]) {
        self.labels = labels
    }
}

#Preview {
    ChartView(curves: .constant([.mock, .mock]))
        .frame(height: 150)
        .padding(.horizontal)
}
