module imgui_ns;

import core.stdc.string;
import core.stdc.float_ : FLT_MAX;
import core.stdc.stdarg;
import core.stdc.stdlib;

import imgui_base;
import gen = imgui_ns_gen;

/// marker attribute that python script will search for, does nothing by itself
struct pyExtract{}


// Dear ImGui end-user API
// (In a namespace so you can add extra functions in your own separate file. Please don't modify imgui.cpp/.h!)
extern(C++, ImGui) nothrow {
    // Context creation and access
    // Each context create its own ImFontAtlas by default. You may instance one yourself and pass it to CreateContext() to share a font atlas between imgui contexts.
    // All those functions are not reliant on the current context.
    ImGuiContext* CreateContext(ImFontAtlas* shared_font_atlas = null);
    void          DestroyContext(ImGuiContext* ctx = null);   // NULL = destroy current context
    ImGuiContext* GetCurrentContext();
    void          SetCurrentContext(ImGuiContext* ctx);
    bool          DebugCheckVersionAndDataLayout(const(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert);

    // Main
    ref ImGuiIO   GetIO();                                    // access the IO structure (mouse/keyboard/gamepad inputs, time, various configuration options/flags)
    ref ImGuiStyle GetStyle();                                // access the Style structure (colors, sizes). Always use PushStyleCol(), PushStyleVar() to modify style mid-frame.
    void          NewFrame();                                 // start a new ImGui frame, you can submit any command from this point until Render()/EndFrame().
    void          EndFrame();                                 // ends the ImGui frame. automatically called by Render(), so most likely don't need to ever call that yourself directly. If you don't need to render you may call EndFrame() but you'll have wasted CPU already. If you don't need to render, better to not create any imgui windows instead!
    void          Render();                                   // ends the ImGui frame, finalize the draw data. (Obsolete: optionally call io.RenderDrawListsFn if set. Nowadays, prefer calling your render function yourself.)
    ImDrawData*   GetDrawData();                              // valid after Render() and until the next call to NewFrame(). this is what you have to render. (Obsolete: this used to be passed to your io.RenderDrawListsFn() function.)

    // Demo, Debug, Information
    void          ShowDemoWindow(bool* p_open = null);        // create demo/test window (previously called ShowTestWindow). demonstrate most ImGui features. call this to learn about the library! try to make it always available in your application!
    void          ShowMetricsWindow(bool* p_open = null);     // create metrics window. display ImGui internals: draw commands (with individual draw calls and vertices), window list, basic internal state, etc.
    void          ShowStyleEditor(ImGuiStyle* ref_ = null);   // add style editor block (not a window). you can pass in a reference ImGuiStyle structure to compare to, revert to and save to (else it uses the default style)
    bool          ShowStyleSelector(const(char)* label);      // add style selector block (not a window), essentially a combo listing the default styles.
    void          ShowFontSelector(const(char)* label);       // add font selector block (not a window), essentially a combo listing the loaded fonts.
    void          ShowUserGuide();                            // add basic help/info block (not a window): how to manipulate ImGui as a end-user (mouse/keyboard controls).
    const(char)*  GetVersion();                               // get a version string e.g. "1.23"

    // Styles
    void          StyleColorsDark(ImGuiStyle* dst = null);    // new, recommended style (default)
    void          StyleColorsClassic(ImGuiStyle* dst = null); // classic imgui style
    void          StyleColorsLight(ImGuiStyle* dst = null);   // best used with borders and a custom, thicker font

    // Windows
    // (Begin = push window to the stack and start appending to it. End = pop window from the stack. You may append multiple times to the same window during the same frame)
    // Begin()/BeginChild() return false to indicate the window being collapsed or fully clipped, so you may early out and omit submitting anything to the window.
    // You need to always call a matching End()/EndChild() for a Begin()/BeginChild() call, regardless of its return value (this is due to legacy reason and is inconsistent with BeginMenu/EndMenu, BeginPopup/EndPopup and other functions where the End call should only be called if the corresponding Begin function returned true.)
    // Passing 'bool* p_open != NULL' shows a close widget in the upper-right corner of the window, which when clicking will set the boolean to false.
    // Use child windows to introduce independent scrolling/clipping regions within a host window. Child windows can embed their own child.
    bool          Begin(const(char)* name, bool* p_open = null, ImGuiWindowFlags flags = 0);
    void          End();
    bool          BeginChild(const(char)* str_id, const ref ImVec2 size = ImVec2(0,0).byRef, bool border = false, ImGuiWindowFlags flags = 0); // Begin a scrolling region. size==0.0f: use remaining window size, size<0.0f: use remaining window size minus abs(size). size>0.0f: fixed size. each axis can use a different mode, e.g. ImVec2(0,400).
    bool          BeginChild(ImGuiID id, const ref ImVec2 size = ImVec2(0,0).byRef, bool border = false, ImGuiWindowFlags flags = 0);
    void          EndChild();

    // Windows Utilities
    bool          IsWindowAppearing();
    bool          IsWindowCollapsed();
    bool          IsWindowFocused(ImGuiFocusedFlags flags=0); // is current window focused? or its root/child, depending on flags. see flags for options.
    bool          IsWindowHovered(ImGuiHoveredFlags flags=0); // is current window hovered (and typically: not blocked by a popup/modal)? see flags for options. NB: If you are trying to check whether your mouse should be dispatched to imgui or to your app, you should use the 'io.WantCaptureMouse' boolean for that! Please read the FAQ!
    ImDrawList*   GetWindowDrawList();                        // get draw list associated to the window, to append your own drawing primitives
    ImVec2        GetWindowPos();                             // get current window position in screen space (useful if you want to do your own drawing via the DrawList API)
    ImVec2        GetWindowSize();                            // get current window size
    float         GetWindowWidth();                           // get current window width (shortcut for GetWindowSize().x)
    float         GetWindowHeight();                          // get current window height (shortcut for GetWindowSize().y)
    ImVec2        GetContentRegionMax();                      // current content boundaries (typically window boundaries including scrolling, or current column boundaries), in windows coordinates
    ImVec2        GetContentRegionAvail();                    // == GetContentRegionMax() - GetCursorPos()
    float         GetContentRegionAvailWidth();               //
    ImVec2        GetWindowContentRegionMin();                // content boundaries min (roughly (0,0)-Scroll), in window coordinates
    ImVec2        GetWindowContentRegionMax();                // content boundaries max (roughly (0,0)+Size-Scroll) where Size can be override with SetNextWindowContentSize(), in window coordinates
    float         GetWindowContentRegionWidth();              //

    void          SetNextWindowPos(const ref ImVec2 pos, ImGuiCond cond = 0, const ref ImVec2 pivot = ImVec2(0,0).byRef); // set next window position. call before Begin(). use pivot=(0.5f,0.5f) to center on given point, etc.
    void          SetNextWindowSize(const ref ImVec2 size, ImGuiCond cond = 0);                  // set next window size. set axis to 0.0f to force an auto-fit on this axis. call before Begin()
    void          SetNextWindowSizeConstraints(const ref ImVec2 size_min, const ref ImVec2 size_max, ImGuiSizeCallback custom_callback = null, void* custom_callback_data = null); // set next window size limits. use -1,-1 on either X/Y axis to preserve the current size. Use callback to apply non-trivial programmatic constraints.
    void          SetNextWindowContentSize(const ref ImVec2 size);                               // set next window content size (~ enforce the range of scrollbars). not including window decorations (title bar, menu bar, etc.). set an axis to 0.0f to leave it automatic. call before Begin()
    void          SetNextWindowCollapsed(bool collapsed, ImGuiCond cond = 0);                 // set next window collapsed state. call before Begin()
    void          SetNextWindowFocus();                                                       // set next window to be focused / front-most. call before Begin()
    void          SetNextWindowBgAlpha(float alpha);                                          // set next window background color alpha. helper to easily modify ImGuiCol_WindowBg/ChildBg/PopupBg.
    void          SetWindowPos(const ref ImVec2 pos, ImGuiCond cond = 0);                        // (not recommended) set current window position - call within Begin()/End(). prefer using SetNextWindowPos(), as this may incur tearing and side-effects.
    void          SetWindowSize(const ref ImVec2 size, ImGuiCond cond = 0);                      // (not recommended) set current window size - call within Begin()/End(). set to ImVec2(0,0) to force an auto-fit. prefer using SetNextWindowSize(), as this may incur tearing and minor side-effects.
    void          SetWindowCollapsed(bool collapsed, ImGuiCond cond = 0);                     // (not recommended) set current window collapsed state. prefer using SetNextWindowCollapsed().
    void          SetWindowFocus();                                                           // (not recommended) set current window to be focused / front-most. prefer using SetNextWindowFocus().
    void          SetWindowFontScale(float scale);                                            // set font scale. Adjust IO.FontGlobalScale if you want to scale all windows
    void          SetWindowPos(const(char)* name, const ref ImVec2 pos, ImGuiCond cond = 0);      // set named window position.
    void          SetWindowSize(const(char)* name, const ref ImVec2 size, ImGuiCond cond = 0);    // set named window size. set axis to 0.0f to force an auto-fit on this axis.
    void          SetWindowCollapsed(const(char)* name, bool collapsed, ImGuiCond cond = 0);   // set named window collapsed state
    void          SetWindowFocus(const(char)* name);                                           // set named window to be focused / front-most. use NULL to remove focus.

    // Windows Scrolling
    float         GetScrollX();                                                   // get scrolling amount [0..GetScrollMaxX()]
    float         GetScrollY();                                                   // get scrolling amount [0..GetScrollMaxY()]
    float         GetScrollMaxX();                                                // get maximum scrolling amount ~~ ContentSize.X - WindowSize.X
    float         GetScrollMaxY();                                                // get maximum scrolling amount ~~ ContentSize.Y - WindowSize.Y
    void          SetScrollX(float scroll_x);                                     // set scrolling amount [0..GetScrollMaxX()]
    void          SetScrollY(float scroll_y);                                     // set scrolling amount [0..GetScrollMaxY()]
    void          SetScrollHere(float center_y_ratio = 0.5f);                     // adjust scrolling amount to make current cursor position visible. center_y_ratio=0.0: top, 0.5: center, 1.0: bottom. When using to make a "default/current item" visible, consider using SetItemDefaultFocus() instead.
    void          SetScrollFromPosY(float pos_y, float center_y_ratio = 0.5f);    // adjust scrolling amount to make given position valid. use GetCursorPos() or GetCursorStartPos()+offset to get valid positions.

    // Parameters stacks (shared)
    void          PushFont(ImFont* font);                                         // use NULL as a shortcut to push default font
    void          PopFont();
    void          PushStyleColor(ImGuiCol idx, ImU32 col);
    void          PushStyleColor(ImGuiCol idx, const ref ImVec4 col);
    void          PopStyleColor(int count = 1);
    void          PushStyleVar(ImGuiStyleVar idx, float val);
    void          PushStyleVar(ImGuiStyleVar idx, const ref ImVec2 val);
    void          PopStyleVar(int count = 1);
    ref const(ImVec4) GetStyleColorVec4(ImGuiCol idx);                            // retrieve style color as stored in ImGuiStyle structure. use to feed back into PushStyleColor(), otherwise use GetColorU32() to get style color with style alpha baked in.
    ImFont*       GetFont();                                                      // get current font
    float         GetFontSize();                                                  // get current font size (= height in pixels) of current font with current scale applied
    ImVec2        GetFontTexUvWhitePixel();                                       // get UV coordinate for a while pixel, useful to draw custom shapes via the ImDrawList API
    ImU32         GetColorU32(ImGuiCol idx, float alpha_mul = 1.0f);              // retrieve given style color with style alpha applied and optional extra alpha multiplier
    ImU32         GetColorU32(const ref ImVec4 col);                              // retrieve given color with style alpha applied
    ImU32         GetColorU32(ImU32 col);                                         // retrieve given color with style alpha applied

    // Parameters stacks (current window)
    void          PushItemWidth(float item_width);                                // width of items for the common item+label case, pixels. 0.0f = default to ~2/3 of windows width, >0.0f: width in pixels, <0.0f align xx pixels to the right of window (so -1.0f always align width to the right side)
    void          PopItemWidth();
    float         CalcItemWidth();                                                // width of item given pushed settings and current cursor position
    void          PushTextWrapPos(float wrap_pos_x = 0.0f);                       // word-wrapping for Text*() commands. < 0.0f: no wrapping; 0.0f: wrap to end of window (or column); > 0.0f: wrap at 'wrap_pos_x' position in window local space
    void          PopTextWrapPos();
    void          PushAllowKeyboardFocus(bool allow_keyboard_focus);              // allow focusing using TAB/Shift-TAB, enabled by default but you can disable it for certain widgets
    void          PopAllowKeyboardFocus();
    void          PushButtonRepeat(bool repeat);                                  // in 'repeat' mode, Button*() functions return repeated true in a typematic manner (using io.KeyRepeatDelay/io.KeyRepeatRate setting). Note that you can call IsItemActive() after any Button() to tell if the button is held in the current frame.
    void          PopButtonRepeat();

    // Cursor / Layout
    void          Separator();                                                    // separator, generally horizontal. inside a menu bar or in horizontal layout mode, this becomes a vertical separator.
    void          SameLine(float pos_x = 0.0f, float spacing_w = -1.0f);          // call between widgets or groups to layout them horizontally
    void          NewLine();                                                      // undo a SameLine()
    void          Spacing();                                                      // add vertical spacing
    void          Dummy(const ref ImVec2 size);                                      // add a dummy item of given size
    void          Indent(float indent_w = 0.0f);                                  // move content position toward the right, by style.IndentSpacing or indent_w if != 0
    void          Unindent(float indent_w = 0.0f);                                // move content position back to the left, by style.IndentSpacing or indent_w if != 0
    void          BeginGroup();                                                   // lock horizontal starting position + capture group bounding box into one "item" (so you can use IsItemHovered() or layout primitives such as SameLine() on whole group, etc.)
    void          EndGroup();
    ImVec2        GetCursorPos();                                                 // cursor position is relative to window position
    float         GetCursorPosX();                                                // "
    float         GetCursorPosY();                                                // "
    void          SetCursorPos(const ref ImVec2 local_pos);                       // "
    void          SetCursorPosX(float x);                                         // "
    void          SetCursorPosY(float y);                                         // "
    ImVec2        GetCursorStartPos();                                            // initial cursor position
    ImVec2        GetCursorScreenPos();                                           // cursor position in absolute screen coordinates [0..io.DisplaySize] (useful to work with ImDrawList API)
    void          SetCursorScreenPos(const ref ImVec2 screen_pos);                // cursor position in absolute screen coordinates [0..io.DisplaySize]
    void          AlignTextToFramePadding();                                      // vertically align upcoming text baseline to FramePadding.y so that it will align properly to regularly framed items (call if you have text on a line before a framed item)
    float         GetTextLineHeight();                                            // ~ FontSize
    float         GetTextLineHeightWithSpacing();                                 // ~ FontSize + style.ItemSpacing.y (distance in pixels between 2 consecutive lines of text)
    float         GetFrameHeight();                                               // ~ FontSize + style.FramePadding.y * 2
    float         GetFrameHeightWithSpacing();                                    // ~ FontSize + style.FramePadding.y * 2 + style.ItemSpacing.y (distance in pixels between 2 consecutive lines of framed widgets)

    // ID stack/scopes
    // Read the FAQ for more details about how ID are handled in dear imgui. If you are creating widgets in a loop you most
    // likely want to push a unique identifier (e.g. object pointer, loop index) to uniquely differentiate them.
    // You can also use the "##foobar" syntax within widget label to distinguish them from each others.
    // In this header file we use the "label"/"name" terminology to denote a string that will be displayed and used as an ID,
    // whereas "str_id" denote a string that is only used as an ID and not aimed to be displayed.
    void          PushID(const(char)* str_id);                                    // push identifier into the ID stack. IDs are hash of the entire stack!
    void          PushID(const(char)* str_id_begin, const(char)* str_id_end);
    void          PushID(const void* ptr_id);
    void          PushID(int int_id);
    void          PopID();
    ImGuiID       GetID(const(char)* str_id);                                     // calculate unique ID (hash of whole ID stack + given parameter). e.g. if you want to query into ImGuiStorage yourself
    ImGuiID       GetID(const(char)* str_id_begin, const(char)* str_id_end);
    ImGuiID       GetID(const void* ptr_id);

    // Widgets: Text
    void          TextUnformatted(const(char)* text, const(char)* text_end = null);                // raw text without formatting. Roughly equivalent to Text("%s", text) but: A) doesn't require null terminated string if 'text_end' is specified, B) it's faster, no memory copy is done, no buffer size limits, recommended for long chunks of text.
    void          Text(const(char)* fmt, ...);                                     // IM_FMTARGS(1); // simple formatted text
    void          TextV(const(char)* fmt, va_list args);                            //IM_FMTLIST(1);
    void          TextColored(const ref ImVec4 col, const(char)* fmt, ...);            //IM_FMTARGS(2); // shortcut for PushStyleColor(ImGuiCol_Text, col); Text(fmt, ...); PopStyleColor();
    void          TextColoredV(const ref ImVec4 col, const(char)* fmt, va_list args);  //IM_FMTLIST(2);
    void          TextDisabled(const(char)* fmt, ...);                              //IM_FMTARGS(1); // shortcut for PushStyleColor(ImGuiCol_Text, style.Colors[ImGuiCol_TextDisabled]); Text(fmt, ...); PopStyleColor();
    void          TextDisabledV(const(char)* fmt, va_list args);                    //IM_FMTLIST(1);
    void          TextWrapped(const(char)* fmt, ...);                               //IM_FMTARGS(1); // shortcut for PushTextWrapPos(0.0f); Text(fmt, ...); PopTextWrapPos();. Note that this won't work on an auto-resizing window if there's no other widgets to extend the window width, yoy may need to set a size using SetNextWindowSize().
    void          TextWrappedV(const(char)* fmt, va_list args);                     //IM_FMTLIST(1);
    void          LabelText(const(char)* label, const(char)* fmt, ...);              //IM_FMTARGS(2); // display text+label aligned the same way as value+label widgets
    void          LabelTextV(const(char)* label, const(char)* fmt, va_list args);    //IM_FMTLIST(2);
    void          BulletText(const(char)* fmt, ...);                                //IM_FMTARGS(1); // shortcut for Bullet()+Text()
    void          BulletTextV(const(char)* fmt, va_list args);                      //IM_FMTLIST(1);

    // Widgets: Main
    // Most widgets return true when the value has been changed or when pressed/selected
    bool          Button(const(char)* label, const ref ImVec2 size = ImVec2(0,0).byRef );    // button
    bool          SmallButton(const(char)* label);                                 // button with FramePadding=(0,0) to easily embed within text
    bool          InvisibleButton(const(char)* str_id, const ref ImVec2 size);        // button behavior without the visuals, useful to build custom behaviors using the public api (along with IsItemActive, IsItemHovered, etc.)
    bool          ArrowButton(const(char)* str_id, ImGuiDir dir);                  // square button with an arrow shape
    void          Image(ImTextureID user_texture_id, const ref ImVec2 size, const ref ImVec2 uv0 = ImVec2(0,0).byRef, const ref ImVec2 uv1 = ImVec2(1,1).byRef, const ref ImVec4 tint_col = ImVec4(1,1,1,1).byRef, const ref ImVec4 border_col = ImVec4(0,0,0,0).byRef);
    bool          ImageButton(ImTextureID user_texture_id, const ref ImVec2 size, const ref ImVec2 uv0 = ImVec2(0,0).byRef,  const ref ImVec2 uv1 = ImVec2(1,1).byRef, int frame_padding = -1, const ref ImVec4 bg_col = ImVec4(0,0,0,0).byRef, const ref ImVec4 tint_col = ImVec4(1,1,1,1).byRef);    // <0 frame_padding uses default frame padding settings. 0 for no padding
    bool          Checkbox(const(char)* label, bool* v);
    bool          CheckboxFlags(const(char)* label, uint* flags, uint flags_value);
    bool          RadioButton(const(char)* label, bool active);
    bool          RadioButton(const(char)* label, int* v, int v_button);
    void          PlotLines(const(char)* label, const float* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0), int stride = float.sizeof);
    void          PlotLines(const(char)* label, float function(void* data, int idx), void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0));
    void          PlotHistogram(const(char)* label, const float* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0), int stride = float.sizeof);
    void          PlotHistogram(const(char)* label, float function(void* data, int idx), void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2(0,0));
    void          ProgressBar(float fraction, const ref ImVec2 size_arg = ImVec2(-1,0).byRef, const(char)* overlay = null);
    void          Bullet();                                                       // draw a small circle and keep the cursor on the same line. advance cursor x position by GetTreeNodeToLabelSpacing(), same distance that TreeNode() uses

    // Widgets: Combo Box
    // The new BeginCombo()/EndCombo() api allows you to manage your contents and selection state however you want it.
    // The old Combo() api are helpers over BeginCombo()/EndCombo() which are kept available for convenience purpose.
    bool          BeginCombo(const(char)* label, const(char)* preview_value, ImGuiComboFlags flags = 0);
    void          EndCombo(); // only call EndCombo() if BeginCombo() returns true!
    @pyExtract  pragma(mangle, gen.Combo.mangleof )
    bool          Combo(const(char)* label, int* current_item, const(const(const(char)*)*) items, int items_count, int popup_max_height_in_items = -1);
    bool          Combo(const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items = -1);      // Separate items with \0 within a string, end item-list with \0\0. e.g. "One\0Two\0Three\0"
    bool          Combo(const(char)* label, int* current_item, bool function (void* data, int idx, const(char)** out_text), void* data, int items_count, int popup_max_height_in_items = -1);

    // Widgets: Drags (tip: ctrl+click on a drag box to input with keyboard. manually input values aren't clamped, can go off-bounds)
    // For all the Float2/Float3/Float4/Int2/Int3/Int4 versions of every functions, note that a 'float v[X]' function argument is the same as 'float* v', the array syntax is just a way to document the number of elements that are expected to be accessible. You can pass address of your first element out of a contiguous set, e.g. &myvector.x
    // Adjust format string to decorate the value with a prefix, a suffix, or adapt the editing and display precision e.g. "%.3f" -> 1.234; "%5.2f secs" -> 01.23 secs; "Biscuit: %.0f" -> Biscuit: 1; etc.
    // Speed are per-pixel of mouse movement (v_speed=0.2f: mouse needs to move by 5 pixels to increase value by 1). For gamepad/keyboard navigation, minimum speed is Max(v_speed, minimum_step_at_given_precision).
    bool          DragFloat(const(char)* label, float* v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", float power = 1.0f);     // If v_min >= v_max we have no bound
    @pyExtract  pragma(mangle, gen.DragFloat2.mangleof )
    bool          DragFloat2(const(char)* label, float* /*const*/ v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", float power = 1.0f);
    @pyExtract  pragma(mangle, gen.DragFloat3.mangleof )
    bool          DragFloat3(const(char)* label, float* /*const*/ v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", float power = 1.0f);
    @pyExtract  pragma(mangle, gen.DragFloat4.mangleof )
    bool          DragFloat4(const(char)* label, float* /*const*/ v, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", float power = 1.0f);
    bool          DragFloatRange2(const(char)* label, float* v_current_min, float* v_current_max, float v_speed = 1.0f, float v_min = 0.0f, float v_max = 0.0f, const(char)* format = "%.3f", const(char)* format_max = null, float power = 1.0f);
    bool          DragInt(const(char)* label, int* v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d");                                       // If v_min >= v_max we have no bound
    @pyExtract  pragma(mangle, gen.DragInt2.mangleof )
    bool          DragInt2(const(char)* label, int* /*const*/ v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d");
    @pyExtract  pragma(mangle, gen.DragInt3.mangleof )
    bool          DragInt3(const(char)* label, int* /*const*/ v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d");
    @pyExtract  pragma(mangle, gen.DragInt4.mangleof )
    bool          DragInt4(const(char)* label, int* /*const*/ v, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d");
    bool          DragIntRange2(const(char)* label, int* v_current_min, int* v_current_max, float v_speed = 1.0f, int v_min = 0, int v_max = 0, const(char)* format = "%d", const(char)* format_max = null);
    bool          DragScalar(const(char)* label, ImGuiDataType data_type, void* v, float v_speed, const void* v_min = null, const void* v_max = null, const(char)* format = null, float power = 1.0f);
    bool          DragScalarN(const(char)* label, ImGuiDataType data_type, void* v, int components, float v_speed, const void* v_min = null, const void* v_max = null, const(char)* format = null, float power = 1.0f);

    // Widgets: Input with Keyboard
    bool          InputText(const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags = 0, ImGuiInputTextCallback callback = null, void* user_data = null);
    bool          InputTextMultiline(const(char)* label, char* buf, size_t buf_size, const ref ImVec2 size = ImVec2(0,0).byRef, ImGuiInputTextFlags flags = 0, ImGuiInputTextCallback callback = null, void* user_data = null);
    bool          InputFloat(const(char)* label, float* v, float step = 0.0f, float step_fast = 0.0f, const(char)* format = "%.3f", ImGuiInputTextFlags extra_flags = 0);
    @pyExtract  pragma(mangle, gen.InputFloat2.mangleof )
    bool          InputFloat2(const(char)* label, float* /*const*/ v, const(char)* format = "%.3f", ImGuiInputTextFlags extra_flags = 0);
    @pyExtract  pragma(mangle, gen.InputFloat3.mangleof )
    bool          InputFloat3(const(char)* label, float* /*const*/ v, const(char)* format = "%.3f", ImGuiInputTextFlags extra_flags = 0);
    @pyExtract  pragma(mangle, gen.InputFloat4.mangleof )
    bool          InputFloat4(const(char)* label, float* /*const*/ v, const(char)* format = "%.3f", ImGuiInputTextFlags extra_flags = 0);
    bool          InputInt(const(char)* label, int* v, int step = 1, int step_fast = 100, ImGuiInputTextFlags extra_flags = 0);
    @pyExtract  pragma(mangle, gen.InputInt2.mangleof )
    bool          InputInt2(const(char)* label, int* /*const*/ v, ImGuiInputTextFlags extra_flags = 0);
    @pyExtract  pragma(mangle, gen.InputInt3.mangleof )
    bool          InputInt3(const(char)* label, int* /*const*/ v, ImGuiInputTextFlags extra_flags = 0);
    @pyExtract  pragma(mangle, gen.InputInt4.mangleof )
    bool          InputInt4(const(char)* label, int* /*const*/ v, ImGuiInputTextFlags extra_flags = 0);
    bool          InputDouble(const(char)* label, double* v, double step = 0.0f, double step_fast = 0.0f, const(char)* format = "%.6f", ImGuiInputTextFlags extra_flags = 0);
    bool          InputScalar(const(char)* label, ImGuiDataType data_type, void* v, const void* step = null, const void* step_fast = null, const(char)* format = null, ImGuiInputTextFlags extra_flags = 0);
    bool          InputScalarN(const(char)* label, ImGuiDataType data_type, void* v, int components, const void* step = null, const void* step_fast = null, const(char)* format = null, ImGuiInputTextFlags extra_flags = 0);

    // Widgets: Sliders (tip: ctrl+click on a slider to input with keyboard. manually input values aren't clamped, can go off-bounds)
    // Adjust format string to decorate the value with a prefix, a suffix, or adapt the editing and display precision e.g. "%.3f" -> 1.234; "%5.2f secs" -> 01.23 secs; "Biscuit: %.0f" -> Biscuit: 1; etc.
    bool          SliderFloat(const(char)* label, float* v, float v_min, float v_max, const(char)* format = "%.3f", float power = 1.0f);     // adjust format to decorate the value with a prefix or a suffix for in-slider labels or unit display. Use power!=1.0 for power curve sliders
    @pyExtract  pragma(mangle, gen.SliderFloat2.mangleof )
    bool          SliderFloat2(const(char)* label, float* /*const*/ v, float v_min, float v_max, const(char)* format = "%.3f", float power = 1.0f);
    @pyExtract  pragma(mangle, gen.SliderFloat3.mangleof )
    bool          SliderFloat3(const(char)* label, float* /*const*/ v, float v_min, float v_max, const(char)* format = "%.3f", float power = 1.0f);
    @pyExtract  pragma(mangle, gen.SliderFloat4.mangleof )
    bool          SliderFloat4(const(char)* label, float* /*const*/ v, float v_min, float v_max, const(char)* format = "%.3f", float power = 1.0f);
    bool          SliderAngle(const(char)* label, float* v_rad, float v_degrees_min = -360.0f, float v_degrees_max = +360.0f);
    bool          SliderInt(const(char)* label, int* v, int v_min, int v_max, const(char)* format = "%d");
    @pyExtract  pragma(mangle, gen.SliderInt2.mangleof )
    bool          SliderInt2(const(char)* label, int* /*const*/ v, int v_min, int v_max, const(char)* format = "%d");
    @pyExtract  pragma(mangle, gen.SliderInt3.mangleof )
    bool          SliderInt3(const(char)* label, int* /*const*/ v, int v_min, int v_max, const(char)* format = "%d");
    @pyExtract  pragma(mangle, gen.SliderInt4.mangleof )
    bool          SliderInt4(const(char)* label, int* /*const*/ v, int v_min, int v_max, const(char)* format = "%d");
    bool          SliderScalar(const(char)* label, ImGuiDataType data_type, void* v, const void* v_min, const void* v_max, const(char)* format = null, float power = 1.0f);
    bool          SliderScalarN(const(char)* label, ImGuiDataType data_type, void* v, int components, const void* v_min, const void* v_max, const(char)* format = null, float power = 1.0f);
    bool          VSliderFloat(const(char)* label, const ref ImVec2 size, float* v, float v_min, float v_max, const(char)* format = "%.3f", float power = 1.0f);
    bool          VSliderInt(const(char)* label, const ref ImVec2 size, int* v, int v_min, int v_max, const(char)* format = "%d");
    bool          VSliderScalar(const(char)* label, const ref ImVec2 size, ImGuiDataType data_type, void* v, const void* v_min, const void* v_max, const(char)* format = null, float power = 1.0f);

    // Widgets: Color Editor/Picker (tip: the ColorEdit* functions have a little colored preview square that can be left-clicked to open a picker, and right-clicked to open an option menu.)
    // Note that a 'float v[X]' function argument is the same as 'float* v', the array syntax is just a way to document the number of elements that are expected to be accessible. You can the pass the address of a first float element out of a contiguous structure, e.g. &myvector.x
    @pyExtract  pragma(mangle, gen.ColorEdit3.mangleof )
    bool          ColorEdit3(const(char)* label, float* /*const*/ col, ImGuiColorEditFlags flags = 0);

    @pyExtract  pragma(mangle, gen.ColorEdit4.mangleof )
    bool          ColorEdit4(const(char)* label, float* /*const*/ col, ImGuiColorEditFlags flags = 0);

    @pyExtract  pragma(mangle, gen.ColorPicker3.mangleof )
    bool          ColorPicker3(const(char)* label, float* /*const*/ col, ImGuiColorEditFlags flags = 0);

    @pyExtract  pragma(mangle, gen.ColorPicker4.mangleof )
    bool          ColorPicker4(const(char)* label, float* /*const*/ col, ImGuiColorEditFlags flags = 0, const(float)* ref_col = null);
    
    @pyExtract  pragma(mangle, gen.ColorButton.mangleof )
    bool          ColorButton(const(char)* desc_id, const ref ImVec4 col, ImGuiColorEditFlags flags = 0, ImVec2 size = ImVec2(0,0));  // display a colored square/button, hover for details, return true when pressed.

    void          SetColorEditOptions(ImGuiColorEditFlags flags);                     // initialize current options (generally on application startup) if you want to select a default format, picker type, etc. User will be able to change many settings, unless you pass the _NoOptions flag to your calls.

    // Widgets: Trees
    // TreeNode functions return true when the node is open, in which case you need to also call TreePop() when you are finished displaying the tree node contents.
    bool          TreeNode(const(char)* label);
    bool          TreeNode(const(char)* str_id, const(char)* fmt, ...); //IM_FMTARGS(2);   // helper variation to completely decorelate the id from the displayed string. Read the FAQ about why and how to use ID. to align arbitrary text at the same level as a TreeNode() you can use Bullet().
    bool          TreeNode(const void* ptr_id, const(char)* fmt, ...); //IM_FMTARGS(2);   // "
    bool          TreeNodeV(const(char)* str_id, const(char)* fmt, va_list args); //IM_FMTLIST(2);
    bool          TreeNodeV(const void* ptr_id, const(char)* fmt, va_list args); //IM_FMTLIST(2);
    bool          TreeNodeEx(const(char)* label, ImGuiTreeNodeFlags flags = 0);
    bool          TreeNodeEx(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...); //IM_FMTARGS(3);
    bool          TreeNodeEx(const void* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...); //IM_FMTARGS(3);
    bool          TreeNodeExV(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args); //IM_FMTLIST(3);
    bool          TreeNodeExV(const void* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, va_list args); //IM_FMTLIST(3);
    void          TreePush(const(char)* str_id);                                       // ~ Indent()+PushId(). Already called by TreeNode() when returning true, but you can call TreePush/TreePop yourself if desired.
    void          TreePush(const void* ptr_id = null);                                // "
    void          TreePop();                                                          // ~ Unindent()+PopId()
    void          TreeAdvanceToLabelPos();                                            // advance cursor x position by GetTreeNodeToLabelSpacing()
    float         GetTreeNodeToLabelSpacing();                                        // horizontal distance preceding label when using TreeNode*() or Bullet() == (g.FontSize + style.FramePadding.x*2) for a regular unframed TreeNode
    void          SetNextTreeNodeOpen(bool is_open, ImGuiCond cond = 0);              // set next TreeNode/CollapsingHeader open state.
    bool          CollapsingHeader(const(char)* label, ImGuiTreeNodeFlags flags = 0);  // if returning 'true' the header is open. doesn't indent nor push on ID stack. user doesn't have to call TreePop().
    bool          CollapsingHeader(const(char)* label, bool* p_open, ImGuiTreeNodeFlags flags = 0); // when 'p_open' isn't NULL, display an additional small close button on upper right of the header

    // Widgets: Selectable / Lists
    bool          Selectable(const(char)* label, bool selected = false, ImGuiSelectableFlags flags = 0, const ref ImVec2 size = ImVec2(0,0).byRef);  // "bool selected" carry the selection state (read-only). Selectable() is clicked is returns true so you can modify your selection state. size.x==0.0: use remaining width, size.x>0.0: specify width. size.y==0.0: use label height, size.y>0.0: specify height
    bool          Selectable(const(char)* label, bool* p_selected, ImGuiSelectableFlags flags = 0, const ref ImVec2 size = ImVec2(0,0).byRef);       // "bool* p_selected" point to the selection state (read-write), as a convenient helper.
    bool          ListBox(const(char)* label, int* current_item, const(const(const(char)*)*) items, int items_count, int height_in_items = -1);
    bool          ListBox(const(char)* label, int* current_item, bool function(void* data, int idx, const(char)** out_text) items_getter, void* data, int items_count, int height_in_items = -1);
    bool          ListBoxHeader(const(char)* label, const ref ImVec2 size = ImVec2(0,0).byRef); // use if you want to reimplement ListBox() will custom data or interactions. if the function return true, you can output elements then call ListBoxFooter() afterwards.
    bool          ListBoxHeader(const(char)* label, int items_count, int height_in_items = -1); // "
    void          ListBoxFooter();                                                    // terminate the scrolling region. only call ListBoxFooter() if ListBoxHeader() returned true!

    // Widgets: Value() Helpers. Output single value in "name: value" format (tip: freely declare more in your code to handle your types. you can add functions to the ImGui namespace)
    void          Value(const(char)* prefix, bool b);
    void          Value(const(char)* prefix, int v);
    void          Value(const(char)* prefix, uint v);
    void          Value(const(char)* prefix, float v, const(char)* float_format = null);

    // Tooltips
    void          BeginTooltip();                                                     // begin/append a tooltip window. to create full-featured tooltip (with any kind of items).
    void          EndTooltip();
    void          SetTooltip(const(char)* fmt, ...); //IM_FMTARGS(1);                     // set a text-only tooltip, typically use with ImGui::IsItemHovered(). overidde any previous call to SetTooltip().
    void          SetTooltipV(const(char)* fmt, va_list args); //IM_FMTLIST(1);

    // Menus
    bool          BeginMainMenuBar();                                                 // create and append to a full screen menu-bar.
    void          EndMainMenuBar();                                                   // only call EndMainMenuBar() if BeginMainMenuBar() returns true!
    bool          BeginMenuBar();                                                     // append to menu-bar of current window (requires ImGuiWindowFlags_MenuBar flag set on parent window).
    void          EndMenuBar();                                                       // only call EndMenuBar() if BeginMenuBar() returns true!
    bool          BeginMenu(const(char)* label, bool enabled = true);                  // create a sub-menu entry. only call EndMenu() if this returns true!
    void          EndMenu();                                                          // only call EndMenu() if BeginMenu() returns true!
    bool          MenuItem(const(char)* label, const(char)* shortcut = null, bool selected = false, bool enabled = true);  // return true when activated. shortcuts are displayed for convenience but not processed by ImGui at the moment
    bool          MenuItem(const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled = true);              // return true when activated + toggle (*p_selected) if p_selected != NULL

    // Popups
    void          OpenPopup(const(char)* str_id);                                      // call to mark popup as open (don't call every frame!). popups are closed when user click outside, or if CloseCurrentPopup() is called within a BeginPopup()/EndPopup() block. By default, Selectable()/MenuItem() are calling CloseCurrentPopup(). Popup identifiers are relative to the current ID-stack (so OpenPopup and BeginPopup needs to be at the same level).
    bool          BeginPopup(const(char)* str_id, ImGuiWindowFlags flags = 0);                                             // return true if the popup is open, and you can start outputting to it. only call EndPopup() if BeginPopup() returns true!
    bool          BeginPopupContextItem(const(char)* str_id = null, int mouse_button = 1);                                 // helper to open and begin popup when clicked on last item. if you can pass a NULL str_id only if the previous item had an id. If you want to use that on a non-interactive item such as Text() you need to pass in an explicit ID here. read comments in .cpp!
    bool          BeginPopupContextWindow(const(char)* str_id = null, int mouse_button = 1, bool also_over_items = true);  // helper to open and begin popup when clicked on current window.
    bool          BeginPopupContextVoid(const(char)* str_id = null, int mouse_button = 1);                                 // helper to open and begin popup when clicked in void (where there are no imgui windows).
    bool          BeginPopupModal(const(char)* name, bool* p_open = null, ImGuiWindowFlags flags = 0);                     // modal dialog (regular window with title bar, block interactions behind the modal window, can't close the modal window by clicking outside)
    void          EndPopup();                                                                                             // only call EndPopup() if BeginPopupXXX() returns true!
    bool          OpenPopupOnItemClick(const(char)* str_id = null, int mouse_button = 1);                                  // helper to open popup when clicked on last item. return true when just opened.
    bool          IsPopupOpen(const(char)* str_id);                                    // return true if the popup is open
    void          CloseCurrentPopup();                                                // close the popup we have begin-ed into. clicking on a MenuItem or Selectable automatically close the current popup.

    // Columns
    // You can also use SameLine(pos_x) for simplified columns. The columns API is still work-in-progress and rather lacking.
    void          Columns(int count = 1, const(char)* id = null, bool border = true);
    void          NextColumn();                                                       // next column, defaults to current row or next row if the current row is finished
    int           GetColumnIndex();                                                   // get current column index
    float         GetColumnWidth(int column_index = -1);                              // get column width (in pixels). pass -1 to use current column
    void          SetColumnWidth(int column_index, float width);                      // set column width (in pixels). pass -1 to use current column
    float         GetColumnOffset(int column_index = -1);                             // get position of column line (in pixels, from the left side of the contents region). pass -1 to use current column, otherwise 0..GetColumnsCount() inclusive. column 0 is typically 0.0f
    void          SetColumnOffset(int column_index, float offset_x);                  // set position of column line (in pixels, from the left side of the contents region). pass -1 to use current column
    int           GetColumnsCount();

    // Logging/Capture: all text output from interface is captured to tty/file/clipboard. By default, tree nodes are automatically opened during logging.
    void          LogToTTY(int max_depth = -1);                                       // start logging to tty
    void          LogToFile(int max_depth = -1, const(char)* filename = null);        // start logging to file
    void          LogToClipboard(int max_depth = -1);                                 // start logging to OS clipboard
    void          LogFinish();                                                        // stop logging (close file, etc.)
    void          LogButtons();                                                       // helper to display buttons for logging to tty/file/clipboard
    void          LogText(const(char)* fmt, ...); //IM_FMTARGS(1);                    // pass text data straight to log (without being displayed)

    // Drag and Drop
    // [BETA API] Missing Demo code. API may evolve.
    bool          BeginDragDropSource(ImGuiDragDropFlags flags = 0);                                      // call when the current item is active. If this return true, you can call SetDragDropPayload() + EndDragDropSource()
    bool          SetDragDropPayload(const(char)* type, const void* data, size_t size, ImGuiCond cond = 0);// type is a user defined string of maximum 32 characters. Strings starting with '_' are reserved for dear imgui internal types. Data is copied and held by imgui.
    void          EndDragDropSource();                                                                    // only call EndDragDropSource() if BeginDragDropSource() returns true!
    bool          BeginDragDropTarget();                                                                  // call after submitting an item that may receive an item. If this returns true, you can call AcceptDragDropPayload() + EndDragDropTarget()
    const(ImGuiPayload)* AcceptDragDropPayload(const(char)* type, ImGuiDragDropFlags flags = 0);            // accept contents of a given type. If ImGuiDragDropFlags_AcceptBeforeDelivery is set you can peek into the payload before the mouse button is released.
    void          EndDragDropTarget();                                                                    // only call EndDragDropTarget() if BeginDragDropTarget() returns true!

    // Clipping
    void          PushClipRect(const ref ImVec2 clip_rect_min, const ref ImVec2 clip_rect_max, bool intersect_with_current_clip_rect);
    void          PopClipRect();

    // Focus, Activation
    // (Prefer using "SetItemDefaultFocus()" over "if (IsWindowAppearing()) SetScrollHere()" when applicable, to make your code more forward compatible when navigation branch is merged)
    void          SetItemDefaultFocus();                                              // make last item the default focused item of a window. Please use instead of "if (IsWindowAppearing()) SetScrollHere()" to signify "default item".
    void          SetKeyboardFocusHere(int offset = 0);                               // focus keyboard on the next widget. Use positive 'offset' to access sub components of a multiple component widget. Use -1 to access previous widget.

    // Utilities
    bool          IsItemHovered(ImGuiHoveredFlags flags = 0);                         // is the last item hovered? (and usable, aka not blocked by a popup, etc.). See ImGuiHoveredFlags for more options.
    bool          IsItemActive();                                                     // is the last item active? (e.g. button being held, text field being edited. This will continuously return true while holding mouse button on an item. Items that don't interact will always return false)
    bool          IsItemFocused();                                                    // is the last item focused for keyboard/gamepad navigation?
    bool          IsItemClicked(int mouse_button = 0);                                // is the last item clicked? (e.g. button/node just clicked on) == IsMouseClicked(mouse_button) && IsItemHovered()
    bool          IsItemVisible();                                                    // is the last item visible? (items may be out of sight because of clipping/scrolling)
    bool          IsItemDeactivated();                                                // was the last item just made inactive (item was previously active). Useful for Undo/Redo patterns with widgets that requires continuous editing.
    bool          IsItemDeactivatedAfterChange();                                     // was the last item just made inactive and made a value change when it was active? (e.g. Slider/Drag moved). Useful for Undo/Redo patterns with widgets that requires continuous editing. Note that you may get false positives (some widgets such as Combo()/ListBox()/Selectable() will return true even when clicking an already selected item).
    bool          IsAnyItemHovered();
    bool          IsAnyItemActive();
    bool          IsAnyItemFocused();
    ImVec2        GetItemRectMin();                                                   // get bounding rectangle of last item, in screen space
    ImVec2        GetItemRectMax();                                                   // "
    ImVec2        GetItemRectSize();                                                  // get size of last item, in screen space
    void          SetItemAllowOverlap();                                              // allow last item to be overlapped by a subsequent item. sometimes useful with invisible buttons, selectables, etc. to catch unused area.
    bool          IsRectVisible(const ref ImVec2 size);                                  // test if rectangle (of given size, starting from cursor position) is visible / not clipped.
    bool          IsRectVisible(const ref ImVec2 rect_min, const ref ImVec2 rect_max);      // test if rectangle (in screen space) is visible / not clipped. to perform coarse clipping on user's side.
    float         GetTime();
    int           GetFrameCount();
    ImDrawList*   GetOverlayDrawList();                                               // this draw list will be the last rendered one, useful to quickly draw overlays shapes/text
    ImDrawListSharedData* GetDrawListSharedData();                                    // you may use this when creating your own ImDrawList instances
    const(char)*  GetStyleColorName(ImGuiCol idx);
    void          SetStateStorage(ImGuiStorage* storage);                             // replace current window storage with our own (if you want to manipulate it yourself, typically clear subsection of it)
    ImGuiStorage* GetStateStorage();
    ImVec2        CalcTextSize(const(char)* text, const(char)* text_end = null, bool hide_text_after_double_hash = false, float wrap_width = -1.0f);
    void          CalcListClipping(int items_count, float items_height, int* out_items_display_start, int* out_items_display_end);    // calculate coarse clipping for large list of evenly sized items. Prefer using the ImGuiListClipper higher-level helper if you can.

    bool          BeginChildFrame(ImGuiID id, const ref ImVec2 size, ImGuiWindowFlags flags = 0); // helper to create a child window / scrolling region that looks like a normal widget frame
    void          EndChildFrame();                                                    // always call EndChildFrame() regardless of BeginChildFrame() return values (which indicates a collapsed/clipped window)

    ImVec4        ColorConvertU32ToFloat4(ImU32 in_);
    ImU32         ColorConvertFloat4ToU32(const ref ImVec4 in_);
    void          ColorConvertRGBtoHSV(float r, float g, float b, ref float out_h, ref float out_s, ref float out_v);
    void          ColorConvertHSVtoRGB(float h, float s, float v, ref float out_r, ref float out_g, ref float out_b);

    // Inputs
    int           GetKeyIndex(ImGuiKey imgui_key);                                    // map ImGuiKey_* values into user's key index. == io.KeyMap[key]
    bool          IsKeyDown(int user_key_index);                                      // is key being held. == io.KeysDown[user_key_index]. note that imgui doesn't know the semantic of each entry of io.KeysDown[]. Use your own indices/enums according to how your backend/engine stored them into io.KeysDown[]!
    bool          IsKeyPressed(int user_key_index, bool repeat = true);               // was key pressed (went from !Down to Down). if repeat=true, uses io.KeyRepeatDelay / KeyRepeatRate
    bool          IsKeyReleased(int user_key_index);                                  // was key released (went from Down to !Down)..
    int           GetKeyPressedAmount(int key_index, float repeat_delay, float rate); // uses provided repeat rate/delay. return a count, most often 0 or 1 but might be >1 if RepeatRate is small enough that DeltaTime > RepeatRate
    bool          IsMouseDown(int button);                                            // is mouse button held
    bool          IsAnyMouseDown();                                                   // is any mouse button held
    bool          IsMouseClicked(int button, bool repeat = false);                    // did mouse button clicked (went from !Down to Down)
    bool          IsMouseDoubleClicked(int button);                                   // did mouse button double-clicked. a double-click returns false in IsMouseClicked(). uses io.MouseDoubleClickTime.
    bool          IsMouseReleased(int button);                                        // did mouse button released (went from Down to !Down)
    bool          IsMouseDragging(int button = 0, float lock_threshold = -1.0f);      // is mouse dragging. if lock_threshold < -1.0f uses io.MouseDraggingThreshold
    bool          IsMouseHoveringRect(const ref ImVec2 r_min, const ref ImVec2 r_max, bool clip = true);  // is mouse hovering given bounding rect (in screen space). clipped by current clipping settings. disregarding of consideration of focus/window ordering/blocked by a popup.
    bool          IsMousePosValid(const ImVec2* mouse_pos = null);                    //
    ImVec2        GetMousePos();                                                      // shortcut to ImGui::GetIO().MousePos provided by user, to be consistent with other calls
    ImVec2        GetMousePosOnOpeningCurrentPopup();                                 // retrieve backup of mouse position at the time of opening popup we have BeginPopup() into
    ImVec2        GetMouseDragDelta(int button = 0, float lock_threshold = -1.0f);    // dragging amount since clicking. if lock_threshold < -1.0f uses io.MouseDraggingThreshold
    void          ResetMouseDragDelta(int button = 0);                                //
    ImGuiMouseCursor GetMouseCursor();                                                // get desired cursor type, reset in ImGui::NewFrame(), this is updated during the frame. valid before Render(). If you use software rendering by setting io.MouseDrawCursor ImGui will render those for you
    void          SetMouseCursor(ImGuiMouseCursor type);                              // set desired cursor type
    void          CaptureKeyboardFromApp(bool capture = true);                        // manually override io.WantCaptureKeyboard flag next frame (said flag is entirely left for your application to handle). e.g. force capture keyboard when your widget is being hovered.
    void          CaptureMouseFromApp(bool capture = true);                           // manually override io.WantCaptureMouse flag next frame (said flag is entirely left for your application to handle).

    // Clipboard Utilities (also see the LogToClipboard() function to capture or output text data to the clipboard)
    const(char)*   GetClipboardText();
    void          SetClipboardText(const(char)* text);

    // Settings/.Ini Utilities
    // The disk functions are automatically called if io.IniFilename != NULL (default is "imgui.ini").
    // Set io.IniFilename to NULL to load/save manually. Read io.WantSaveIniSettings description about handling .ini saving manually.
    void          LoadIniSettingsFromDisk(const(char)* ini_filename);                  // call after CreateContext() and before the first call to NewFrame(). NewFrame() automatically calls LoadIniSettingsFromDisk(io.IniFilename).
    void          LoadIniSettingsFromMemory(const(char)* ini_data, size_t ini_size=0); // call after CreateContext() and before the first call to NewFrame() to provide .ini data from your own data source.
    void          SaveIniSettingsToDisk(const(char)* ini_filename);
    const(char)*   SaveIniSettingsToMemory(size_t* out_ini_size = null);               // return a zero-terminated string with the .ini data which you can save by your own mean. call when io.WantSaveIniSettings is set, then save data by your own mean and clear io.WantSaveIniSettings.

    // Memory Utilities
    // All those functions are not reliant on the current context.
    // If you reload the contents of imgui.cpp at runtime, you may need to call SetCurrentContext() + SetAllocatorFunctions() again.
    void          SetAllocatorFunctions(void* function(size_t sz, void* user_data) alloc_func, void function(void* ptr, void* user_data) free_func, void* user_data = null);
    void*         MemAlloc(size_t size);
    void          MemFree(void* ptr);
    
}// namespace ImGui
