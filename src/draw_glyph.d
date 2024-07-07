import glyph;
import sdl_gfx_backend;

alias g =SDL_GFX_Backend;

// Glyph - draw - G
//   glyph.draw (g)
//   g.draw (glyph)
void
draw (G)(ref G g, ref Glyph glyph) {
    glyph
        .lines ()   // G_lines
        .each ()    // G_lines_iter
        .draw (g);  // G_lines_iter.draw () -> G_line.draw () -> G.draw_line ()
}

pragma (inline,true)
void
draw (G) (ref Glyph glyph, ref G g) {
    g.draw (glyph);
}
