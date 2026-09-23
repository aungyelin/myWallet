//
//  ScreenHeaderView.swift
//  myWallet
//
//  Created by Ye Lin Aung on 22/9/2569 BE.
//

import SwiftUI

struct ScreenHeaderView<Accessory: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let accessory: () -> Accessory
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder accessory: @escaping () -> Accessory = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: LayoutMetrics.spacingMicro) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            accessory()
        }
        .padding(.horizontal, LayoutMetrics.headerHorizontalPadding)
        .padding(.top, LayoutMetrics.headerTopPadding)
        .padding(.bottom, LayoutMetrics.headerVerticalPadding)
        .frame(maxWidth: LayoutMetrics.maxContentWidth)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

extension ScreenHeaderView where Accessory == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle, accessory: { EmptyView() })
    }
}

#Preview("ScreenHeaderView - iPhone") {
    VStack {
        ScreenHeaderView(title: String(localized: "app_name"), subtitle: String(localized: "home_screen_title")) {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(Color.accentColor)
        }
        Spacer()
    }
}

#Preview("ScreenHeaderView - iPad", traits: .fixedLayout(width: 800, height: 200)) {
    ScreenHeaderView(title: String(localized: "nav_profile"))
}
