//
//  SplashView.swift
//  3180941
//
//  Created by student01 on 2026/3/29.
//

import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                Text("摊")
                    .font(.system(size: 72, weight: .black))
                    .foregroundStyle(.black)

                Text("让烟火日常被看见")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.tanSecondary)

                Spacer()

                Text("成都市井档案数字化保护平台")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onFinished()
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(onFinished: { })
    }
}
