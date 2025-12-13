//
//  MermaidHelper.swift
//  DevAscent
//
//  Generates HTML to render Mermaid.js diagrams
//  Created by Rishiraj on 13/12/24.
//

import Foundation

/// Helper to generate HTML for rendering Mermaid.js diagrams in WKWebView
struct MermaidHelper {
    
    /// Generate full HTML page with Mermaid.js for rendering
    static func generateHTML(for mermaidCode: String) -> String {
        // Escape any special characters in the mermaid code
        let escapedCode = mermaidCode
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                
                html, body {
                    background-color: #050505;
                    color: #E0E0E0;
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    min-height: 100vh;
                    overflow-x: auto;
                    overflow-y: auto;
                }
                
                .mermaid {
                    display: flex;
                    justify-content: center;
                    padding: 20px;
                    min-width: 100%;
                }
                
                .mermaid svg {
                    max-width: none !important;
                }
                
                /* Mermaid Dark Theme Overrides */
                .node rect,
                .node circle,
                .node polygon {
                    fill: #121212 !important;
                    stroke: #00FF9D !important;
                    stroke-width: 2px !important;
                }
                
                .node .label {
                    color: #E0E0E0 !important;
                    fill: #E0E0E0 !important;
                }
                
                .edgePath .path {
                    stroke: #00F0FF !important;
                    stroke-width: 2px !important;
                }
                
                .edgeLabel {
                    background-color: #050505 !important;
                    color: #B0B0B0 !important;
                }
                
                .cluster rect {
                    fill: #1A1A1A !important;
                    stroke: #333 !important;
                }
                
                .cluster-label .nodeLabel {
                    color: #00FF9D !important;
                }
                
                /* Sequence diagram specific */
                .actor {
                    fill: #121212 !important;
                    stroke: #00FF9D !important;
                }
                
                .actor-line {
                    stroke: #444 !important;
                }
                
                .messageText {
                    fill: #E0E0E0 !important;
                }
                
                .messageLine0, .messageLine1 {
                    stroke: #00F0FF !important;
                }
                
                .activation0, .activation1 {
                    fill: #00FF9D !important;
                    opacity: 0.2;
                }
                
                /* Class diagram specific */
                .classGroup .title {
                    fill: #00FF9D !important;
                }
                
                .classGroup .classText {
                    fill: #E0E0E0 !important;
                }
                
                g.classGroup rect {
                    fill: #121212 !important;
                    stroke: #00FF9D !important;
                }
                
                .relation {
                    stroke: #00F0FF !important;
                }
                
                .cardinality text {
                    fill: #B0B0B0 !important;
                }
            </style>
        </head>
        <body>
            <div class="mermaid">
            \(escapedCode)
            </div>
            <script>
                mermaid.initialize({
                    startOnLoad: true,
                    theme: 'dark',
                    themeVariables: {
                        primaryColor: '#121212',
                        primaryTextColor: '#E0E0E0',
                        primaryBorderColor: '#00FF9D',
                        lineColor: '#00F0FF',
                        secondaryColor: '#1A1A1A',
                        tertiaryColor: '#0A0A0A',
                        background: '#050505',
                        mainBkg: '#121212',
                        nodeBkg: '#121212',
                        nodeBorder: '#00FF9D',
                        clusterBkg: '#1A1A1A',
                        clusterBorder: '#333',
                        titleColor: '#00FF9D',
                        edgeLabelBackground: '#050505',
                        actorBorder: '#00FF9D',
                        actorBkg: '#121212',
                        actorTextColor: '#E0E0E0',
                        actorLineColor: '#444',
                        signalColor: '#00F0FF',
                        signalTextColor: '#E0E0E0',
                        labelBoxBkgColor: '#121212',
                        labelBoxBorderColor: '#00FF9D',
                        labelTextColor: '#E0E0E0',
                        loopTextColor: '#E0E0E0',
                        noteBorderColor: '#00FF9D',
                        noteBkgColor: '#1A1A1A',
                        noteTextColor: '#E0E0E0',
                        activationBorderColor: '#00FF9D',
                        activationBkgColor: 'rgba(0, 255, 157, 0.2)',
                        sequenceNumberColor: '#00FF9D',
                        classText: '#E0E0E0'
                    },
                    securityLevel: 'loose',
                    fontFamily: '-apple-system, BlinkMacSystemFont, sans-serif'
                });
            </script>
        </body>
        </html>
        """
    }
}
