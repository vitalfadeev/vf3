             Building package profdump in /home/vf/.dub/packages/profdump/0.4.3/profdump/
    Starting Performing "debug" build using /usr/bin/dmd for x86_64.
  Up-to-date profdump 0.4.3: target for configuration [application] is up to date.
    Finished To force a rebuild of up-to-date targets, run again with --force
     Running ../../../.dub/packages/profdump/0.4.3/profdump/profdump -b trace.log
void main()                             	1028.70593s 100.00%
void app.event_loop(ref sdl.video.SDL_Window*, sdl.render.SDL_Renderer*, ref app.Frame)	584.09515s 56.78%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select.draw(sdl.render.SDL_Renderer*)	263.92142s 25.66%
types.Size ui.render.Render.render_struct!(file.Dir.linux_dirent64).render_struct(file.Dir.linux_dirent64*, int[])	263.36761s 25.60%
types.Size ui.render.Render.render_chars(..)	261.48798s 25.42%
types.Size gl_side.draw_draws!(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int)	28.32797s 2.75%
int cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache.opApply(scope int delegate(ui.render.Render.E))	28.17378s 2.74%
bindbc.sdl.config.SDLSupport sdl.loadSDL(..)	25.75533s 2.50%
bindbc.sdl.config.SDLSupport sdl.loadSDL()	25.52330s 2.48%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select._draw_selection(sdl.render.SDL_Renderer*, ulong, file.Dir.linux_dirent64)	23.24456s 2.26%
int font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator.opApply(scope int delegate(ui.render.Render.E))	20.67881s 2.01%
int gl_side.draw_draws!(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int).__foreachbody5(ui.render.Render.E)	7.15251s 0.70%
SDL_RenderDrawLines                     	5.23199s 0.51%
FT_Request_Size                         	3.57337s 0.35%
FT_New_Size                             	3.32626s 0.32%
FT_Get_Module                           	2.07061s 0.20%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(..).__arrayAlloc(..)	1.68671s 0.16%
FT_MulDiv                               	1.64794s 0.16%
sdl.rect.SDL_Point[] object.dup!(sdl.rect.SDL_Point).dup(const(sdl.rect.SDL_Point)[])	1.55859s 0.15%
sdl.rect.SDL_Point[] core.internal.array.duplication._dup!(const(sdl.rect.SDL_Point), sdl.rect.SDL_Point)._dup(scope const(sdl.rect.SDL_Point)[])	1.45684s 0.14%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(sdl.rect.SDL_Point).__arrayAlloc(..)	0.89029s 0.09%
int function(ui.render.Render.E) cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache.opApply(scope int delegate(ui.render.Render.E)).__foreachbody8	0.59538s 0.06%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(..)._d_arraysetlengthT(..)	0.56766s 0.06%
ref sdl.rect.SDL_Point[] core.internal.array.appending._d_arrayappendcTX!(sdl.rect.SDL_Point[], sdl.rect.SDL_Point)._d_arrayappendcTX(scope return ref sdl.rect.SDL_Point[], ulong)	0.50745s 0.05%
char[] core.internal.array.duplication._dup!(..)._dup(..)	0.50617s 0.05%
FT_DivFix                               	0.50087s 0.05%
void app.Frame._load_dir()              	0.46115s 0.04%
void bindbc.loader.sharedlib.bindSymbol(bindbc.loader.sharedlib.SharedLib, void**, const(..)	0.37164s 0.04%
extern (..) int font.Glyph_to_points!(ui.render.Render.E).Glyph_to_points.line_to_cb(const(ft.image.FT_Vector*), void*)	0.33121s 0.03%
void app.load_FT()                      	0.32253s 0.03%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType()	0.32198s 0.03%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType(..)	0.32145s 0.03%
FT_List_Add                             	0.25440s 0.02%
int file.Dir.ID.Iterator.opApply(scope int delegate(file.Dir.linux_dirent64*))	0.21682s 0.02%
extern (..) int font.Glyph_to_points!(ui.render.Render.E).Glyph_to_points.coni_to_cb(const(ft.image.FT_Vector*), const(ft.image.FT_Vector*), void*)	0.21187s 0.02%
extern (..) int font.Glyph_to_points!(ui.render.Render.E).Glyph_to_points.move_to_cb(const(ft.image.FT_Vector*), void*)	0.20547s 0.02%
FT_MulFix                               	0.20262s 0.02%
ref file.Dir.ID file.Dir.ID.__ctor(..)  	0.19423s 0.02%
ref ui.render.Render.E[] core.internal.array.appending._d_arrayappendcTX!(ui.render.Render.E[], ui.render.Render.E)._d_arrayappendcTX(scope return ref ui.render.Render.E[], ulong)	0.18681s 0.02%
char[] core.internal.string.signedToTempString!(..).signedToTempString(..)	0.13583s 0.01%
int app.Frame._load_dir().__foreachbody3(file.Dir.linux_dirent64*)	0.13247s 0.01%
ref file.Dir.linux_dirent64[] core.internal.array.appending._d_arrayappendcTX!(file.Dir.linux_dirent64[], file.Dir.linux_dirent64)._d_arrayappendcTX(scope return ref file.Dir.linux_dirent64[], ulong)	0.10942s 0.01%
bool core.internal.array.utils.__setArrayAllocLength!(sdl.rect.SDL_Point).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.08927s 0.01%
FT_Add_Default_Modules                  	0.08371s 0.01%
FT_Add_Module                           	0.08105s 0.01%
cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)	0.07977s 0.01%
const bool cache.Cache_id.opEquals(ref const(cache.Cache_id))	0.07653s 0.01%
bool core.internal.array.utils.__setArrayAllocLength!(..).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.06409s 0.01%
bool std.range.primitives.empty!(..).empty(..)	0.04947s 0.00%
void sdl.video.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03922s 0.00%
void sdl.stdinc.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03408s 0.00%
void sdl.render.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.02987s 0.00%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(..)._d_arraysetlengthT(..)	0.02875s 0.00%
char[] core.internal.string.unsignedToTempString!(..).unsignedToTempString(..)	0.02673s 0.00%
FT_Outline_Get_CBox                     	0.02254s 0.00%
inout(..)[] std.string.fromStringz!(..).fromStringz(..)	0.01842s 0.00%
FT_Get_Font_Format                      	0.01584s 0.00%
FT_New_Library                          	0.01059s 0.00%
const ulong cache.Cache_id.toHash()     	0.01010s 0.00%
FT_Outline_Check                        	0.00908s 0.00%
FT_List_Finalize                        	0.00412s 0.00%
FT_Set_Default_Properties               	0.00165s 0.00%
void app.Frame.event(sdl.events.SDL_Event*)	0.00135s 0.00%
FT_Library_SetLcdFilter                 	0.00051s 0.00%
bool core.internal.array.equality.__equals!(..).__equals(..)	0.00050s 0.00%
int core.internal.string.dstrcmp!().dstrcmp(..)	0.00037s 0.00%
void ui.select_2._Select_2!(app.Frame.E1*, app.Frame.E2*)._Select_2.event(sdl.events.SDL_Event*)	0.00005s 0.00%
void ui.select._Select!(file.Dir.linux_dirent64[])._Select.event(sdl.events.SDL_Event*)	0.00002s 0.00%
