// ComfyUI Square Nodes - Browser Console Script
// Copy and paste this into your browser's developer console (F12) while ComfyUI is open

(function() {
    'use strict';
    
    console.log("Applying square nodes styling...");
    
    // Remove existing square nodes style if present
    const existingStyle = document.getElementById('square-nodes-override');
    if (existingStyle) {
        existingStyle.remove();
    }
    
    // CSS to make nodes square
    const css = `
        /* ComfyUI Square Nodes - Remove rounded corners */
        .litegraph .lgraphnode {
            border-radius: 0 !important;
        }

        .litegraph .lgraphnode .title {
            border-radius: 0 !important;
            border-top-left-radius: 0 !important;
            border-top-right-radius: 0 !important;
        }

        .litegraph .lgraphnode .content {
            border-radius: 0 !important;
            border-bottom-left-radius: 0 !important;
            border-bottom-right-radius: 0 !important;
        }

        .litegraph .lgraphnode .widget {
            border-radius: 0 !important;
        }

        .litegraph .lgraphnode .slot,
        .litegraph .lgraphnode .slot_input,
        .litegraph .lgraphnode .slot_output,
        .litegraph .lgraphnode .node_slot {
            border-radius: 0 !important;
        }

        .litegraph .lgraphnode.selected {
            border-radius: 0 !important;
        }

        .litegraph .lgraphgroup {
            border-radius: 0 !important;
        }
        
        .litegraph canvas {
            --node-border-radius: 0px !important;
        }
    `;
    
    // Inject the CSS
    const style = document.createElement('style');
    style.id = 'square-nodes-override';
    style.type = 'text/css';
    style.textContent = css;
    document.head.appendChild(style);
    
    // Configure LiteGraph if available
    if (window.LiteGraph && window.LGraphNode) {
        // Set default shape
        if (window.LiteGraph.BOX_SHAPE !== undefined) {
            window.LiteGraph.NODE_DEFAULT_SHAPE = window.LiteGraph.BOX_SHAPE;
        } else {
            window.LiteGraph.NODE_DEFAULT_SHAPE = 1; // BOX_SHAPE value
        }
        
        // Override existing nodes
        if (window.app && window.app.graph && window.app.graph._nodes) {
            window.app.graph._nodes.forEach(node => {
                if (node.shape !== undefined) node.shape = 1;
                if (node.round_radius !== undefined) node.round_radius = 0;
            });
        }
        
        // Override prototype for new nodes
        if (window.LGraphNode.prototype) {
            window.LGraphNode.prototype.shape = 1;
            window.LGraphNode.prototype.round_radius = 0;
        }
        
        console.log("Square nodes: LiteGraph configuration updated");
    }
    
    // Force redraw if possible
    if (window.app && window.app.graph && window.app.graph.setDirtyCanvas) {
        window.app.graph.setDirtyCanvas(true, true);
    }
    
    console.log("Square nodes styling applied successfully!");
    console.log("If you don't see changes immediately, try adding a new node to the graph.");
    
})();