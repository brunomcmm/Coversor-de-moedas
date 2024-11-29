//
//  ExchangeRateChart.swift
//  Conversor de Moedas
//
//  Este módulo gerencia o componente do gráfico para exibir a variação das taxas de câmbio.
//  Criado por Bruno Maciel em 29/11/2024.
//

import SwiftUI
import Charts

struct ExchangeRateChartView: View {
    let rates: [Double]

    var body: some View {
        Chart {
            ForEach(Array(rates.enumerated()), id: \.offset) { index, rate in
                LineMark(
                    x: .value("Dia", index),
                    y: .value("Taxa", rate)
                )
            }
        }
        .chartYAxis {
            AxisMarks(values: .stride(by: 10)) {
                AxisValueLabel()
            }
        }
        .chartYScale(domain: calculateYAxisDomain()) // Ajusta o limite inferior
        .chartXAxis {
            AxisMarks() // Sem rótulos no eixo X
        }
    }

    /// Calcula o domínio do eixo Y com base nos valores
    private func calculateYAxisDomain() -> ClosedRange<Double> {
        let minRate = rates.min() ?? 0.0
        let maxRate = rates.max() ?? 0.0
        return (minRate - 20)...(maxRate)
    }
}
