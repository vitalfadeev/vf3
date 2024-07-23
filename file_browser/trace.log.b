             Building package profdump in /home/vf/.dub/packages/profdump/0.4.3/profdump/
    Starting Performing "debug" build using /usr/bin/dmd for x86_64.
  Up-to-date profdump 0.4.3: target for configuration [application] is up to date.
    Finished To force a rebuild of up-to-date targets, run again with --force
     Running ../../../.dub/packages/profdump/0.4.3/profdump/profdump -b trace.log
void main()                             	1386.72131s 100.00%
void app.event_loop(ref sdl.video.SDL_Window*, sdl.render.SDL_Renderer*, ref app.Frame)	876.53180s 63.21%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select.draw(sdl.render.SDL_Renderer*)	23.93289s 1.73%
types.Size ui.render.Render.render_struct!(file.Dir.linux_dirent64).render_struct(file.Dir.linux_dirent64*, int[])	23.65375s 1.71%
types.Size ui.render.Render.render_chars(..)	22.89379s 1.65%
types.Size gl_side.draw_draws!(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int)	21.69406s 1.56%
int cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache.opApply(scope int delegate(font.Font.ID.E))	21.52705s 1.55%
bindbc.sdl.config.SDLSupport sdl.loadSDL(..)	19.01988s 1.37%
bindbc.sdl.config.SDLSupport sdl.loadSDL()	18.80172s 1.36%
int font.Font.ID.Iterator.opApply(scope int delegate(font.Font.ID.E))	17.37344s 1.25%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select._draw_selection(sdl.render.SDL_Renderer*, ulong, file.Dir.linux_dirent64)	7.47308s 0.54%
int gl_side.draw_draws!(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int).__foreachbody5(font.Font.ID.E)	3.40885s 0.25%
SDL_RenderDrawLines                     	2.03524s 0.15%
sdl.rect.SDL_Point[] object.dup!(sdl.rect.SDL_Point).dup(const(sdl.rect.SDL_Point)[])	1.05622s 0.08%
sdl.rect.SDL_Point[] core.internal.array.duplication._dup!(const(sdl.rect.SDL_Point), sdl.rect.SDL_Point)._dup(scope const(sdl.rect.SDL_Point)[])	0.97674s 0.07%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(sdl.rect.SDL_Point).__arrayAlloc(..)	0.67528s 0.05%
void bindbc.loader.sharedlib.bindSymbol(bindbc.loader.sharedlib.SharedLib, void**, const(..)	0.37339s 0.03%
char[] core.internal.array.duplication._dup!(..)._dup(..)	0.35407s 0.03%
void app.load_FT()                      	0.32775s 0.02%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType()	0.32694s 0.02%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType(..)	0.32646s 0.02%
FT_MulDiv                               	0.32105s 0.02%
void app.Frame._load_dir()              	0.31265s 0.02%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(..).__arrayAlloc(..)	0.24625s 0.02%
ref sdl.rect.SDL_Point[] core.internal.array.appending._d_arrayappendcTX!(sdl.rect.SDL_Point[], sdl.rect.SDL_Point)._d_arrayappendcTX(scope return ref sdl.rect.SDL_Point[], ulong)	0.21872s 0.02%
int file.Dir.ID.Iterator.opApply(scope int delegate(file.Dir.linux_dirent64*))	0.20604s 0.01%
char[] core.internal.string.signedToTempString!(..).signedToTempString(..)	0.17977s 0.01%
extern (..) int font.Font.ID.Iterator.coni_to_cb(const(ft.image.FT_Vector*), const(ft.image.FT_Vector*), void*)	0.14344s 0.01%
extern (..) int font.Font.ID.Iterator.move_to_cb(const(ft.image.FT_Vector*), void*)	0.13242s 0.01%
int app.Frame._load_dir().__foreachbody3(file.Dir.linux_dirent64*)	0.12298s 0.01%
ref file.Dir.linux_dirent64[] core.internal.array.appending._d_arrayappendcTX!(file.Dir.linux_dirent64[], file.Dir.linux_dirent64)._d_arrayappendcTX(scope return ref file.Dir.linux_dirent64[], ulong)	0.10690s 0.01%
extern (..) int font.Font.ID.Iterator.line_to_cb(const(ft.image.FT_Vector*), void*)	0.09915s 0.01%
ref font.Font.ID.E.Contur[] core.internal.array.appending._d_arrayappendcTX!(font.Font.ID.E.Contur[], font.Font.ID.E.Contur)._d_arrayappendcTX(scope return ref font.Font.ID.E.Contur[], ulong)	0.09832s 0.01%
FT_Add_Default_Modules                  	0.07537s 0.01%
ref file.Dir.ID file.Dir.ID.__ctor(..)  	0.07519s 0.01%
FT_Add_Module                           	0.07266s 0.01%
cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)	0.05739s 0.00%
FT_Request_Size                         	0.05300s 0.00%
void sdl.video.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03934s 0.00%
FT_Get_Module                           	0.03473s 0.00%
void sdl.stdinc.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03410s 0.00%
const bool cache.Cache_id.opEquals(ref const(cache.Cache_id))	0.03163s 0.00%
void sdl.render.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.02972s 0.00%
bool core.internal.array.utils.__setArrayAllocLength!(sdl.rect.SDL_Point).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.02797s 0.00%
const ulong cache.Cache_id.toHash()     	0.02769s 0.00%
int function(font.Font.ID.E) cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache.opApply(scope int delegate(font.Font.ID.E)).__foreachbody8	0.02755s 0.00%
FT_New_Size                             	0.02209s 0.00%
ref font.Font.ID.E[] core.internal.array.appending._d_arrayappendcTX!(font.Font.ID.E[], font.Font.ID.E)._d_arrayappendcTX(scope return ref font.Font.ID.E[], ulong)	0.01774s 0.00%
char[] core.internal.string.unsignedToTempString!(..).unsignedToTempString(..)	0.01669s 0.00%
bool core.internal.array.utils.__setArrayAllocLength!(..).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.01346s 0.00%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(..)._d_arraysetlengthT(..)	0.01129s 0.00%
FT_New_Library                          	0.01114s 0.00%
FT_Outline_Get_CBox                     	0.01041s 0.00%
inout(..)[] std.string.fromStringz!(..).fromStringz(..)	0.00916s 0.00%
FT_DivFix                               	0.00883s 0.00%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(file.Dir.linux_dirent64[], file.Dir.linux_dirent64)._d_arraysetlengthT(return scope ref file.Dir.linux_dirent64[], ulong)	0.00677s 0.00%
FT_Get_Font_Format                      	0.00623s 0.00%
FT_List_Add                             	0.00340s 0.00%
FT_Outline_Check                        	0.00332s 0.00%
FT_List_Finalize                        	0.00250s 0.00%
FT_MulFix                               	0.00219s 0.00%
void app.Frame.event(sdl.events.SDL_Event*)	0.00215s 0.00%
FT_Set_Default_Properties               	0.00156s 0.00%
void ui.select._Select!(file.Dir.linux_dirent64[])._Select.event(sdl.events.SDL_Event*)	0.00081s 0.00%
FT_Library_SetLcdFilter                 	0.00048s 0.00%
bool core.internal.array.equality.__equals!(..).__equals(..)	0.00045s 0.00%
void ui.select._Select!(file.Dir.linux_dirent64[])._Select.on_key(sdl.events.SDL_KeyboardEvent*)	0.00042s 0.00%
int core.internal.string.dstrcmp!().dstrcmp(..)	0.00035s 0.00%
bool std.range.primitives.empty!(..).empty(..)	0.00028s 0.00%
void ui.select_2._Select_2!(app.Frame.E1*, app.Frame.E2*)._Select_2.event(sdl.events.SDL_Event*)	0.00023s 0.00%
void ui.select_2._Select_2!(app.Frame.E1*, app.Frame.E2*)._Select_2.on_key(sdl.events.SDL_KeyboardEvent*)	0.00010s 0.00%
