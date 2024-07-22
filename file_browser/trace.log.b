             Building package profdump in /home/vf/.dub/packages/profdump/0.4.3/profdump/
    Starting Performing "debug" build using /usr/bin/dmd for x86_64.
  Up-to-date profdump 0.4.3: target for configuration [application] is up to date.
    Finished To force a rebuild of up-to-date targets, run again with --force
     Running ../../../.dub/packages/profdump/0.4.3/profdump/profdump -b trace.log
void main()                             	2837.71582s 100.00%
void app.event_loop(ref sdl.video.SDL_Window*, sdl.render.SDL_Renderer*, ref app.Frame)	2229.06982s 78.55%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select.draw(sdl.render.SDL_Renderer*)	55.40667s 1.95%
types.Size ui.render.Render.render_struct!(file.Dir.linux_dirent64).render_struct(file.Dir.linux_dirent64*, int[])	54.14822s 1.91%
types.Size ui.render.Render.render_chars(..)	51.11101s 1.80%
types.Size gl_side.draw_draws!(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int)	43.51796s 1.53%
int cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache.opApply(scope int delegate(font.Font.ID.E))	42.08642s 1.48%
bindbc.sdl.config.SDLSupport sdl.loadSDL(..)	20.78907s 0.73%
int font.Font.ID.Iterator.opApply(scope int delegate(font.Font.ID.E))	20.64893s 0.73%
bindbc.sdl.config.SDLSupport sdl.loadSDL()	20.53478s 0.72%
types.Size ui.select._Select!(file.Dir.linux_dirent64[])._Select._draw_selection(sdl.render.SDL_Renderer*, ulong, file.Dir.linux_dirent64)	15.76294s 0.56%
int gl_side.draw_draws!(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache).draw_draws(cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache, sdl.render.SDL_Renderer*, types.Pos, int).__foreachbody5(font.Font.ID.E)	14.10507s 0.50%
SDL_RenderDrawLines                     	8.22014s 0.29%
sdl.rect.SDL_Point[] object.dup!(sdl.rect.SDL_Point).dup(const(sdl.rect.SDL_Point)[])	4.48519s 0.16%
sdl.rect.SDL_Point[] core.internal.array.duplication._dup!(const(sdl.rect.SDL_Point), sdl.rect.SDL_Point)._dup(scope const(sdl.rect.SDL_Point)[])	4.18849s 0.15%
const bool cache.Cache_id.opEquals(ref const(cache.Cache_id))	3.56085s 0.13%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(sdl.rect.SDL_Point).__arrayAlloc(..)	2.96059s 0.10%
char[] core.internal.array.duplication._dup!(..)._dup(..)	1.68923s 0.06%
core.memory.BlkInfo_ core.internal.array.utils.__arrayAlloc!(..).__arrayAlloc(..)	1.17963s 0.04%
void app.Frame._load_dir()              	0.66520s 0.02%
void bindbc.loader.sharedlib.bindSymbol(bindbc.loader.sharedlib.SharedLib, void**, const(..)	0.50988s 0.02%
void app.load_FT()                      	0.46628s 0.02%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType()	0.45374s 0.02%
bindbc.freetype.config.FTSupport bindbc.freetype.dynload.loadFreeType(..)	0.45309s 0.02%
FT_MulDiv                               	0.36788s 0.01%
char[] core.internal.string.signedToTempString!(..).signedToTempString(..)	0.36092s 0.01%
int file.Dir.ID.Iterator.opApply(scope int delegate(file.Dir.linux_dirent64*))	0.34748s 0.01%
ref file.Dir.ID file.Dir.ID.__ctor(..)  	0.29243s 0.01%
ref sdl.rect.SDL_Point[] core.internal.array.appending._d_arrayappendcTX!(sdl.rect.SDL_Point[], sdl.rect.SDL_Point)._d_arrayappendcTX(scope return ref sdl.rect.SDL_Point[], ulong)	0.23683s 0.01%
const ulong cache.Cache_id.toHash()     	0.22332s 0.01%
cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)	0.20299s 0.01%
int app.Frame._load_dir().__foreachbody3(file.Dir.linux_dirent64*)	0.20016s 0.01%
ref file.Dir.linux_dirent64[] core.internal.array.appending._d_arrayappendcTX!(file.Dir.linux_dirent64[], file.Dir.linux_dirent64)._d_arrayappendcTX(scope return ref file.Dir.linux_dirent64[], ulong)	0.18093s 0.01%
extern (..) int font.Font.ID.Iterator.move_to_cb(const(ft.image.FT_Vector*), void*)	0.17222s 0.01%
extern (..) int font.Font.ID.Iterator.coni_to_cb(const(ft.image.FT_Vector*), const(ft.image.FT_Vector*), void*)	0.15226s 0.01%
char[] core.internal.string.unsignedToTempString!(..).unsignedToTempString(..)	0.14477s 0.01%
ref font.Font.ID.E.Contur[] core.internal.array.appending._d_arrayappendcTX!(font.Font.ID.E.Contur[], font.Font.ID.E.Contur)._d_arrayappendcTX(scope return ref font.Font.ID.E.Contur[], ulong)	0.13444s 0.00%
bool core.internal.array.utils.__setArrayAllocLength!(sdl.rect.SDL_Point).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.10787s 0.00%
extern (..) int font.Font.ID.Iterator.line_to_cb(const(ft.image.FT_Vector*), void*)	0.10674s 0.00%
FT_Add_Default_Modules                  	0.09600s 0.00%
FT_Add_Module                           	0.09142s 0.00%
FT_Request_Size                         	0.06605s 0.00%
void sdl.video.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.05296s 0.00%
bool core.internal.array.utils.__setArrayAllocLength!(..).__setArrayAllocLength(ref core.memory.BlkInfo_, ulong, bool, ulong)	0.05291s 0.00%
FT_Get_Module                           	0.05236s 0.00%
void sdl.stdinc.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.04284s 0.00%
void sdl.render.bindModuleSymbols(bindbc.loader.sharedlib.SharedLib)	0.03782s 0.00%
inout(..)[] std.string.fromStringz!(..).fromStringz(..)	0.03439s 0.00%
FT_New_Size                             	0.03124s 0.00%
int function(font.Font.ID.E) cache.cache!(font.Font.ID.Iterator).cache(font.Font.ID.Iterator, cache.Cache_id)._cache.opApply(scope int delegate(font.Font.ID.E)).__foreachbody8	0.03108s 0.00%
ulong core.internal.array.capacity._d_arraysetlengthTImpl!(..)._d_arraysetlengthT(..)	0.02253s 0.00%
ref font.Font.ID.E[] core.internal.array.appending._d_arrayappendcTX!(font.Font.ID.E[], font.Font.ID.E)._d_arrayappendcTX(scope return ref font.Font.ID.E[], ulong)	0.01854s 0.00%
FT_Outline_Get_CBox                     	0.01546s 0.00%
FT_Get_Font_Format                      	0.01245s 0.00%
FT_New_Library                          	0.01227s 0.00%
FT_DivFix                               	0.01087s 0.00%
FT_Outline_Check                        	0.00633s 0.00%
FT_List_Add                             	0.00614s 0.00%
FT_Set_Default_Properties               	0.00510s 0.00%
FT_List_Finalize                        	0.00332s 0.00%
FT_MulFix                               	0.00228s 0.00%
void app.Frame.event(sdl.events.SDL_Event*)	0.00158s 0.00%
FT_Library_SetLcdFilter                 	0.00068s 0.00%
bool core.internal.array.equality.__equals!(..).__equals(..)	0.00059s 0.00%
int core.internal.string.dstrcmp!().dstrcmp(..)	0.00043s 0.00%
bool std.range.primitives.empty!(..).empty(..)	0.00019s 0.00%
void ui.select._Select!(file.Dir.linux_dirent64[])._Select.event(sdl.events.SDL_Event*)	0.00009s 0.00%
void ui.select_2._Select_2!(app.Frame.E1*, app.Frame.E2*)._Select_2.event(sdl.events.SDL_Event*)	0.00008s 0.00%
