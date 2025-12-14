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
            <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=0.1, maximum-scale=5.0, user-scalable=yes">
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
                    width: 100%;
                    height: 100%;
                    overflow: auto;
                    -webkit-overflow-scrolling: touch;
                }
                
                .mermaid {
                    padding: 16px;
                    width: 100%;
                    min-height: 100vh;
                }
                
                .mermaid svg {
                    display: block;
                    margin: 0 auto;
                    max-width: 100%;
                    height: auto;
                }
                
                /* Zoom controls */
                .zoom-controls {
                    position: fixed;
                    bottom: 20px;
                    right: 20px;
                    display: flex;
                    flex-direction: column;
                    gap: 8px;
                    z-index: 1000;
                }
                
                .zoom-btn {
                    width: 44px;
                    height: 44px;
                    border-radius: 22px;
                    border: 2px solid #00FF9D;
                    background: rgba(18, 18, 18, 0.95);
                    color: #00FF9D;
                    font-size: 24px;
                    font-weight: bold;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }
                
                .zoom-btn:active {
                    background: #00FF9D;
                    color: #050505;
                }
                
                .zoom-level {
                    text-align: center;
                    font-size: 11px;
                    color: #00FF9D;
                    background: rgba(18, 18, 18, 0.95);
                    padding: 4px 8px;
                    border-radius: 12px;
                }
                
                /* Mermaid Dark Theme Overrides */
                .node rect, .node circle, .node polygon {
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
                
                .actor {
                    fill: #121212 !important;
                    stroke: #00FF9D !important;
                }
                
                .actor-line { stroke: #444 !important; }
                .messageText { fill: #E0E0E0 !important; }
                .messageLine0, .messageLine1 { stroke: #00F0FF !important; }
                
                .classGroup .title { fill: #00FF9D !important; }
                .classGroup .classText { fill: #E0E0E0 !important; }
                g.classGroup rect { fill: #121212 !important; stroke: #00FF9D !important; }
                .relation { stroke: #00F0FF !important; }
            </style>
        </head>
        <body>
            <div class="mermaid" id="diagram">
            \(escapedCode)
            </div>
            
            <div class="zoom-controls">
                <button class="zoom-btn" onclick="zoomIn()">+</button>
                <div class="zoom-level" id="zoomLevel">100%</div>
                <button class="zoom-btn" onclick="zoomOut()">−</button>
                <button class="zoom-btn" onclick="resetZoom()" style="font-size: 14px;">↺</button>
            </div>
            
            <script>
                let currentZoom = 100;
                const diagram = document.getElementById('diagram');
                const zoomLevelEl = document.getElementById('zoomLevel');
                
                function setZoom(percent) {
                    currentZoom = Math.max(25, Math.min(400, percent));
                    const svg = diagram.querySelector('svg');
                    if (svg) {
                        svg.style.transform = 'scale(' + (currentZoom / 100) + ')';
                        svg.style.transformOrigin = 'top center';
                    }
                    zoomLevelEl.textContent = currentZoom + '%';
                }
                
                function zoomIn() { setZoom(currentZoom + 25); }
                function zoomOut() { setZoom(currentZoom - 25); }
                function resetZoom() { setZoom(100); }
                
                mermaid.initialize({
                    startOnLoad: true,
                    theme: 'dark',
                    themeVariables: {
                        primaryColor: '#121212',
                        primaryTextColor: '#E0E0E0',
                        primaryBorderColor: '#00FF9D',
                        lineColor: '#00F0FF',
                        secondaryColor: '#1A1A1A',
                        background: '#050505',
                        mainBkg: '#121212',
                        nodeBkg: '#121212',
                        nodeBorder: '#00FF9D',
                        clusterBkg: '#1A1A1A',
                        titleColor: '#00FF9D',
                        edgeLabelBackground: '#050505',
                        actorBorder: '#00FF9D',
                        actorBkg: '#121212',
                        actorTextColor: '#E0E0E0',
                        signalColor: '#00F0FF',
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
