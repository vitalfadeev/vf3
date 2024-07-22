             Building package profdump in /home/vf/.dub/packages/profdump/0.4.3/profdump/
    Starting Performing "debug" build using /usr/bin/dmd for x86_64.
  Up-to-date profdump 0.4.3: target for configuration [application] is up to date.
    Finished To force a rebuild of up-to-date targets, run again with --force
     Running ../../../.dub/packages/profdump/0.4.3/profdump/profdump -b trace.log
void main()                             	1022.75220s 100.00%
void app.event_loop(ref sdl.video.SDL_Window*, sdl.render.SDL_Renderer*, ref app.Frame)	501.92606s 49.08%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select.draw(sdl.render.SDL_Renderer*)	165.10139s 16.14%
types.Size ui.render.Render.render_struct!(file.Dir.linux_dirent64).render_struct(file.Dir.linux_dirent64*, int[])	164.71622s 16.11%
types.Size ui.render.Render.render_chars(..)	163.36427s 15.97%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select._draw_selection(sdl.render.SDL_Renderer*, ulong, file.Dir.linux_dirent64)	31.06371s 3.04%
bindbc.sdl.config.SDLSupport sdl.loadSDL(..)	22.57928s 2.21%
bindbc.sdl.config.SDLSupport sdl.loadSDL()	22.34950s 2.19%
types.Size gl_side.draw_draws!(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int)	19.96152s 1.95%
int cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache.opApply(scope int delegate(ui.render.Render.E))	19.79735s 1.94%
int font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator.opApply(scope int delegate(ui.render.Render.E))	14.52181s 1.42%
int gl_side.draw_draws!(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int).__foreachbody5(ui.render.Render.E)	4.19983s 0.41%
SDL_RenderDrawLines                     	2.96751s 0.29%
FT_New_Size                             	2.01603s 0.20%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(..).__arrayAlloc(..)	1.09864s 0.11%
FT_Get_Module                           	1.08888s 0.11%
sdl.rect.SDL_Point[] object.dup!(sdl.rect.SDL_Point).dup(const(sdl.rect.SDL_Point)[])	0.92556s 0.09%
sdl.rect.SDL_Point[] core.internal.array.duplication._dup!(const(sdl.rect.SDL_Point), sdl.rect.SDL_Point)._dup(scope const(sdl.rect.SDL_Point)[])	0.86269s 0.08%
FT_MulDiv                               	0.69812s 0.07%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(sdl.rect.SDL_Point).__arrayAlloc(..)	0.50905s 0.05%
char[] core.internal.array.duplication._dup!(..)._dup(..)	0.42525s 0.04%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(..)._d_arraysetlengthT(..)	0.39683s 0.04%
void bindbc.loader.sharedlib.bindSymbol(bindbc.loader.sharedlib.SharedLib, void**, const(..)	0.36659s 0.04%
void app.load_FT()                      	0.32535s 0.03%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType()	0.32482s 0.03%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType(..)	0.32430s 0.03%
void app.Frame._load_dir()              	0.30809s 0.03%
ref sdl.rect.SDL_Point[] core.internal.array.appending._d_arrayappendcTX!(sdl.rect.SDL_Point[], sdl.rect.SDL_Point)._d_arrayappendcTX(scope return ref sdl.rect.SDL_Point[], ulong)	0.23334s 0.02%
FT_Add_Default_Modules                  	0.20120s 0.02%
int file.Dir.ID.Iterator.opApply(scope int delegate(file.Dir.linux_dirent64*))	0.20087s 0.02%
FT_Add_Module                           	0.19823s 0.02%
FT_List_Add                             	0.16599s 0.02%
extern (..) int font.Glyph_to_points!(ui.render.Render.E).Glyph_to_points.move_to_cb(const(ft.image.FT_Vector*), void*)	0.15669s 0.02%
extern (..) int font.Glyph_to_points!(ui.render.Render.E).Glyph_to_points.coni_to_cb(const(ft.image.FT_Vector*), const(ft.image.FT_Vector*), void*)	0.13955s 0.01%
int app.Frame._load_dir().__foreachbody3(file.Dir.linux_dirent64*)	0.12069s 0.01%
ref ui.render.Render.E.Contur[] core.internal.array.appending._d_arrayappendcTX!(ui.render.Render.E.Contur[], ui.render.Render.E.Contur)._d_arrayappendcTX(scope return ref ui.render.Render.E.Contur[], ulong)	0.11653s 0.01%
extern (..) int font.Glyph_to_points!(ui.render.Render.E).Glyph_to_points.line_to_cb(const(ft.image.FT_Vector*), void*)	0.11528s 0.01%
ref file.Dir.linux_dirent64[] core.internal.array.appending._d_arrayappendcTX!(file.Dir.linux_dirent64[], file.Dir.linux_dirent64)._d_arrayappendcTX(scope return ref file.Dir.linux_dirent64[], ulong)	0.10519s 0.01%
char[] core.internal.string.signedToTempString!(..).signedToTempString(..)	0.08756s 0.01%
ref file.Dir.ID file.Dir.ID.__ctor(..)  	0.07720s 0.01%
FT_Request_Size                         	0.07252s 0.01%
cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)	0.05713s 0.01%
const bool cache.Cache_id.opEquals(ref const(cache.Cache_id))	0.04149s 0.00%
void sdl.video.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03974s 0.00%
bool core.internal.array.utils.__setArrayAllocLength!(..).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.03963s 0.00%
void sdl.stdinc.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03366s 0.00%
bool core.internal.array.utils.__setArrayAllocLength!(sdl.rect.SDL_Point).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.03176s 0.00%
void sdl.render.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03029s 0.00%
int function(ui.render.Render.E) cache.cache!(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator).cache(font.Font_Glyph.ID.Iterator!(ui.render.Render.E).Iterator, cache.Cache_id)._cache.opApply(scope int delegate(ui.render.Render.E)).__foreachbody8	0.02849s 0.00%
ref ui.render.Render.E[] core.internal.array.appending._d_arrayappendcTX!(ui.render.Render.E[], ui.render.Render.E)._d_arrayappendcTX(scope return ref ui.render.Render.E[], ulong)	0.01718s 0.00%
char[] core.internal.string.unsignedToTempString!(..).unsignedToTempString(..)	0.01632s 0.00%
const ulong cache.Cache_id.toHash()     	0.01432s 0.00%
bool std.range.primitives.empty!(..).empty(..)	0.01422s 0.00%
FT_DivFix                               	0.01345s 0.00%
FT_Outline_Get_CBox                     	0.01286s 0.00%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(..)._d_arraysetlengthT(..)	0.01153s 0.00%
inout(..)[] std.string.fromStringz!(..).fromStringz(..)	0.01128s 0.00%
FT_Get_Font_Format                      	0.00879s 0.00%
FT_New_Library                          	0.00800s 0.00%
FT_Outline_Check                        	0.00503s 0.00%
FT_MulFix                               	0.00364s 0.00%
FT_List_Finalize                        	0.00245s 0.00%
void app.Frame.event(sdl.events.SDL_Event*)	0.00206s 0.00%
FT_Set_Default_Properties               	0.00191s 0.00%
bool core.internal.array.equality.__equals!(..).__equals(..)	0.00050s 0.00%
int core.internal.string.dstrcmp!().dstrcmp(..)	0.00049s 0.00%
FT_Library_SetLcdFilter                 	0.00044s 0.00%
void ui.select_2._Select_2!(app.Frame.E1*, app.Frame.E2*)._Select_2.event(sdl.events.SDL_Event*)	0.00006s 0.00%
void ui.select._Select!(file.Dir.linux_dirent64[])._Select.event(sdl.events.SDL_Event*)	0.00005s 0.00%
