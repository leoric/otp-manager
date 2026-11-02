import SwiftUI

struct CustomCircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round, dash: [2, 3]))
                .foregroundColor(Color.white.opacity(0.8))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
        }
        .frame(width: 22, height: 22)
    }
}