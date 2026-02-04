#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib
import os
import cairo

# Experimentations Project XDR - OSD Indicator
# Transparent Overlay Strategy for Wayland positioning

class VoiceKeyboardOSD:
    def __init__(self):
        self.window = Gtk.Window(type=Gtk.WindowType.TOPLEVEL)
        self.window.set_title("Voice-Keyboard-OSD")
        
        # Core flags
        self.window.set_keep_above(True)
        self.window.set_accept_focus(False)
        self.window.set_can_focus(False)
        self.window.set_decorated(False)
        self.window.set_skip_taskbar_hint(True)
        self.window.set_skip_pager_hint(True)
        
        # Make it a notification/utility to avoid some WM decorations or behaviors
        self.window.set_type_hint(Gdk.WindowTypeHint.NOTIFICATION)
        
        # Full transparency support
        screen = Gdk.Screen.get_default()
        visual = screen.get_rgba_visual()
        if visual:
            self.window.set_visual(visual)
        
        self.window.set_app_paintable(True)
        self.window.connect('draw', self.on_draw)
        self.window.connect("map", self.on_map)

        # Strategy: Full Screen Window to "position" the dot in the top-right
        # On Wayland, this is more reliable than window.move()
        monitor = screen.get_primary_monitor()
        geometry = screen.get_monitor_geometry(monitor)
        self.screen_width = geometry.width
        self.screen_height = geometry.height
        
        # Set window size to match screen
        self.window.set_default_size(self.screen_width, self.screen_height)
        self.window.set_size_request(self.screen_width, self.screen_height)
        
        # State management
        runtime_dir = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
        self.state_file = os.path.join(runtime_dir, "voice-keyboard.state")
        self.is_active = False

        GLib.timeout_add(200, self.check_state)

    def on_map(self, widget):
        # Empty input region = FULL CLICK-THROUGH
        # Even if the window is full screen, the user can click through it
        region = cairo.Region()
        self.window.input_shape_combine_region(region)

    def on_draw(self, widget, cr):
        # 1. Clear everything (Full Transparency)
        cr.set_source_rgba(0, 0, 0, 0)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        
        # 2. Draw the dot in the TOP-RIGHT corner
        # Margin: 30px from top, 30px from right
        dot_x = self.screen_width - 30
        dot_y = 30
        dot_radius = 10

        cr.set_operator(cairo.OPERATOR_OVER)
        
        # Red Dot with a slight glow effect
        cr.set_source_rgba(1.0, 0.0, 0.0, 0.9)
        cr.arc(dot_x, dot_y, dot_radius, 0, 2 * 3.14159)
        cr.fill()
        
        # Simple white border for contrast
        cr.set_source_rgba(1, 1, 1, 0.5)
        cr.set_line_width(2)
        cr.arc(dot_x, dot_y, dot_radius, 0, 2 * 3.14159)
        cr.stroke()
        
        return False

    def check_state(self):
        try:
            if os.path.exists(self.state_file):
                with open(self.state_file, 'r') as f:
                    state = f.read().strip()
                    if state == "ACTIVE":
                        if not self.is_active:
                            self.window.show_all()
                            # Re-maximize or ensure fullscreen if needed
                            self.window.maximize() # Helps on some Wayland compositors
                            self.is_active = True
                    else:
                        if self.is_active:
                            self.window.hide()
                            self.is_active = False
            else:
                if self.is_active:
                    self.window.hide()
                    self.is_active = False
        except Exception:
            pass
        return True

    def run(self):
        Gtk.main()

if __name__ == "__main__":
    osd = VoiceKeyboardOSD()
    osd.run()
