import SwiftUI

struct VolumeRingView: View {
    var decibel: Float
    var showPrompt: Bool
    
    var body: some View {
        ZStack {
            // Main volume ring
            Circle()
                .strokeBorder(Color.white.opacity(0.8), lineWidth: 2 + CGFloat(decibel) * 3)
                .frame(width: CGFloat(100 + (decibel * 100)),
                       height: CGFloat(100 + (decibel * 100)))
                .scaleEffect(1 + CGFloat(decibel) * 0.3)
                .opacity(0.5 + Double(decibel) * 0.5)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: decibel)
            
            // Prompt text that appears after 5 seconds of quietness
            if showPrompt {
                Text("큰 소리를 질러 개새들을 놀래키세요!")
                    .font(.system(size: 16 + CGFloat(decibel) * 10))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: decibel)
            }
        }
    }
}
