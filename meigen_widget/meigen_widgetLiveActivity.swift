//
//  meigen_widgetLiveActivity.swift
//  meigen_widget
//
//  Created by 1460969 on 2023/12/08.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct meigen_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct meigen_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: meigen_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension meigen_widgetAttributes {
    fileprivate static var preview: meigen_widgetAttributes {
        meigen_widgetAttributes(name: "World")
    }
}

extension meigen_widgetAttributes.ContentState {
    fileprivate static var smiley: meigen_widgetAttributes.ContentState {
        meigen_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: meigen_widgetAttributes.ContentState {
         meigen_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: meigen_widgetAttributes.preview) {
   meigen_widgetLiveActivity()
} contentStates: {
    meigen_widgetAttributes.ContentState.smiley
    meigen_widgetAttributes.ContentState.starEyes
}
