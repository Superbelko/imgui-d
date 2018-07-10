module imgui_base;

public import core.stdc.float_ : FLT_MAX;
import core.stdc.string;
import core.stdc.stdarg;
import core.stdc.stdlib;

static import imgui_ns;

// https://p0nce.github.io/d-idioms/#Rvalue-references:-Understanding-auto-ref-and-then-not-using-it
mixin template RvalueRef()
{
    alias T = typeof(this); // typeof(this) get us the type we're in
    static assert (is(T == struct));

    @nogc @safe
    ref const(T) byRef() const pure nothrow return
    {
        return this;
    }
}


immutable char* IMGUI_VERSION = "1.62";
bool IMGUI_CHECKVERSION() { return imgui_ns.DebugCheckVersionAndDataLayout(IMGUI_VERSION, ImGuiIO.sizeof, ImGuiStyle.sizeof, ImVec2.sizeof, ImVec4.sizeof, ImDrawVert.sizeof); }

extern(C++):

alias ushort ImDrawIdx;
alias void* ImTextureID;

alias ImGuiID = uint;             // Unique ID used by widgets (typically hashed from a stack of string)
// note: it has to be ushort to match C++ signature
alias ImWchar = ushort;            // Character for keyboard input/display
alias int ImGuiCol;               // enum: a color identifier for styling     // enum ImGuiCol_
alias int ImGuiDataType;          // enum: a primary data type                // enum ImGuiDataType_
alias int ImGuiDir;               // enum: a cardinal direction               // enum ImGuiDir_
alias int ImGuiCond;              // enum: a condition for Set*()             // enum ImGuiCond_
alias int ImGuiKey;               // enum: a key identifier (ImGui-side enum) // enum ImGuiKey_
alias int ImGuiNavInput;          // enum: an input identifier for navigation // enum ImGuiNavInput_
alias int ImGuiMouseCursor;       // enum: a mouse cursor identifier          // enum ImGuiMouseCursor_
alias int ImGuiStyleVar;          // enum: a variable identifier for styling  // enum ImGuiStyleVar_
alias int ImDrawCornerFlags;      // flags: for ImDrawList::AddRect*() etc.   // enum ImDrawCornerFlags_
alias int ImDrawListFlags;        // flags: for ImDrawList                    // enum ImDrawListFlags_
alias int ImFontAtlasFlags;       // flags: for ImFontAtlas                   // enum ImFontAtlasFlags_
alias int ImGuiBackendFlags;      // flags: for io.BackendFlags               // enum ImGuiBackendFlags_
alias int ImGuiColorEditFlags;    // flags: for ColorEdit*(), ColorPicker*()  // enum ImGuiColorEditFlags_
alias int ImGuiColumnsFlags;      // flags: for *Columns*()                   // enum ImGuiColumnsFlags_
alias int ImGuiConfigFlags;       // flags: for io.ConfigFlags                // enum ImGuiConfigFlags_
alias int ImGuiComboFlags;        // flags: for BeginCombo()                  // enum ImGuiComboFlags_
alias int ImGuiDragDropFlags;     // flags: for *DragDrop*()                  // enum ImGuiDragDropFlags_
alias int ImGuiFocusedFlags;      // flags: for IsWindowFocused()             // enum ImGuiFocusedFlags_
alias int ImGuiHoveredFlags;      // flags: for IsItemHovered() etc.          // enum ImGuiHoveredFlags_
alias int ImGuiInputTextFlags;    // flags: for InputText*()                  // enum ImGuiInputTextFlags_
alias int ImGuiSelectableFlags;   // flags: for Selectable()                  // enum ImGuiSelectableFlags_
alias int ImGuiTreeNodeFlags;     // flags: for TreeNode*(),CollapsingHeader()// enum ImGuiTreeNodeFlags_
alias int ImGuiWindowFlags;       // flags: for Begin*()                      // enum ImGuiWindowFlags_
alias ImGuiTextEditCallback = extern(C++) int function(ImGuiTextEditCallbackData *data);
alias ImGuiSizeCallback = extern(C++) void function(ImGuiSizeCallbackData* data);

// Scalar data types
alias ImU32 = uint;
alias ImS32 = int;
alias ImU64 = ulong;
alias ImS64 = long;

struct ImGuiContext {}
struct ImDrawListSharedData {}

// 2D vector (often used to store positions, sizes, etc.)
struct ImVec2
{
    float     x = 0f, y = 0f;

    extern(D):
    alias arr this;
    @property float[] arr() { return (&x)[0..2]; }

    mixin RvalueRef;
}

// 4D vector (often used to store floating-point colors)
struct ImVec4
{
    float     x = 0f, y = 0f, z = 0f, w = 0f;

    extern(D):
    alias arr this;
    @property float[] arr() { return (&x)[0..4]; }

    mixin RvalueRef;
}

// Dear ImGui end-user API
// (In a namespace so you can add extra functions in your own separate file. Please don't modify imgui.cpp/.h!)
//namespace ImGui 
//{
//    
//} // namespace ImGui

// Flags for ImGui::Begin()
enum //ImGuiWindowFlags_
{
    ImGuiWindowFlags_None                   = 0,
    ImGuiWindowFlags_NoTitleBar             = 1 << 0,   // Disable title-bar
    ImGuiWindowFlags_NoResize               = 1 << 1,   // Disable user resizing with the lower-right grip
    ImGuiWindowFlags_NoMove                 = 1 << 2,   // Disable user moving the window
    ImGuiWindowFlags_NoScrollbar            = 1 << 3,   // Disable scrollbars (window can still scroll with mouse or programatically)
    ImGuiWindowFlags_NoScrollWithMouse      = 1 << 4,   // Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
    ImGuiWindowFlags_NoCollapse             = 1 << 5,   // Disable user collapsing window by double-clicking on it
    ImGuiWindowFlags_AlwaysAutoResize       = 1 << 6,   // Resize every window to its content every frame
    //ImGuiWindowFlags_ShowBorders          = 1 << 7,   // Show borders around windows and items (OBSOLETE! Use e.g. style.FrameBorderSize=1.0f to enable borders).
    ImGuiWindowFlags_NoSavedSettings        = 1 << 8,   // Never load/save settings in .ini file
    ImGuiWindowFlags_NoInputs               = 1 << 9,   // Disable catching mouse or keyboard inputs, hovering test with pass through.
    ImGuiWindowFlags_MenuBar                = 1 << 10,  // Has a menu-bar
    ImGuiWindowFlags_HorizontalScrollbar    = 1 << 11,  // Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
    ImGuiWindowFlags_NoFocusOnAppearing     = 1 << 12,  // Disable taking focus when transitioning from hidden to visible state
    ImGuiWindowFlags_NoBringToFrontOnFocus  = 1 << 13,  // Disable bringing window to front when taking focus (e.g. clicking on it or programatically giving it focus)
    ImGuiWindowFlags_AlwaysVerticalScrollbar= 1 << 14,  // Always show vertical scrollbar (even if ContentSize.y < Size.y)
    ImGuiWindowFlags_AlwaysHorizontalScrollbar=1<< 15,  // Always show horizontal scrollbar (even if ContentSize.x < Size.x)
    ImGuiWindowFlags_AlwaysUseWindowPadding = 1 << 16,  // Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
    ImGuiWindowFlags_ResizeFromAnySide      = 1 << 17,  // [BETA] Enable resize from any corners and borders. Your back-end needs to honor the different values of io.MouseCursor set by imgui.
    ImGuiWindowFlags_NoNavInputs            = 1 << 18,  // No gamepad/keyboard navigation within the window
    ImGuiWindowFlags_NoNavFocus             = 1 << 19,  // No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
    ImGuiWindowFlags_NoNav                  = ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,

    // [Internal]
    ImGuiWindowFlags_NavFlattened           = 1 << 23,  // [BETA] Allow gamepad/keyboard navigation to cross over parent border to this child (only use on child that have no scrolling!)
    ImGuiWindowFlags_ChildWindow            = 1 << 24,  // Don't use! For internal use by BeginChild()
    ImGuiWindowFlags_Tooltip                = 1 << 25,  // Don't use! For internal use by BeginTooltip()
    ImGuiWindowFlags_Popup                  = 1 << 26,  // Don't use! For internal use by BeginPopup()
    ImGuiWindowFlags_Modal                  = 1 << 27,  // Don't use! For internal use by BeginPopupModal()
    ImGuiWindowFlags_ChildMenu              = 1 << 28   // Don't use! For internal use by BeginMenu()
}

// Flags for ImGui::InputText()
enum //ImGuiInputTextFlags_
{
    ImGuiInputTextFlags_None                = 0,
    ImGuiInputTextFlags_CharsDecimal        = 1 << 0,   // Allow 0123456789.+-*/
    ImGuiInputTextFlags_CharsHexadecimal    = 1 << 1,   // Allow 0123456789ABCDEFabcdef
    ImGuiInputTextFlags_CharsUppercase      = 1 << 2,   // Turn a..z into A..Z
    ImGuiInputTextFlags_CharsNoBlank        = 1 << 3,   // Filter out spaces, tabs
    ImGuiInputTextFlags_AutoSelectAll       = 1 << 4,   // Select entire text when first taking mouse focus
    ImGuiInputTextFlags_EnterReturnsTrue    = 1 << 5,   // Return 'true' when Enter is pressed (as opposed to when the value was modified)
    ImGuiInputTextFlags_CallbackCompletion  = 1 << 6,   // Call user function on pressing TAB (for completion handling)
    ImGuiInputTextFlags_CallbackHistory     = 1 << 7,   // Call user function on pressing Up/Down arrows (for history handling)
    ImGuiInputTextFlags_CallbackAlways      = 1 << 8,   // Call user function every time. User code may query cursor position, modify text buffer.
    ImGuiInputTextFlags_CallbackCharFilter  = 1 << 9,   // Call user function to filter character. Modify data->EventChar to replace/filter input, or return 1 to discard character.
    ImGuiInputTextFlags_AllowTabInput       = 1 << 10,  // Pressing TAB input a '\t' character into the text field
    ImGuiInputTextFlags_CtrlEnterForNewLine = 1 << 11,  // In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter).
    ImGuiInputTextFlags_NoHorizontalScroll  = 1 << 12,  // Disable following the cursor horizontally
    ImGuiInputTextFlags_AlwaysInsertMode    = 1 << 13,  // Insert mode
    ImGuiInputTextFlags_ReadOnly            = 1 << 14,  // Read-only mode
    ImGuiInputTextFlags_Password            = 1 << 15,  // Password mode, display all characters as '*'
    ImGuiInputTextFlags_NoUndoRedo          = 1 << 16,  // Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().
    ImGuiInputTextFlags_CharsScientific     = 1 << 17,  // Allow 0123456789.+-*/eE (Scientific notation input)
    // [Internal]
    ImGuiInputTextFlags_Multiline           = 1 << 20   // For internal use by InputTextMultiline()
}

// Flags for ImGui::TreeNodeEx(), ImGui::CollapsingHeader*()
enum //ImGuiTreeNodeFlags_
{
    ImGuiTreeNodeFlags_None                 = 0,
    ImGuiTreeNodeFlags_Selected             = 1 << 0,   // Draw as selected
    ImGuiTreeNodeFlags_Framed               = 1 << 1,   // Full colored frame (e.g. for CollapsingHeader)
    ImGuiTreeNodeFlags_AllowItemOverlap     = 1 << 2,   // Hit testing to allow subsequent widgets to overlap this one
    ImGuiTreeNodeFlags_NoTreePushOnOpen     = 1 << 3,   // Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack
    ImGuiTreeNodeFlags_NoAutoOpenOnLog      = 1 << 4,   // Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
    ImGuiTreeNodeFlags_DefaultOpen          = 1 << 5,   // Default node to be open
    ImGuiTreeNodeFlags_OpenOnDoubleClick    = 1 << 6,   // Need double-click to open node
    ImGuiTreeNodeFlags_OpenOnArrow          = 1 << 7,   // Only open when clicking on the arrow part. If ImGuiTreeNodeFlags_OpenOnDoubleClick is also set, single-click arrow or double-click all box to open.
    ImGuiTreeNodeFlags_Leaf                 = 1 << 8,   // No collapsing, no arrow (use as a convenience for leaf nodes).
    ImGuiTreeNodeFlags_Bullet               = 1 << 9,   // Display a bullet instead of arrow
    ImGuiTreeNodeFlags_FramePadding         = 1 << 10,  // Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding().
    //ImGuITreeNodeFlags_SpanAllAvailWidth  = 1 << 11,  // FIXME: TODO: Extend hit box horizontally even if not framed
    //ImGuiTreeNodeFlags_NoScrollOnOpen     = 1 << 12,  // FIXME: TODO: Disable automatic scroll on TreePop() if node got just open and contents is not visible
    ImGuiTreeNodeFlags_NavLeftJumpsBackHere = 1 << 13,  // (WIP) Nav: left direction may move to this TreeNode() from any of its child (items submitted between TreeNode and TreePop)
    ImGuiTreeNodeFlags_CollapsingHeader     = ImGuiTreeNodeFlags_Framed | ImGuiTreeNodeFlags_NoTreePushOnOpen | ImGuiTreeNodeFlags_NoAutoOpenOnLog

    // Obsolete names (will be removed)
    //#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS
    //    , ImGuiTreeNodeFlags_AllowOverlapMode = ImGuiTreeNodeFlags_AllowItemOverlap
    //#endif
}

// Flags for ImGui::Selectable()
enum //ImGuiSelectableFlags_
{
    ImGuiSelectableFlags_None               = 0,
    ImGuiSelectableFlags_DontClosePopups    = 1 << 0,   // Clicking this don't close parent popup window
    ImGuiSelectableFlags_SpanAllColumns     = 1 << 1,   // Selectable frame can span all columns (text will still fit in current column)
    ImGuiSelectableFlags_AllowDoubleClick   = 1 << 2    // Generate press events on double clicks too
}

// Flags for ImGui::BeginCombo()
enum //ImGuiComboFlags_
{
    ImGuiComboFlags_None                    = 0,
    ImGuiComboFlags_PopupAlignLeft          = 1 << 0,   // Align the popup toward the left by default
    ImGuiComboFlags_HeightSmall             = 1 << 1,   // Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()
    ImGuiComboFlags_HeightRegular           = 1 << 2,   // Max ~8 items visible (default)
    ImGuiComboFlags_HeightLarge             = 1 << 3,   // Max ~20 items visible
    ImGuiComboFlags_HeightLargest           = 1 << 4,   // As many fitting items as possible
    ImGuiComboFlags_NoArrowButton           = 1 << 5,   // Display on the preview box without the square arrow button
    ImGuiComboFlags_NoPreview               = 1 << 6,   // Display only a square arrow button
    ImGuiComboFlags_HeightMask_             = ImGuiComboFlags_HeightSmall | ImGuiComboFlags_HeightRegular | ImGuiComboFlags_HeightLarge | ImGuiComboFlags_HeightLargest
}

// Flags for ImGui::IsWindowFocused()
enum //ImGuiFocusedFlags_
{
    ImGuiFocusedFlags_None                          = 0,
    ImGuiFocusedFlags_ChildWindows                  = 1 << 0,   // IsWindowFocused(): Return true if any children of the window is focused
    ImGuiFocusedFlags_RootWindow                    = 1 << 1,   // IsWindowFocused(): Test from root window (top most parent of the current hierarchy)
    ImGuiFocusedFlags_AnyWindow                     = 1 << 2,   // IsWindowFocused(): Return true if any window is focused
    ImGuiFocusedFlags_RootAndChildWindows           = ImGuiFocusedFlags_RootWindow | ImGuiFocusedFlags_ChildWindows
}

// Flags for ImGui::IsItemHovered(), ImGui::IsWindowHovered()
// Note: If you are trying to check whether your mouse should be dispatched to imgui or to your app, you should use the 'io.WantCaptureMouse' boolean for that. Please read the FAQ!
enum //ImGuiHoveredFlags_
{
    ImGuiHoveredFlags_None                          = 0,        // Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
    ImGuiHoveredFlags_ChildWindows                  = 1 << 0,   // IsWindowHovered() only: Return true if any children of the window is hovered
    ImGuiHoveredFlags_RootWindow                    = 1 << 1,   // IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)
    ImGuiHoveredFlags_AnyWindow                     = 1 << 2,   // IsWindowHovered() only: Return true if any window is hovered
    ImGuiHoveredFlags_AllowWhenBlockedByPopup       = 1 << 3,   // Return true even if a popup window is normally blocking access to this item/window
    //ImGuiHoveredFlags_AllowWhenBlockedByModal     = 1 << 4,   // Return true even if a modal popup window is normally blocking access to this item/window. FIXME-TODO: Unavailable yet.
    ImGuiHoveredFlags_AllowWhenBlockedByActiveItem  = 1 << 5,   // Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.
    ImGuiHoveredFlags_AllowWhenOverlapped           = 1 << 6,   // Return true even if the position is overlapped by another window
    ImGuiHoveredFlags_RectOnly                      = ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_AllowWhenOverlapped,
    ImGuiHoveredFlags_RootAndChildWindows           = ImGuiHoveredFlags_RootWindow | ImGuiHoveredFlags_ChildWindows
}

// Flags for ImGui::BeginDragDropSource(), ImGui::AcceptDragDropPayload()
enum //ImGuiDragDropFlags_
{
    ImGuiDragDropFlags_None                         = 0,
    // BeginDragDropSource() flags
    ImGuiDragDropFlags_SourceNoPreviewTooltip       = 1 << 0,   // By default, a successful call to BeginDragDropSource opens a tooltip so you can display a preview or description of the source contents. This flag disable this behavior.
    ImGuiDragDropFlags_SourceNoDisableHover         = 1 << 1,   // By default, when dragging we clear data so that IsItemHovered() will return true, to avoid subsequent user code submitting tooltips. This flag disable this behavior so you can still call IsItemHovered() on the source item.
    ImGuiDragDropFlags_SourceNoHoldToOpenOthers     = 1 << 2,   // Disable the behavior that allows to open tree nodes and collapsing header by holding over them while dragging a source item.
    ImGuiDragDropFlags_SourceAllowNullID            = 1 << 3,   // Allow items such as Text(), Image() that have no unique identifier to be used as drag source, by manufacturing a temporary identifier based on their window-relative position. This is extremely unusual within the dear imgui ecosystem and so we made it explicit.
    ImGuiDragDropFlags_SourceExtern                 = 1 << 4,   // External source (from outside of imgui), won't attempt to read current item/window info. Will always return true. Only one Extern source can be active simultaneously.
    // AcceptDragDropPayload() flags
    ImGuiDragDropFlags_AcceptBeforeDelivery         = 1 << 10,  // AcceptDragDropPayload() will returns true even before the mouse button is released. You can then call IsDelivery() to test if the payload needs to be delivered.
    ImGuiDragDropFlags_AcceptNoDrawDefaultRect      = 1 << 11,  // Do not draw the default highlight rectangle when hovering over target.
    ImGuiDragDropFlags_AcceptNoPreviewTooltip       = 1 << 12,  // Request hiding the BeginDragDropSource tooltip from the BeginDragDropTarget site.
    ImGuiDragDropFlags_AcceptPeekOnly               = ImGuiDragDropFlags_AcceptBeforeDelivery | ImGuiDragDropFlags_AcceptNoDrawDefaultRect  // For peeking ahead and inspecting the payload before delivery.
}

// Standard Drag and Drop payload types. You can define you own payload types using short strings. Types starting with '_' are defined by Dear ImGui.
enum IMGUI_PAYLOAD_TYPE_COLOR_3F =     "_COL3F";    // float[3]: Standard type for colors, without alpha. User code may use this type.
enum IMGUI_PAYLOAD_TYPE_COLOR_4F =     "_COL4F";    // float[4]: Standard type for colors. User code may use this type.

// A primary data type
enum //ImGuiDataType_
{
    ImGuiDataType_S32,      // int
    ImGuiDataType_U32,      // unsigned int
    ImGuiDataType_S64,      // long long, __int64
    ImGuiDataType_U64,      // unsigned long long, unsigned __int64
    ImGuiDataType_Float,    // float
    ImGuiDataType_Double,   // double
    ImGuiDataType_COUNT
}

// A cardinal direction
enum //ImGuiDir_
{
    ImGuiDir_None    = -1,
    ImGuiDir_Left    = 0,
    ImGuiDir_Right   = 1,
    ImGuiDir_Up      = 2,
    ImGuiDir_Down    = 3,
    ImGuiDir_COUNT
}

// User fill ImGuiIO.KeyMap[] array with indices into the ImGuiIO.KeysDown[512] array
enum //ImGuiKey_
{
    ImGuiKey_Tab,
    ImGuiKey_LeftArrow,
    ImGuiKey_RightArrow,
    ImGuiKey_UpArrow,
    ImGuiKey_DownArrow,
    ImGuiKey_PageUp,
    ImGuiKey_PageDown,
    ImGuiKey_Home,
    ImGuiKey_End,
    ImGuiKey_Insert,
    ImGuiKey_Delete,
    ImGuiKey_Backspace,
    ImGuiKey_Space,
    ImGuiKey_Enter,
    ImGuiKey_Escape,
    ImGuiKey_A,         // for text edit CTRL+A: select all
    ImGuiKey_C,         // for text edit CTRL+C: copy
    ImGuiKey_V,         // for text edit CTRL+V: paste
    ImGuiKey_X,         // for text edit CTRL+X: cut
    ImGuiKey_Y,         // for text edit CTRL+Y: redo
    ImGuiKey_Z,         // for text edit CTRL+Z: undo
    ImGuiKey_COUNT
}


// [BETA] Gamepad/Keyboard directional navigation
// Keyboard: Set io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard to enable. NewFrame() will automatically fill io.NavInputs[] based on your io.KeysDown[] + io.KeyMap[] arrays.
// Gamepad:  Set io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad to enable. Back-end: set ImGuiBackendFlags_HasGamepad and fill the io.NavInputs[] fields before calling NewFrame(). Note that io.NavInputs[] is cleared by EndFrame().
// Read instructions in imgui.cpp for more details. Download PNG/PSD at goo.gl/9LgVZW.
enum //ImGuiNavInput_
{
    // Gamepad Mapping
    ImGuiNavInput_Activate,      // activate / open / toggle / tweak value       // e.g. Cross  (PS4), A (Xbox), A (Switch), Space (Keyboard)
    ImGuiNavInput_Cancel,        // cancel / close / exit                        // e.g. Circle (PS4), B (Xbox), B (Switch), Escape (Keyboard)
    ImGuiNavInput_Input,         // text input / on-screen keyboard              // e.g. Triang.(PS4), Y (Xbox), X (Switch), Return (Keyboard)
    ImGuiNavInput_Menu,          // tap: toggle menu / hold: focus, move, resize // e.g. Square (PS4), X (Xbox), Y (Switch), Alt (Keyboard)
    ImGuiNavInput_DpadLeft,      // move / tweak / resize window (w/ PadMenu)    // e.g. D-pad Left/Right/Up/Down (Gamepads), Arrow keys (Keyboard)
    ImGuiNavInput_DpadRight,     //
    ImGuiNavInput_DpadUp,        //
    ImGuiNavInput_DpadDown,      //
    ImGuiNavInput_LStickLeft,    // scroll / move window (w/ PadMenu)            // e.g. Left Analog Stick Left/Right/Up/Down
    ImGuiNavInput_LStickRight,   //
    ImGuiNavInput_LStickUp,      //
    ImGuiNavInput_LStickDown,    //
    ImGuiNavInput_FocusPrev,     // next window (w/ PadMenu)                     // e.g. L1 or L2 (PS4), LB or LT (Xbox), L or ZL (Switch)
    ImGuiNavInput_FocusNext,     // prev window (w/ PadMenu)                     // e.g. R1 or R2 (PS4), RB or RT (Xbox), R or ZL (Switch)
    ImGuiNavInput_TweakSlow,     // slower tweaks                                // e.g. L1 or L2 (PS4), LB or LT (Xbox), L or ZL (Switch)
    ImGuiNavInput_TweakFast,     // faster tweaks                                // e.g. R1 or R2 (PS4), RB or RT (Xbox), R or ZL (Switch)

    // [Internal] Don't use directly! This is used internally to differentiate keyboard from gamepad inputs for behaviors that require to differentiate them.
    // Keyboard behavior that have no corresponding gamepad mapping (e.g. CTRL+TAB) will be directly reading from io.KeysDown[] instead of io.NavInputs[].
    ImGuiNavInput_KeyMenu_,      // toggle menu                                  // = io.KeyAlt
    ImGuiNavInput_KeyLeft_,      // move left                                    // = Arrow keys
    ImGuiNavInput_KeyRight_,     // move right
    ImGuiNavInput_KeyUp_,        // move up
    ImGuiNavInput_KeyDown_,      // move down
    ImGuiNavInput_COUNT,
    ImGuiNavInput_InternalStart_ = ImGuiNavInput_KeyMenu_
}

// Configuration flags stored in io.ConfigFlags. Set by user/application.
enum //ImGuiConfigFlags_
{
    ImGuiConfigFlags_NavEnableKeyboard      = 1 << 0,   // Master keyboard navigation enable flag. NewFrame() will automatically fill io.NavInputs[] based on io.KeysDown[].
    ImGuiConfigFlags_NavEnableGamepad       = 1 << 1,   // Master gamepad navigation enable flag. This is mostly to instruct your imgui back-end to fill io.NavInputs[]. Back-end also needs to set ImGuiBackendFlags_HasGamepad.
    ImGuiConfigFlags_NavEnableSetMousePos   = 1 << 2,   // Instruct navigation to move the mouse cursor. May be useful on TV/console systems where moving a virtual mouse is awkward. Will update io.MousePos and set io.WantSetMousePos=true. If enabled you MUST honor io.WantSetMousePos requests in your binding, otherwise ImGui will react as if the mouse is jumping around back and forth.
    ImGuiConfigFlags_NavNoCaptureKeyboard   = 1 << 3,   // Instruct navigation to not set the io.WantCaptureKeyboard flag when io.NavActive is set.
    ImGuiConfigFlags_NoMouse                = 1 << 4,   // Instruct imgui to clear mouse position/buttons in NewFrame(). This allows ignoring the mouse information set by the back-end.
    ImGuiConfigFlags_NoMouseCursorChange    = 1 << 5,   // Instruct back-end to not alter mouse cursor shape and visibility. Use if the back-end cursor changes are interfering with yours and you don't want to use SetMouseCursor() to change mouse cursor. You may want to honor requests from imgui by reading GetMouseCursor() yourself instead.

    // User storage (to allow your back-end/engine to communicate to code that may be shared between multiple projects. Those flags are not used by core ImGui)
    ImGuiConfigFlags_IsSRGB                 = 1 << 20,  // Application is SRGB-aware.
    ImGuiConfigFlags_IsTouchScreen          = 1 << 21   // Application is using a touch screen instead of a mouse.
}

// Back-end capabilities flags stored in io.BackendFlags. Set by imgui_impl_xxx or custom back-end.
enum //ImGuiBackendFlags_
{
    ImGuiBackendFlags_HasGamepad            = 1 << 0,   // Back-end supports gamepad and currently has one connected.
    ImGuiBackendFlags_HasMouseCursors       = 1 << 1,   // Back-end supports honoring GetMouseCursor() value to change the OS cursor shape.
    ImGuiBackendFlags_HasSetMousePos        = 1 << 2    // Back-end supports io.WantSetMousePos requests to reposition the OS mouse position (only used if ImGuiConfigFlags_NavEnableSetMousePos is set).
}

// Enumeration for PushStyleColor() / PopStyleColor()
enum //ImGuiCol_
{
    ImGuiCol_Text,
    ImGuiCol_TextDisabled,
    ImGuiCol_WindowBg,              // Background of normal windows
    ImGuiCol_ChildBg,               // Background of child windows
    ImGuiCol_PopupBg,               // Background of popups, menus, tooltips windows
    ImGuiCol_Border,
    ImGuiCol_BorderShadow,
    ImGuiCol_FrameBg,               // Background of checkbox, radio button, plot, slider, text input
    ImGuiCol_FrameBgHovered,
    ImGuiCol_FrameBgActive,
    ImGuiCol_TitleBg,
    ImGuiCol_TitleBgActive,
    ImGuiCol_TitleBgCollapsed,
    ImGuiCol_MenuBarBg,
    ImGuiCol_ScrollbarBg,
    ImGuiCol_ScrollbarGrab,
    ImGuiCol_ScrollbarGrabHovered,
    ImGuiCol_ScrollbarGrabActive,
    ImGuiCol_CheckMark,
    ImGuiCol_SliderGrab,
    ImGuiCol_SliderGrabActive,
    ImGuiCol_Button,
    ImGuiCol_ButtonHovered,
    ImGuiCol_ButtonActive,
    ImGuiCol_Header,
    ImGuiCol_HeaderHovered,
    ImGuiCol_HeaderActive,
    ImGuiCol_Separator,
    ImGuiCol_SeparatorHovered,
    ImGuiCol_SeparatorActive,
    ImGuiCol_ResizeGrip,
    ImGuiCol_ResizeGripHovered,
    ImGuiCol_ResizeGripActive,
    ImGuiCol_PlotLines,
    ImGuiCol_PlotLinesHovered,
    ImGuiCol_PlotHistogram,
    ImGuiCol_PlotHistogramHovered,
    ImGuiCol_TextSelectedBg,
    ImGuiCol_ModalWindowDarkening,  // Darken/colorize entire screen behind a modal window, when one is active
    ImGuiCol_DragDropTarget,
    ImGuiCol_NavHighlight,          // Gamepad/keyboard: current highlighted item
    ImGuiCol_NavWindowingHighlight, // Gamepad/keyboard: when holding NavMenu to focus/move/resize windows
    ImGuiCol_COUNT

    // Obsolete names (will be removed)
    //#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS
    //, ImGuiCol_ChildWindowBg = ImGuiCol_ChildBg, ImGuiCol_Column = ImGuiCol_Separator, ImGuiCol_ColumnHovered = ImGuiCol_SeparatorHovered, ImGuiCol_ColumnActive = ImGuiCol_SeparatorActive
    //ImGuiCol_CloseButton, ImGuiCol_CloseButtonActive, ImGuiCol_CloseButtonHovered, // [unused since 1.60+] the close button now uses regular button colors.
    //ImGuiCol_ComboBg,                                                              // [unused since 1.53+] ComboBg has been merged with PopupBg, so a redirect isn't accurate.
    //#endif
}

// Enumeration for PushStyleVar() / PopStyleVar() to temporarily modify the ImGuiStyle structure.
// NB: the enum only refers to fields of ImGuiStyle which makes sense to be pushed/popped inside UI code. During initialization, feel free to just poke into ImGuiStyle directly.
// NB: if changing this enum, you need to update the associated internal table GStyleVarInfo[] accordingly. This is where we link enum values to members offset/type.
enum //ImGuiStyleVar_
{
    // Enum name ......................// Member in ImGuiStyle structure (see ImGuiStyle for descriptions)
    ImGuiStyleVar_Alpha,               // float     Alpha
    ImGuiStyleVar_WindowPadding,       // ImVec2    WindowPadding
    ImGuiStyleVar_WindowRounding,      // float     WindowRounding
    ImGuiStyleVar_WindowBorderSize,    // float     WindowBorderSize
    ImGuiStyleVar_WindowMinSize,       // ImVec2    WindowMinSize
    ImGuiStyleVar_WindowTitleAlign,    // ImVec2    WindowTitleAlign
    ImGuiStyleVar_ChildRounding,       // float     ChildRounding
    ImGuiStyleVar_ChildBorderSize,     // float     ChildBorderSize
    ImGuiStyleVar_PopupRounding,       // float     PopupRounding
    ImGuiStyleVar_PopupBorderSize,     // float     PopupBorderSize
    ImGuiStyleVar_FramePadding,        // ImVec2    FramePadding
    ImGuiStyleVar_FrameRounding,       // float     FrameRounding
    ImGuiStyleVar_FrameBorderSize,     // float     FrameBorderSize
    ImGuiStyleVar_ItemSpacing,         // ImVec2    ItemSpacing
    ImGuiStyleVar_ItemInnerSpacing,    // ImVec2    ItemInnerSpacing
    ImGuiStyleVar_IndentSpacing,       // float     IndentSpacing
    ImGuiStyleVar_ScrollbarSize,       // float     ScrollbarSize
    ImGuiStyleVar_ScrollbarRounding,   // float     ScrollbarRounding
    ImGuiStyleVar_GrabMinSize,         // float     GrabMinSize
    ImGuiStyleVar_GrabRounding,        // float     GrabRounding
    ImGuiStyleVar_ButtonTextAlign,     // ImVec2    ButtonTextAlign
    ImGuiStyleVar_COUNT

    // Obsolete names (will be removed)
    //#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS
    //, ImGuiStyleVar_Count_ = ImGuiStyleVar_COUNT, ImGuiStyleVar_ChildWindowRounding = ImGuiStyleVar_ChildRounding
    //#endif
}

// Enumeration for ColorEdit3() / ColorEdit4() / ColorPicker3() / ColorPicker4() / ColorButton()
enum //ImGuiColorEditFlags_
{
    ImGuiColorEditFlags_None            = 0,
    ImGuiColorEditFlags_NoAlpha         = 1 << 1,   //              // ColorEdit, ColorPicker, ColorButton: ignore Alpha component (read 3 components from the input pointer).
    ImGuiColorEditFlags_NoPicker        = 1 << 2,   //              // ColorEdit: disable picker when clicking on colored square.
    ImGuiColorEditFlags_NoOptions       = 1 << 3,   //              // ColorEdit: disable toggling options menu when right-clicking on inputs/small preview.
    ImGuiColorEditFlags_NoSmallPreview  = 1 << 4,   //              // ColorEdit, ColorPicker: disable colored square preview next to the inputs. (e.g. to show only the inputs)
    ImGuiColorEditFlags_NoInputs        = 1 << 5,   //              // ColorEdit, ColorPicker: disable inputs sliders/text widgets (e.g. to show only the small preview colored square).
    ImGuiColorEditFlags_NoTooltip       = 1 << 6,   //              // ColorEdit, ColorPicker, ColorButton: disable tooltip when hovering the preview.
    ImGuiColorEditFlags_NoLabel         = 1 << 7,   //              // ColorEdit, ColorPicker: disable display of inline text label (the label is still forwarded to the tooltip and picker).
    ImGuiColorEditFlags_NoSidePreview   = 1 << 8,   //              // ColorPicker: disable bigger color preview on right side of the picker, use small colored square preview instead.
    ImGuiColorEditFlags_NoDragDrop      = 1 << 9,   //              // ColorEdit: disable drag and drop target. ColorButton: disable drag and drop source.

    // User Options (right-click on widget to change some of them). You can set application defaults using SetColorEditOptions(). The idea is that you probably don't want to override them in most of your calls, let the user choose and/or call SetColorEditOptions() during startup.
    ImGuiColorEditFlags_AlphaBar        = 1 << 16,  //              // ColorEdit, ColorPicker: show vertical alpha bar/gradient in picker.
    ImGuiColorEditFlags_AlphaPreview    = 1 << 17,  //              // ColorEdit, ColorPicker, ColorButton: display preview as a transparent color over a checkerboard, instead of opaque.
    ImGuiColorEditFlags_AlphaPreviewHalf= 1 << 18,  //              // ColorEdit, ColorPicker, ColorButton: display half opaque / half checkerboard, instead of opaque.
    ImGuiColorEditFlags_HDR             = 1 << 19,  //              // (WIP) ColorEdit: Currently only disable 0.0f..1.0f limits in RGBA edition (note: you probably want to use ImGuiColorEditFlags_Float flag as well).
    ImGuiColorEditFlags_RGB             = 1 << 20,  // [Inputs]     // ColorEdit: choose one among RGB/HSV/HEX. ColorPicker: choose any combination using RGB/HSV/HEX.
    ImGuiColorEditFlags_HSV             = 1 << 21,  // [Inputs]     // "
    ImGuiColorEditFlags_HEX             = 1 << 22,  // [Inputs]     // "
    ImGuiColorEditFlags_Uint8           = 1 << 23,  // [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0..255.
    ImGuiColorEditFlags_Float           = 1 << 24,  // [DataType]   // ColorEdit, ColorPicker, ColorButton: _display_ values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
    ImGuiColorEditFlags_PickerHueBar    = 1 << 25,  // [PickerMode] // ColorPicker: bar for Hue, rectangle for Sat/Value.
    ImGuiColorEditFlags_PickerHueWheel  = 1 << 26,  // [PickerMode] // ColorPicker: wheel for Hue, triangle for Sat/Value.

    // [Internal] Masks
    ImGuiColorEditFlags__InputsMask     = ImGuiColorEditFlags_RGB|ImGuiColorEditFlags_HSV|ImGuiColorEditFlags_HEX,
    ImGuiColorEditFlags__DataTypeMask   = ImGuiColorEditFlags_Uint8|ImGuiColorEditFlags_Float,
    ImGuiColorEditFlags__PickerMask     = ImGuiColorEditFlags_PickerHueWheel|ImGuiColorEditFlags_PickerHueBar,
    ImGuiColorEditFlags__OptionsDefault = ImGuiColorEditFlags_Uint8|ImGuiColorEditFlags_RGB|ImGuiColorEditFlags_PickerHueBar    // Change application default using SetColorEditOptions()
}

// Enumeration for GetMouseCursor()
// User code may request binding to display given cursor by calling SetMouseCursor(), which is why we have some cursors that are marked unused here
enum //ImGuiMouseCursor_
{
    ImGuiMouseCursor_None = -1,
    ImGuiMouseCursor_Arrow = 0,
    ImGuiMouseCursor_TextInput,         // When hovering over InputText, etc.
    ImGuiMouseCursor_ResizeAll,         // Unused by imgui functions
    ImGuiMouseCursor_ResizeNS,          // When hovering over an horizontal border
    ImGuiMouseCursor_ResizeEW,          // When hovering over a vertical border or a column
    ImGuiMouseCursor_ResizeNESW,        // When hovering over the bottom-left corner of a window
    ImGuiMouseCursor_ResizeNWSE,        // When hovering over the bottom-right corner of a window
    ImGuiMouseCursor_COUNT

    // Obsolete names (will be removed)
    //#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS
    //, ImGuiMouseCursor_Count_ = ImGuiMouseCursor_COUNT
    //#endif
}

// Condition for ImGui::SetWindow***(), SetNextWindow***(), SetNextTreeNode***() functions
// Important: Treat as a regular enum! Do NOT combine multiple values using binary operators! All the functions above treat 0 as a shortcut to ImGuiCond_Always.
enum //ImGuiCond_
{
    ImGuiCond_Always        = 1 << 0,   // Set the variable
    ImGuiCond_Once          = 1 << 1,   // Set the variable once per runtime session (only the first call with succeed)
    ImGuiCond_FirstUseEver  = 1 << 2,   // Set the variable if the object/window has no persistently saved data (no entry in .ini file)
    ImGuiCond_Appearing     = 1 << 3    // Set the variable if the object/window is appearing after being hidden/inactive (or the first time)

    // Obsolete names (will be removed)
    //#ifndef IMGUI_DISABLE_OBSOLETE_FUNCTIONS
    //, ImGuiSetCond_Always = ImGuiCond_Always, ImGuiSetCond_Once = ImGuiCond_Once, ImGuiSetCond_FirstUseEver = ImGuiCond_FirstUseEver, ImGuiSetCond_Appearing = ImGuiCond_Appearing
    //#endif
}


// You may modify the ImGui::GetStyle() main instance during initialization and before NewFrame().
// During the frame, use ImGui::PushStyleVar(ImGuiStyleVar_XXXX)/PopStyleVar() to alter the main style values, and ImGui::PushStyleColor(ImGuiCol_XXX)/PopStyleColor() for colors.
struct ImGuiStyle
{
    float       Alpha;                      // Global alpha applies to everything in ImGui.
    ImVec2      WindowPadding;              // Padding within a window.
    float       WindowRounding;             // Radius of window corners rounding. Set to 0.0f to have rectangular windows.
    float       WindowBorderSize;           // Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    ImVec2      WindowMinSize;              // Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().
    ImVec2      WindowTitleAlign;           // Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.
    float       ChildRounding;              // Radius of child window corners rounding. Set to 0.0f to have rectangular windows.
    float       ChildBorderSize;            // Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    float       PopupRounding;              // Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)
    float       PopupBorderSize;            // Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    ImVec2      FramePadding;               // Padding within a framed rectangle (used by most widgets).
    float       FrameRounding;              // Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).
    float       FrameBorderSize;            // Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
    ImVec2      ItemSpacing;                // Horizontal and vertical spacing between widgets/lines.
    ImVec2      ItemInnerSpacing;           // Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).
    ImVec2      TouchExtraPadding;          // Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!
    float       IndentSpacing;              // Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).
    float       ColumnsMinSpacing;          // Minimum horizontal spacing between two columns.
    float       ScrollbarSize;              // Width of the vertical scrollbar, Height of the horizontal scrollbar.
    float       ScrollbarRounding;          // Radius of grab corners for scrollbar.
    float       GrabMinSize;                // Minimum width/height of a grab box for slider/scrollbar.
    float       GrabRounding;               // Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.
    ImVec2      ButtonTextAlign;            // Alignment of button text when button is larger than text. Defaults to (0.5f,0.5f) for horizontally+vertically centered.
    ImVec2      DisplayWindowPadding;       // Window positions are clamped to be visible within the display area by at least this amount. Only covers regular windows.
    ImVec2      DisplaySafeAreaPadding;     // If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!
    float       MouseCursorScale;           // Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later.
    bool        AntiAliasedLines;           // Enable anti-aliasing on lines/borders. Disable if you are really tight on CPU/GPU.
    bool        AntiAliasedFill;            // Enable anti-aliasing on filled shapes (rounded rectangles, circles, etc.)
    float       CurveTessellationTol;       // Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.
    ImVec4[ImGuiCol_COUNT]      Colors;

    //ImGuiStyle();
    void ScaleAllSizes(float scale_factor);
}

// This is where your app communicate with ImGui. Access via ImGui::GetIO().
// Read 'Programmer guide' section in .cpp file for general usage.
struct ImGuiIO
{
    //------------------------------------------------------------------
    // Settings (fill once)                 // Default value:
    //------------------------------------------------------------------

    ImGuiConfigFlags   ConfigFlags;         // = 0                  // See ImGuiConfigFlags_ enum. Set by user/application. Gamepad/keyboard navigation options, etc.
    ImGuiBackendFlags  BackendFlags;        // = 0                  // Set ImGuiBackendFlags_ enum. Set by imgui_impl_xxx files or custom back-end to communicate features supported by the back-end.
    ImVec2        DisplaySize;              // <unset>              // Display size, in pixels. For clamping windows positions.
    float         DeltaTime;                // = 1.0f/60.0f         // Time elapsed since last frame, in seconds.
    float         IniSavingRate;            // = 5.0f               // Minimum time between saving positions/sizes to .ini file, in seconds.
    const(char)*   IniFilename;             // = "imgui.ini"        // Path to .ini file. Set NULL to disable automatic .ini loading/saving, if e.g. you want to manually load/save from memory.
    const(char)*   LogFilename;             // = "imgui_log.txt"    // Path to .log file (default parameter to ImGui::LogToFile when no file is specified).
    float         MouseDoubleClickTime;     // = 0.30f              // Time for a double-click, in seconds.
    float         MouseDoubleClickMaxDist;  // = 6.0f               // Distance threshold to stay in to validate a double-click, in pixels.
    float         MouseDragThreshold;       // = 6.0f               // Distance threshold before considering we are dragging.
    int[ImGuiKey_COUNT]    KeyMap;          // <unset>              // Map of indices into the KeysDown[512] entries array which represent your "native" keyboard state.
    float         KeyRepeatDelay;           // = 0.250f             // When holding a key/button, time before it starts repeating, in seconds (for buttons in Repeat mode, etc.).
    float         KeyRepeatRate;            // = 0.050f             // When holding a key/button, rate at which it repeats, in seconds.
    void*         UserData;                 // = null               // Store your own data for retrieval by callbacks.

    ImFontAtlas*  Fonts;                    // <auto>               // Load and assemble one or more fonts into a single tightly packed texture. Output to Fonts array.
    float         FontGlobalScale;          // = 1.0f               // Global scale all fonts
    bool          FontAllowUserScaling;     // = false              // Allow user scaling text of individual window with CTRL+Wheel.
    ImFont*       FontDefault;              // = null               // Font to use on NewFrame(). Use NULL to uses Fonts->Fonts[0].
    ImVec2        DisplayFramebufferScale;  // = (1.0f,1.0f)        // For retina display or other situations where window coordinates are different from framebuffer coordinates. User storage only, presently not used by ImGui.
    ImVec2        DisplayVisibleMin;        // <unset> (0.0f,0.0f)  // If you use DisplaySize as a virtual space larger than your screen, set DisplayVisibleMin/Max to the visible area.
    ImVec2        DisplayVisibleMax;        // <unset> (0.0f,0.0f)  // If the values are the same, we defaults to Min=(0.0f) and Max=DisplaySize

    // Advanced/subtle behaviors
    bool          OptMacOSXBehaviors;       // = defined(__APPLE__) // OS X style: Text editing cursor movement using Alt instead of Ctrl, Shortcuts using Cmd/Super instead of Ctrl, Line/Text Start and End using Cmd+Arrows instead of Home/End, Double click selects by word instead of selecting whole text, Multi-selection in lists uses Cmd/Super instead of Ctrl
    bool          OptCursorBlink;           // = true               // Enable blinking cursor, for users who consider it annoying.

    //------------------------------------------------------------------
    // Settings (User Functions)
    //------------------------------------------------------------------

    // Optional: access OS clipboard
    // (default to use native Win32 clipboard on Windows, otherwise uses a private clipboard. Override to access OS clipboard on other architectures)
    const(char)* function(void* user_data) GetClipboardTextFn;
    void        function(void* user_data, const(char)* text) SetClipboardTextFn;
    void*       ClipboardUserData;

    // Optional: notify OS Input Method Editor of the screen position of your cursor for text input position (e.g. when using Japanese/Chinese IME in Windows)
    // (default to use native imm32 api on Windows)
    void        function(int x, int y) ImeSetInputScreenPosFn;
    void*       ImeWindowHandle;            // (Windows) Set this to your HWND to get automatic IME cursor positioning.

    // This is only here to keep ImGuiIO the same size, so that IMGUI_DISABLE_OBSOLETE_FUNCTIONS can exceptionally be used outside of imconfig.h.
    void*       RenderDrawListsFnDummy;

    //------------------------------------------------------------------
    // Input - Fill before calling NewFrame()
    //------------------------------------------------------------------

    ImVec2      MousePos;                       // Mouse position, in pixels. Set to ImVec2(-FLT_MAX,-FLT_MAX) if mouse is unavailable (on another screen, etc.)
    bool[5]     MouseDown;                      // Mouse buttons: left, right, middle + extras. ImGui itself mostly only uses left button (BeginPopupContext** are using right button). Others buttons allows us to track if the mouse is being used by your application + available to user as a convenience via IsMouse** API.
    float       MouseWheel;                     // Mouse wheel Vertical: 1 unit scrolls about 5 lines text.
    float       MouseWheelH;                    // Mouse wheel Horizontal. Most users don't have a mouse with an horizontal wheel, may not be filled by all back-ends.
    bool        MouseDrawCursor;                // Request ImGui to draw a mouse cursor for you (if you are on a platform without a mouse cursor).
    bool        KeyCtrl;                        // Keyboard modifier pressed: Control
    bool        KeyShift;                       // Keyboard modifier pressed: Shift
    bool        KeyAlt;                         // Keyboard modifier pressed: Alt
    bool        KeySuper;                       // Keyboard modifier pressed: Cmd/Super/Windows
    bool[512]   KeysDown;                       // Keyboard keys that are pressed (ideally left in the "native" order your engine has access to keyboard keys, so you can use your own defines/enums for keys).
    ImWchar[16+1]    InputCharacters;           // List of characters input (translated by user from keypress+keyboard state). Fill using AddInputCharacter() helper.
    float[ImGuiNavInput_COUNT]    NavInputs;    // Gamepad inputs (keyboard keys will be auto-mapped and be written here by ImGui::NewFrame, all values will be cleared back to zero in ImGui::EndFrame)

    // Functions
    void AddInputCharacter(ImWchar c);                        // Add new character into InputCharacters[]
    void AddInputCharactersUTF8(const(char)* utf8_chars);      // Add new characters into InputCharacters[] from an UTF-8 string
    void ClearInputCharacters() { InputCharacters[0] = 0; }   // Clear the text input buffer manually

    //------------------------------------------------------------------
    // Output - Retrieve after calling NewFrame()
    //------------------------------------------------------------------

    bool        WantCaptureMouse;           // When io.WantCaptureMouse is true, imgui will use the mouse inputs, do not dispatch them to your main game/application (in both cases, always pass on mouse inputs to imgui). (e.g. unclicked mouse is hovering over an imgui window, widget is active, mouse was clicked over an imgui window, etc.).
    bool        WantCaptureKeyboard;        // When io.WantCaptureKeyboard is true, imgui will use the keyboard inputs, do not dispatch them to your main game/application (in both cases, always pass keyboard inputs to imgui). (e.g. InputText active, or an imgui window is focused and navigation is enabled, etc.).
    bool        WantTextInput;              // Mobile/console: when io.WantTextInput is true, you may display an on-screen keyboard. This is set by ImGui when it wants textual keyboard input to happen (e.g. when a InputText widget is active).
    bool        WantSetMousePos;            // MousePos has been altered, back-end should reposition mouse on next frame. Set only when ImGuiConfigFlags_NavEnableSetMousePos flag is enabled.
    bool        WantSaveIniSettings;        // When manual .ini load/save is active (io.IniFilename == NULL), this will be set to notify your application that you can call SaveIniSettingsToMemory() and save yourself. IMPORTANT: You need to clear io.WantSaveIniSettings yourself.
    bool        NavActive;                  // Directional navigation is currently allowed (will handle ImGuiKey_NavXXX events) = a window is focused and it doesn't use the ImGuiWindowFlags_NoNavInputs flag.
    bool        NavVisible;                 // Directional navigation is visible and allowed (will handle ImGuiKey_NavXXX events).
    float       Framerate;                  // Application framerate estimation, in frame per second. Solely for convenience. Rolling average estimation based on IO.DeltaTime over 120 frames
    int         MetricsRenderVertices;      // Vertices output during last call to Render()
    int         MetricsRenderIndices;       // Indices output during last call to Render() = number of triangles * 3
    int         MetricsActiveWindows;       // Number of visible root windows (exclude child windows)
    ImVec2      MouseDelta;                 // Mouse delta. Note that this is zero if either current or previous position are invalid (-FLT_MAX,-FLT_MAX), so a disappearing/reappearing mouse won't have a huge delta.

    //------------------------------------------------------------------
    // [Internal] ImGui will maintain those fields. Forward compatibility not guaranteed!
    //------------------------------------------------------------------

    ImVec2      MousePosPrev;               // Previous mouse position temporary storage (nb: not for public use, set to MousePos in NewFrame())
    ImVec2[5]   MouseClickedPos;            // Position at time of clicking
    float[5]    MouseClickedTime;        // Time of last click (used to figure out double-click)
    bool[5]     MouseClicked;            // Mouse button went from !Down to Down
    bool[5]     MouseDoubleClicked;      // Has mouse button been double-clicked?
    bool[5]     MouseReleased;           // Mouse button went from Down to !Down
    bool[5]     MouseDownOwned;          // Track if button was clicked inside a window. We don't request mouse capture from the application if click started outside ImGui bounds.
    float[5]    MouseDownDuration;       // Duration the mouse button has been down (0.0f == just clicked)
    float[5]    MouseDownDurationPrev;   // Previous time the mouse button has been down
    ImVec2[5]   MouseDragMaxDistanceAbs; // Maximum distance, absolute, on each axis, of how much mouse has traveled from the clicking point
    float[5]    MouseDragMaxDistanceSqr; // Squared maximum distance of how much mouse has traveled from the clicking point
    float[512]  KeysDownDuration;      // Duration the keyboard key has been down (0.0f == just pressed)
    float[512]  KeysDownDurationPrev;  // Previous duration the key has been down
    float[ImGuiNavInput_COUNT]       NavInputsDownDuration;
    float[ImGuiNavInput_COUNT]       NavInputsDownDurationPrev;

    //this();
};

//-----------------------------------------------------------------------------
// Helpers
//-----------------------------------------------------------------------------

// D side note: this contains only data members, 
// on C++ side it mimics STL vector, and this is important to not mix memory allocators
// but currently not all methods are implement
extern(C++)
struct ImVector(T)
{
    int Size;
    int Capacity;
    T* Data;

    alias iterator = T*;
    alias const_iterator = const(T)*;

    alias Data this;
    ~this()        { if (Data) imgui_ns.MemFree(Data); }
    this(this)     { T* new_mem = cast(T*)imgui_ns.MemAlloc((Size+Capacity) * T.sizeof); memcpy(new_mem, Data, Size * T.sizeof); Data = new_mem; }

    bool                 empty() const                   { return Size == 0; }
    int                  size() const                    { return Size; }
    int                  capacity() const                { return Capacity; }
    //value_type&          operator[](int i)               { IM_ASSERT(i < Size); return Data[i]; }
    //const value_type&    operator[](int i) const         { IM_ASSERT(i < Size); return Data[i]; }

    void                 clear()                         { if (Data) { Size = Capacity = 0; imgui_ns.MemFree(Data); Data = null; } }
    iterator             begin()                         { return Data; }
    const_iterator       begin() const                   { return Data; }
    iterator             end()                           { return &Data[Size]; }
    const_iterator       end() const                     { return &Data[Size]; }
    ref T                front()                         { return Data[0]; }
    ref const(T)         front() const                   { return Data[0]; }
    ref T                back()                          { return Data[Size]; }
    ref const(T)         back() const                    { return Data[Size]; }
    void                 swap(ref ImVector!T rhs)        { int rhs_size = rhs.Size; rhs.Size = Size; Size = rhs_size; int rhs_cap = rhs.Capacity; rhs.Capacity = Capacity; Capacity = rhs_cap; T* rhs_data = rhs.Data; rhs.Data = Data; Data = rhs_data; }


    int                  _grow_capacity(int sz) const    { int new_capacity = Capacity ? (Capacity + Capacity/2) : 8; return new_capacity > sz ? new_capacity : sz; }
    void                 resize(int new_size)            { if (new_size > Capacity) reserve(_grow_capacity(new_size)); Size = new_size; }
    void                 resize(int new_size,const ref T v){ if (new_size > Capacity) reserve(_grow_capacity(new_size)); if (new_size > Size) for (int n = Size; n < new_size; n++) memcpy(&Data[n], &v, v.sizeof); Size = new_size; }
    void                 reserve(int new_capacity)
    {
        if (new_capacity <= Capacity)
            return;
        T* new_data = cast(T*)imgui_ns.MemAlloc((cast(size_t)new_capacity) * T.sizeof);
        if (Data)
        {
            memcpy(new_data, Data, (cast(size_t)Size) * T.sizeof);
            imgui_ns.MemFree(Data);
        }
        Data = new_data;
        Capacity = new_capacity;
    }

    // NB: It is forbidden to call push_back/push_front/insert with a reference pointing inside the ImVector data itself! e.g. v.push_back(v[10]) is forbidden.
    void                 push_back(const ref T v)                  { if (Size == Capacity) reserve(_grow_capacity(Size + 1)); memcpy(&Data[Size], &v, v.sizeof); Size++; }
    void                 push_back(const T v)                      { push_back(v); }
    void                 pop_back()                                { assert(Size > 0); Size--; }
    void                 push_front(const ref T v)                 { if (Size == 0) push_back(v); else insert(Data, v); }
    void                 push_front(const T v)                     { push_front(v); }
    iterator             erase(const_iterator it)                  { assert(it >= Data && it < Data+Size); const ptrdiff_t off = it - Data; memmove(Data + off, Data + off + 1, (cast(size_t)Size - cast(size_t)off - 1) * T.sizeof); Size--; return Data + off; }
    iterator             erase(const_iterator it, const_iterator it_last){ assert(it >= Data && it < Data+Size && it_last > it && it_last <= Data+Size); const ptrdiff_t count = it_last - it; const ptrdiff_t off = it - Data; memmove(Data + off, Data + off + count, (cast(size_t)Size - cast(size_t)off - count) * T.sizeof); Size -= cast(int)count; return iterator(Data + off); }
    iterator             erase_unsorted(const_iterator it)         { assert(it >= Data && it < Data+Size);  const ptrdiff_t off = it - Data; if (it < Data+Size-1) memcpy(Data + off, Data + Size - 1, T.sizeof); Size--; return Data + off; }
    iterator             insert(const_iterator it, const ref T v)  { assert(it >= Data && it <= Data+Size); const ptrdiff_t off = it - Data; if (Size == Capacity) reserve(_grow_capacity(Size + 1)); if (off < cast(int)Size) memmove(Data + off + 1, Data + off, (cast(size_t)Size - cast(size_t)off) * T.sizeof); memcpy(&Data[off], &v, v.sizeof); Size++; return iterator(Data + off); }
    iterator             insert(const_iterator it, const T v)      { return insert(it, v); }
    bool                 contains(const ref T v) const             { const(T)* data = Data;  const(T)* data_end = Data + Size; while (data < data_end) if (*data++ == v) return true; return false; }
}

// not sure if this is really needed for client code
/*
// Helper: IM_NEW(), IM_PLACEMENT_NEW(), IM_DELETE() macros to call MemAlloc + Placement New, Placement Delete + MemFree
// We call C++ constructor on own allocated memory via the placement "new(ptr) Type()" syntax.
// Defining a custom placement new() with a dummy parameter allows us to bypass including <new> which on some platforms complains when user has disabled exceptions.
struct ImNewDummy {};
inline void* operator new(size_t, ImNewDummy, void* ptr) { return ptr; }
inline void  operator delete(void*, ImNewDummy, void*)   {} // This is only required so we can use the symetrical new()
#define IM_PLACEMENT_NEW(_PTR)              new(ImNewDummy(), _PTR)
#define IM_NEW(_TYPE)                       new(ImNewDummy(), ImGui::MemAlloc(sizeof(_TYPE))) _TYPE
template<typename T> void IM_DELETE(T* p)   { if (p) { p->~T(); ImGui::MemFree(p); } }
*/

// Helper: Execute a block of code at maximum once a frame. Convenient if you want to quickly create an UI within deep-nested code that runs multiple times every frame.
// Usage: static ImGuiOnceUponAFrame oaf; if (oaf) ImGui::Text("This will be called only once per frame");
struct ImGuiOnceUponAFrame
{
    //ImGuiOnceUponAFrame() { RefFrame = -1; }
    int RefFrame = -1;
    //operator bool() const { int current_frame = GetFrameCount(); if (RefFrame == current_frame) return false; RefFrame = current_frame; return true; }
    // note: I have no idea
    bool opCall() { int current_frame = imgui_ns.GetFrameCount(); if (RefFrame == current_frame) return false; RefFrame = current_frame; return true; }
}

// Helper: Parse and apply text filters. In format "aaaaa[,bbbb][,ccccc]"
struct ImGuiTextFilter
{
    struct TextRange
    {
        const(char)* b;
        const(char)* e;

        //this() { b = e = null; }
        //this(const(char)* _b, const(char)* _e) { b = _b; e = _e; }
        const(char)* begin() const { return b; }
        const(char)* end() const { return e; }
        bool empty() const { return b == e; }
        char front() const { return *b; }
        static bool is_blank(char c) { return c == ' ' || c == '\t'; }
        void trim_blanks() { while (b < e && is_blank(*b)) b++; while (e > b && is_blank(*(e-1))) e--; }
        void split(char separator, ref ImVector!TextRange out_);
    };

    char[256]           InputBuf;
    ImVector!TextRange  Filters;
    int                 CountGrep;

    this(const(char)* default_filter = "");
    bool                Draw(const(char)* label = "Filter (inc,-exc)", float width = 0.0f);    // Helper calling InputText+Build
    bool                PassFilter(const(char)* text, const(char)* text_end = null) const;
    void                Build();
    void                Clear() { InputBuf[0] = 0; Build(); }
    bool                IsActive() const { return !Filters.empty(); }
};

// Helper: Text buffer for logging/accumulating text
struct ImGuiTextBuffer
{
    ImVector!char       Buf;

    //this()   { Buf.push_back(0); }
    char                opIndex(size_t i) { return Buf.Data[i]; }
    const(char)*        begin() const { return &Buf.front(); }
    const(char)*        end() const { return &Buf.back(); }      // Buf is zero-terminated, so end() will point on the zero-terminator
    int                 size() const { return Buf.Size - 1; }
    bool                empty() { return Buf.Size <= 1; }
    void                clear() { Buf.clear(); Buf.push_back('\0'); }
    void                reserve(int capacity) { Buf.reserve(capacity); }
    const(char)*        c_str() const { return Buf.Data; }
    void                appendf(const char* fmt, ...);// IM_FMTARGS(2);
    void                appendfv(const char* fmt, va_list args);// IM_FMTLIST(2);
}
// helper to use instead of default ctor
ImGuiTextBuffer imGuiTextBuffer() { ImGuiTextBuffer b; b.Buf.push_back('\0'); return b; }

// Helper: Simple Key->value storage
// Typically you don't have to worry about this since a storage is held within each Window.
// We use it to e.g. store collapse state for a tree (Int 0/1)
// This is optimized for efficient lookup (dichotomy into a contiguous buffer) and rare insertion (typically tied to user interactions aka max once a frame)
// You can use it as custom user storage for temporary values. Declare your own storage if, for example:
// - You want to manipulate the open/close state of a particular sub-tree in your interface (tree node uses Int 0/1 to store their state).
// - You want to store custom debug data easily without adding or editing structures in your code (probably not efficient, but convenient)
// Types are NOT stored, so it is up to you to make sure your Key don't collide with different types.
struct ImGuiStorage
{
    struct Pair
    {
        ImGuiID key;
        union { int val_i; float val_f; void* val_p; };
        this(ImGuiID _key, int _val_i)   { key = _key; val_i = _val_i; }
        this(ImGuiID _key, float _val_f) { key = _key; val_f = _val_f; }
        this(ImGuiID _key, void* _val_p) { key = _key; val_p = _val_p; }
    };
    ImVector!Pair      Data;

    // - Get***() functions find pair, never add/allocate. Pairs are sorted so a query is O(log N)
    // - Set***() functions find pair, insertion on demand if missing.
    // - Sorted insertion is costly, paid once. A typical frame shouldn't need to insert any new pair.
    void      Clear() { Data.clear(); }
    int       GetInt(ImGuiID key, int default_val = 0) const;
    void      SetInt(ImGuiID key, int val);
    bool      GetBool(ImGuiID key, bool default_val = false) const;
    void      SetBool(ImGuiID key, bool val);
    float     GetFloat(ImGuiID key, float default_val = 0.0f) const;
    void      SetFloat(ImGuiID key, float val);
    void*     GetVoidPtr(ImGuiID key) const; // default_val is NULL
    void      SetVoidPtr(ImGuiID key, void* val);

    // - Get***Ref() functions finds pair, insert on demand if missing, return pointer. Useful if you intend to do Get+Set.
    // - References are only valid until a new value is added to the storage. Calling a Set***() function or a Get***Ref() function invalidates the pointer.
    // - A typical use case where this is convenient for quick hacking (e.g. add storage during a live Edit&Continue session if you can't modify existing struct)
    //      float* pvar = ImGui::GetFloatRef(key); ImGui::SliderFloat("var", pvar, 0, 100.0f); some_var += *pvar;
    int*      GetIntRef(ImGuiID key, int default_val = 0);
    bool*     GetBoolRef(ImGuiID key, bool default_val = false);
    float*    GetFloatRef(ImGuiID key, float default_val = 0.0f);
    void**    GetVoidPtrRef(ImGuiID key, void* default_val = null);

    // Use on your own storage if you know only integer are being stored (open/close all tree nodes)
    void      SetAllInt(int val);

    // For quicker full rebuild of a storage (instead of an incremental one), you may add all your contents and then sort once.
    void      BuildSortByKey();
}

// Shared state of InputText(), passed to callback when a ImGuiInputTextFlags_Callback* flag is used and the corresponding callback is triggered.
struct ImGuiTextEditCallbackData
{
    ImGuiInputTextFlags EventFlag;      // One of ImGuiInputTextFlags_Callback* // Read-only
    ImGuiInputTextFlags Flags;          // What user passed to InputText()      // Read-only
    void*               UserData;       // What user passed to InputText()      // Read-only
    bool                ReadOnly;       // Read-only mode                       // Read-only

    // CharFilter event:
    ImWchar             EventChar;      // Character input                      // Read-write (replace character or set to zero)

    // Completion,History,Always events:
    // If you modify the buffer contents make sure you update 'BufTextLen' and set 'BufDirty' to true.
    ImGuiKey            EventKey;       // Key pressed (Up/Down/TAB)            // Read-only
    char*               Buf;            // Current text buffer                  // Read-write (pointed data only, can't replace the actual pointer)
    int                 BufTextLen;     // Current text length in bytes         // Read-write
    int                 BufSize;        // Maximum text length in bytes         // Read-only
    bool                BufDirty;       // Set if you modify Buf/BufTextLen!!   // Write
    int                 CursorPos;      //                                      // Read-write
    int                 SelectionStart; //                                      // Read-write (== to SelectionEnd when no selection)
    int                 SelectionEnd;   //                                      // Read-write

    // NB: Helper functions for text manipulation. Calling those function loses selection.
    void    DeleteChars(int pos, int bytes_count);
    void    InsertChars(int pos, const(char)* text, const(char)* text_end = null);
    bool    HasSelection() const { return SelectionStart != SelectionEnd; }
}


// Resizing callback data to apply custom constraint. As enabled by SetNextWindowSizeConstraints(). Callback is called during the next Begin().
// NB: For basic min/max size constraint on each axis you don't need to use the callback! The SetNextWindowSizeConstraints() parameters are enough.
struct ImGuiSizeCallbackData
{
    void*   UserData;       // Read-only.   What user passed to SetNextWindowSizeConstraints()
    ImVec2  Pos;            // Read-only.   Window position, for reference.
    ImVec2  CurrentSize;    // Read-only.   Current window size.
    ImVec2  DesiredSize;    // Read-write.  Desired size, based on user's mouse position. Write to this field to restrain resizing.
}

// Data payload for Drag and Drop operations
struct ImGuiPayload
{
    // Members
    void*           Data;               // Data (copied and owned by dear imgui)
    int             DataSize;           // Data size

    // [Internal]
    ImGuiID         SourceId;           // Source item id
    ImGuiID         SourceParentId;     // Source parent id (if available)
    int             DataFrameCount = -1;     // Data timestamp
    byte[32+1]      DataType;     // Data type tag (short user-supplied string, 32 characters max)
    bool            Preview;            // Set when AcceptDragDropPayload() was called and mouse has been hovering the target item (nb: handle overlapping drag targets)
    bool            Delivery;           // Set when AcceptDragDropPayload() was called and mouse button is released over the target item.

    // this() {Clear();}
    void Clear()    { SourceId = SourceParentId = 0; Data = null; DataSize = 0; memset(&DataType[0], 0, DataType.sizeof); DataFrameCount = -1; Preview = Delivery = false; }
    bool IsDataType(const(char)* type) const { return DataFrameCount != -1 && strcmp(type, cast(char*)&DataType[0]) == 0; }
    bool IsPreview() const                  { return Preview; }
    bool IsDelivery() const                 { return Delivery; }
}


// Helpers macros to generate 32-bits encoded colors
version(IMGUI_USE_BGRA_PACKED_COLOR)
{
    enum IM_COL32_R_SHIFT    =    16;
    enum IM_COL32_G_SHIFT    =    8;
    enum IM_COL32_B_SHIFT    =    0;
    enum IM_COL32_A_SHIFT    =    24;
    enum IM_COL32_A_MASK     =    0xFF000000;
} else {
    enum IM_COL32_R_SHIFT    =    0;
    enum IM_COL32_G_SHIFT    =    8;
    enum IM_COL32_B_SHIFT    =    16;
    enum IM_COL32_A_SHIFT    =    24;
    enum IM_COL32_A_MASK     =    0xFF000000;
}
ImU32 IM_COL32(int R, int G, int B, int A)    { return (cast(ImU32)(A)<<IM_COL32_A_SHIFT) | (cast(ImU32)(B)<<IM_COL32_B_SHIFT) | (cast(ImU32)(G)<<IM_COL32_G_SHIFT) | (cast(ImU32)(R)<<IM_COL32_R_SHIFT); }
enum IM_COL32_WHITE    =   IM_COL32(255,255,255,255);  // Opaque white = 0xFFFFFFFF
enum IM_COL32_BLACK    =   IM_COL32(0,0,0,255);        // Opaque black
enum IM_COL32_BLACK_TRANS = IM_COL32(0,0,0,0);          // Transparent black = 0x00000000

// Helper: ImColor() implicity converts colors to either ImU32 (packed 4x1 byte) or ImVec4 (4x1 float)
// Prefer using IM_COL32() macros if you want a guaranteed compile-time ImU32 for usage with ImDrawList API.
// **Avoid storing ImColor! Store either u32 of ImVec4. This is not a full-featured color class. MAY OBSOLETE.
// **None of the ImGui API are using ImColor directly but you can use it as a convenience to pass colors in either ImU32 or ImVec4 formats. Explicitly cast to ImU32 or ImVec4 if needed.
struct ImColor
{
    ImVec4              Value;

    //this()                                                          { Value.x = Value.y = Value.z = Value.w = 0.0f; }
    this(int r, int g, int b, int a = 255)                          { float sc = 1.0f/255.0f; Value.x = cast(float)r * sc; Value.y = cast(float)g * sc; Value.z = cast(float)b * sc; Value.w = cast(float)a * sc; }
    this(ImU32 rgba)                                                { float sc = 1.0f/255.0f; Value.x = cast(float)((rgba>>IM_COL32_R_SHIFT)&0xFF) * sc; Value.y = cast(float)((rgba>>IM_COL32_G_SHIFT)&0xFF) * sc; Value.z = cast(float)((rgba>>IM_COL32_B_SHIFT)&0xFF) * sc; Value.w = cast(float)((rgba>>IM_COL32_A_SHIFT)&0xFF) * sc; }
    this(float r, float g, float b, float a = 1.0f)                 { Value.x = r; Value.y = g; Value.z = b; Value.w = a; }
    //this(const ImVec4& col)                                         { Value = col; }
    ImU32  opCast(T)() const  if (is(/*Unqual!*/T == ImU32))            { return imgui_ns.ColorConvertFloat4ToU32(Value); }
    ImVec4 opCast(T)() const  if (is(/*Unqual!*/T == ImVec4))           { return Value; }

    // FIXME-OBSOLETE: May need to obsolete/cleanup those helpers.
    //void    SetHSV(float h, float s, float v, float a = 1.0f){ ImGui::ColorConvertHSVtoRGB(h, s, v, Value.x, Value.y, Value.z); Value.w = a; }
    //static ImColor HSV(float h, float s, float v, float a = 1.0f)   { float r,g,b; ImGui::ColorConvertHSVtoRGB(h, s, v, r, g, b); return ImColor(r,g,b,a); }
}

// Helper: Manually clip large list of items.
// If you are submitting lots of evenly spaced items and you have a random access to the list, you can perform coarse clipping based on visibility to save yourself from processing those items at all.
// The clipper calculates the range of visible items and advance the cursor to compensate for the non-visible items we have skipped.
// ImGui already clip items based on their bounds but it needs to measure text size to do so. Coarse clipping before submission makes this cost and your own data fetching/submission cost null.
// Usage:
//     ImGuiListClipper clipper(1000);  // we have 1000 elements, evenly spaced.
//     while (clipper.Step())
//         for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
//             ImGui::Text("line number %d", i);
// - Step 0: the clipper let you process the first element, regardless of it being visible or not, so we can measure the element height (step skipped if we passed a known height as second arg to constructor).
// - Step 1: the clipper infer height from first element, calculate the actual range of elements to display, and position the cursor before the first element.
// - (Step 2: dummy step only required if an explicit items_height was passed to constructor or Begin() and user call Step(). Does nothing and switch to Step 3.)
// - Step 3: the clipper validate that we have reached the expected Y position (corresponding to element DisplayEnd), advance the cursor to the end of the list and then returns 'false' to end the loop.
struct ImGuiListClipper
{
    float   StartPosY;
    float   ItemsHeight;
    int     ItemsCount, StepNo, DisplayStart, DisplayEnd;

    // items_count:  Use -1 to ignore (you can call Begin later). Use INT_MAX if you don't know how many items you have (in which case the cursor won't be advanced in the final step).
    // items_height: Use -1.0f to be calculated automatically on first step. Otherwise pass in the distance between your items, typically GetTextLineHeightWithSpacing() or GetFrameHeightWithSpacing().
    // If you don't specify an items_height, you NEED to call Step(). If you specify items_height you may call the old Begin()/End() api directly, but prefer calling Step().
    this(int items_count = -1, float items_height = -1.0f)  { Begin(items_count, items_height); } // NB: Begin() initialize every fields (as we allow user to call Begin/End multiple times on a same instance if they want).
    ~this()                                                 { assert(ItemsCount == -1); }      // Assert if user forgot to call End() or Step() until false.

    bool Step();                                              // Call until it returns false. The DisplayStart/DisplayEnd fields will be set and you can process/draw those items.
    void Begin(int items_count, float items_height = -1.0f);  // Automatically called by constructor if you passed 'items_count' or by Step() in Step 1.
    void End();                                               // Automatically called on the last call of Step() that returns false.
}

// Draw callbacks for advanced uses.
// NB- You most likely do NOT need to use draw callbacks just to create your own widget or customized UI rendering (you can poke into the draw list for that)
// Draw callback may be useful for example, A) Change your GPU render state, B) render a complex 3D scene inside a UI element (without an intermediate texture/render target), etc.
// The expected behavior from your rendering function is 'if (cmd.UserCallback != NULL) cmd.UserCallback(parent_list, cmd); else RenderTriangles()'
alias ImDrawCallback = extern(C++) void function(const ImDrawList* parent_list, const ImDrawCmd* cmd);

// Typically, 1 command = 1 GPU draw call (unless command is a callback)
struct ImDrawCmd
{
    uint            ElemCount;              // Number of indices (multiple of 3) to be rendered as triangles. Vertices are stored in the callee ImDrawList's vtx_buffer[] array, indices in idx_buffer[].
    ImVec4          ClipRect;               // Clipping rectangle (x1, y1, x2, y2). Subtract ImDrawData->DisplayPos to get clipping rectangle in "viewport" coordinates
    ImTextureID     TextureId;              // User-provided texture ID. Set by user in ImfontAtlas::SetTexID() for fonts or passed to Image*() functions. Ignore if never using images or multiple fonts atlas.
    ImDrawCallback  UserCallback;           // If != NULL, call the function instead of rendering the vertices. clip_rect and texture_id will be set normally.
    void*           UserCallbackData;       // The draw callback code can access this.
}

//static if (!is(typeof(ImDrawIdx)))
//    alias ImDrawIdx = ushort;

// Vertex layout
struct ImDrawVert
{
    ImVec2  pos;
    ImVec2  uv;
    ImU32   col;
}

// Draw channels are used by the Columns API to "split" the render list into different channels while building, so items of each column can be batched together.
// You can also use them to simulate drawing layers and submit primitives in a different order than how they will be rendered.
struct ImDrawChannel
{
    ImVector!ImDrawCmd     CmdBuffer;
    ImVector!ImDrawIdx     IdxBuffer;
}

enum //ImDrawCornerFlags_
{
    ImDrawCornerFlags_TopLeft   = 1 << 0, // 0x1
    ImDrawCornerFlags_TopRight  = 1 << 1, // 0x2
    ImDrawCornerFlags_BotLeft   = 1 << 2, // 0x4
    ImDrawCornerFlags_BotRight  = 1 << 3, // 0x8
    ImDrawCornerFlags_Top       = ImDrawCornerFlags_TopLeft | ImDrawCornerFlags_TopRight,   // 0x3
    ImDrawCornerFlags_Bot       = ImDrawCornerFlags_BotLeft | ImDrawCornerFlags_BotRight,   // 0xC
    ImDrawCornerFlags_Left      = ImDrawCornerFlags_TopLeft | ImDrawCornerFlags_BotLeft,    // 0x5
    ImDrawCornerFlags_Right     = ImDrawCornerFlags_TopRight | ImDrawCornerFlags_BotRight,  // 0xA
    ImDrawCornerFlags_All       = 0xF     // In your function calls you may use ~0 (= all bits sets) instead of ImDrawCornerFlags_All, as a convenience
}

enum //ImDrawListFlags_
{
    ImDrawListFlags_AntiAliasedLines = 1 << 0,
    ImDrawListFlags_AntiAliasedFill  = 1 << 1
}

// Draw command list
// This is the low-level list of polygons that ImGui functions are filling. At the end of the frame, all command lists are passed to your ImGuiIO::RenderDrawListFn function for rendering.
// Each ImGui window contains its own ImDrawList. You can use ImGui::GetWindowDrawList() to access the current window draw list and draw custom primitives.
// You can interleave normal ImGui:: calls and adding primitives to the current draw list.
// All positions are generally in pixel coordinates (top-left at (0,0), bottom-right at io.DisplaySize), but you are totally free to apply whatever transformation matrix to want to the data (if you apply such transformation you'll want to apply it to ClipRect as well)
// Important: Primitives are always added to the list and not culled (culling is done at higher-level by ImGui:: functions), if you use this API a lot consider coarse culling your drawn objects.
struct ImDrawList
{
    // This is what you have to render
    ImVector!ImDrawCmd     CmdBuffer;          // Draw commands. Typically 1 command = 1 GPU draw call, unless the command is a callback.
    ImVector!ImDrawIdx     IdxBuffer;          // Index buffer. Each command consume ImDrawCmd::ElemCount of those
    ImVector!ImDrawVert    VtxBuffer;          // Vertex buffer.
    ImDrawListFlags         Flags;             // Flags, you may poke into these to adjust anti-aliasing settings per-primitive.

    // [Internal, used while building lists]
    const(ImDrawListSharedData)* _Data;         // Pointer to shared draw data (you can use ImGui::GetDrawListSharedData() to get the one from current ImGui context)
    const(char)*            _OwnerName;         // Pointer to owner window's name for debugging
    uint                    _VtxCurrentIdx;     // [Internal] == VtxBuffer.Size
    ImDrawVert*             _VtxWritePtr;       // [Internal] point within VtxBuffer.Data after each add command (to avoid using the ImVector<> operators too much)
    ImDrawIdx*              _IdxWritePtr;       // [Internal] point within IdxBuffer.Data after each add command (to avoid using the ImVector<> operators too much)
    ImVector!ImVec4         _ClipRectStack;     // [Internal]
    ImVector!ImTextureID    _TextureIdStack;    // [Internal]
    ImVector!ImVec2         _Path;              // [Internal] current path building
    int                     _ChannelsCurrent;   // [Internal] current channel number (0)
    int                     _ChannelsCount;     // [Internal] number of active channels (1+)
    ImVector!ImDrawChannel  _Channels;          // [Internal] draw channels for columns API (not resized down so _ChannelsCount may be smaller than _Channels.Size)

    // If you want to create ImDrawList instances, pass them ImGui::GetDrawListSharedData() or create and use your own ImDrawListSharedData (so you can use ImDrawList without ImGui)
    this(const(ImDrawListSharedData)* shared_data);// { _Data = shared_data; _OwnerName = null; Clear(); }
    ~this() { ClearFreeMemory(); }
    void  PushClipRect(ImVec2 clip_rect_min, ImVec2 clip_rect_max, bool intersect_with_current_clip_rect = false);  // Render-level scissoring. This is passed down to your render function but not used for CPU-side coarse clipping. Prefer using higher-level ImGui::PushClipRect() to affect logic (hit-testing and widget culling)
    void  PushClipRectFullScreen();
    void  PopClipRect();
    void  PushTextureID(ImTextureID texture_id);
    void  PopTextureID();
    ImVec2   GetClipRectMin() const { auto cr = &_ClipRectStack.back(); return ImVec2(cr.x, cr.y); }
    ImVec2   GetClipRectMax() const { auto cr = &_ClipRectStack.back(); return ImVec2(cr.z, cr.w); }

    // Primitives
    void  AddLine(ref const(ImVec2) a, ref const(ImVec2) b, ImU32 col, float thickness = 1.0f);
    void  AddRect(ref const(ImVec2) a, ref const(ImVec2) b, ImU32 col, float rounding = 0.0f, int rounding_corners_flags = ImDrawCornerFlags_All, float thickness = 1.0f);   // a: upper-left, b: lower-right, rounding_corners_flags: 4-bits corresponding to which corner to round
    void  AddRectFilled(ref const(ImVec2) a, ref const(ImVec2) b, ImU32 col, float rounding = 0.0f, int rounding_corners_flags = ImDrawCornerFlags_All);                     // a: upper-left, b: lower-right
    void  AddRectFilledMultiColor(ref const(ImVec2) a, ref const(ImVec2) b, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left);
    void  AddQuad(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ref const(ImVec2) d, ImU32 col, float thickness = 1.0f);
    void  AddQuadFilled(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ref const(ImVec2) d, ImU32 col);
    void  AddTriangle(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ImU32 col, float thickness = 1.0f);
    void  AddTriangleFilled(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ImU32 col);
    void  AddCircle(ref const(ImVec2) centre, float radius, ImU32 col, int num_segments = 12, float thickness = 1.0f);
    void  AddCircleFilled(ref const(ImVec2) centre, float radius, ImU32 col, int num_segments = 12);
    void  AddText(ref const(ImVec2) pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null);
    void  AddText(const(ImFont)* font, float font_size, ref const(ImVec2) pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null, float wrap_width = 0.0f, const(ImVec4)* cpu_fine_clip_rect = null);
    void  AddImage(ImTextureID user_texture_id, ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) uv_a = ImVec2(0,0).byRef, ref const(ImVec2) uv_b = ImVec2(1,1).byRef, ImU32 col = 0xFFFFFFFF);
    void  AddImageQuad(ImTextureID user_texture_id, ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ref const(ImVec2) d, ref const(ImVec2) uv_a = ImVec2(0,0).byRef, ref const(ImVec2) uv_b = ImVec2(1,0).byRef, ref const(ImVec2) uv_c = ImVec2(1,1).byRef, ref const(ImVec2) uv_d = ImVec2(0,1).byRef, ImU32 col = 0xFFFFFFFF);
    void  AddImageRounded(ImTextureID user_texture_id, ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) uv_a, ref const(ImVec2) uv_b, ImU32 col, float rounding, int rounding_corners = ImDrawCornerFlags_All);
    void  AddPolyline(const(ImVec2)* points, const int num_points, ImU32 col, bool closed, float thickness);
    void  AddConvexPolyFilled(const(ImVec2)* points, const int num_points, ImU32 col); // Note: Anti-aliased filling requires points to be in clockwise order.
    void  AddBezierCurve(ref const(ImVec2) pos0, ref const(ImVec2) cp0, ref const(ImVec2) cp1, ref const(ImVec2) pos1, ImU32 col, float thickness, int num_segments = 0);

    // Stateful path API, add points then finish with PathFillConvex() or PathStroke()
    void  PathClear()                                                 { _Path.resize(0); }
    void  PathLineTo(ref const(ImVec2) pos)                               { _Path.push_back(pos); }
    void  PathLineToMergeDuplicate(ref const(ImVec2) pos)                 { if (_Path.Size == 0 || memcmp(&_Path[_Path.Size-1], &pos, 8) != 0) _Path.push_back(pos); }
    void  PathFillConvex(ImU32 col)                                   { AddConvexPolyFilled(_Path.Data, _Path.Size, col); PathClear(); }  // Note: Anti-aliased filling requires points to be in clockwise order.
    void  PathStroke(ImU32 col, bool closed, float thickness = 1.0f)  { AddPolyline(_Path.Data, _Path.Size, col, closed, thickness); PathClear(); }
    void  PathArcTo(ref const(ImVec2) centre, float radius, float a_min, float a_max, int num_segments = 10);
    void  PathArcToFast(ref const(ImVec2) centre, float radius, int a_min_of_12, int a_max_of_12);                                            // Use precomputed angles for a 12 steps circle
    void  PathBezierCurveTo(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, int num_segments = 0);
    void  PathRect(ref const(ImVec2) rect_min, ref const(ImVec2) rect_max, float rounding = 0.0f, int rounding_corners_flags = ImDrawCornerFlags_All);

    // Channels
    // - Use to simulate layers. By switching channels to can render out-of-order (e.g. submit foreground primitives before background primitives)
    // - Use to minimize draw calls (e.g. if going back-and-forth between multiple non-overlapping clipping rectangles, prefer to append into separate channels then merge at the end)
    void  ChannelsSplit(int channels_count);
    void  ChannelsMerge();
    void  ChannelsSetCurrent(int channel_index);

    // Advanced
    void  AddCallback(ImDrawCallback callback, void* callback_data);  // Your rendering function must check for 'UserCallback' in ImDrawCmd and call the function instead of rendering triangles.
    void  AddDrawCmd();                                               // This is useful if you need to forcefully create a new draw call (to allow for dependent rendering / blending). Otherwise primitives are merged into the same draw-call as much as possible
    ImDrawList* CloneOutput() const;                                  // Create a clone of the CmdBuffer/IdxBuffer/VtxBuffer.

    // Internal helpers
    // NB: all primitives needs to be reserved via PrimReserve() beforehand!
    void  Clear();
    void  ClearFreeMemory();
    void  PrimReserve(int idx_count, int vtx_count);
    void  PrimRect(ref const(ImVec2) a, ref const(ImVec2) b, ImU32 col);      // Axis aligned rectangle (composed of two triangles)
    void  PrimRectUV(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) uv_a, ref const(ImVec2) uv_b, ImU32 col);
    void  PrimQuadUV(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ref const(ImVec2) d, ref const(ImVec2) uv_a, ref const(ImVec2) uv_b, ref const(ImVec2) uv_c, ref const(ImVec2) uv_d, ImU32 col);
    void  PrimWriteVtx(ref const(ImVec2) pos, ref const(ImVec2) uv, ImU32 col){ _VtxWritePtr.pos = pos; _VtxWritePtr.uv = uv; _VtxWritePtr.col = col; _VtxWritePtr++; _VtxCurrentIdx++; }
    void  PrimWriteIdx(ImDrawIdx idx)                                 { *_IdxWritePtr = idx; _IdxWritePtr++; }
    void  PrimVtx(ref const(ImVec2) pos, ref const(ImVec2) uv, ImU32 col)     { PrimWriteIdx(cast(ImDrawIdx)_VtxCurrentIdx); PrimWriteVtx(pos, uv, col); }
    void  UpdateClipRect();
    void  UpdateTextureID();
}

// All draw data to render an ImGui frame
// (NB: the style and the naming convention here is a little inconsistent but we preserve them for backward compatibility purpose)
struct ImDrawData
{
    bool            Valid;                  // Only valid after Render() is called and before the next NewFrame() is called.
    ImDrawList**    CmdLists;               // Array of ImDrawList* to render. The ImDrawList are owned by ImGuiContext and only pointed to from here.
    int             CmdListsCount;          // Number of ImDrawList* to render
    int             TotalIdxCount;          // For convenience, sum of all ImDrawList's IdxBuffer.Size
    int             TotalVtxCount;          // For convenience, sum of all ImDrawList's VtxBuffer.Size
    ImVec2          DisplayPos;             // Upper-left position of the viewport to render (== upper-left of the orthogonal projection matrix to use)
    ImVec2          DisplaySize;            // Size of the viewport to render (== io.DisplaySize for the main viewport) (DisplayPos + DisplaySize == lower-right of the orthogonal projection matrix to use)

    // Functions
    //ImDrawData()    { Valid = false; Clear(); }
    //~ImDrawData()   { Clear(); }
    void Clear()    { Valid = false; CmdLists = null; CmdListsCount = TotalVtxCount = TotalIdxCount = 0; DisplayPos = DisplaySize = ImVec2(0f, 0f); } // The ImDrawList are owned by ImGuiContext!
    void  DeIndexAllBuffers();                // Helper to convert all buffers from indexed to non-indexed, in case you cannot render indexed. Note: this is slow and most likely a waste of resources. Always prefer indexed rendering!
    void  ScaleClipRects(const ref ImVec2 sc);   // Helper to scale the ClipRect field of each ImDrawCmd. Use if your final output buffer is at a different scale than ImGui expects, or if there is a difference between your window resolution and framebuffer resolution.
}


struct ImFontConfig
{
    void*           FontData;               //          // TTF/OTF data
    int             FontDataSize;           //          // TTF/OTF data size
    bool            FontDataOwnedByAtlas = true;   // true     // TTF/OTF data ownership taken by the container ImFontAtlas (will delete memory itself).
    int             FontNo;                 // 0        // Index of font within TTF/OTF file
    float           SizePixels = 1.0f;      //          // Size in pixels for rasterizer (more or less maps to the resulting font height).
    int             OversampleH = 3;        // 3        // Rasterize at higher quality for sub-pixel positioning. We don't use sub-pixel positions on the Y axis.
    int             OversampleV = 1;        // 1        // Rasterize at higher quality for sub-pixel positioning. We don't use sub-pixel positions on the Y axis.
    bool            PixelSnapH;             // false    // Align every glyph to pixel boundary. Useful e.g. if you are merging a non-pixel aligned font with the default font. If enabled, you can set OversampleH/V to 1.
    ImVec2          GlyphExtraSpacing;      // 0, 0     // Extra spacing (in pixels) between glyphs. Only X axis is supported for now.
    ImVec2          GlyphOffset;            // 0, 0     // Offset all glyphs from this font input.
    const(ImWchar)* GlyphRanges;            // NULL     // Pointer to a user-provided list of Unicode range (2 value per range, values are inclusive, zero-terminated list). THE ARRAY DATA NEEDS TO PERSIST AS LONG AS THE FONT IS ALIVE.
    float           GlyphMinAdvanceX = 0f;  // 0        // Minimum AdvanceX for glyphs, set Min to align font icons, set both Min/Max to enforce mono-space font
    float           GlyphMaxAdvanceX = FLT_MAX;       // FLT_MAX  // Maximum AdvanceX for glyphs
    bool            MergeMode;              // false    // Merge into previous ImFont, so you can combine multiple inputs font into one ImFont (e.g. ASCII font + icons + Japanese glyphs). You may want to use GlyphOffset.y when merge font of different heights.
    uint            RasterizerFlags;        // 0x00     // Settings for custom font rasterizer (e.g. ImGuiFreeType). Leave as zero if you aren't using one.
    float           RasterizerMultiply = 1.0f;     // 1.0f     // Brighten (>1.0f) or darken (<1.0f) font output. Brightening small fonts may be a good workaround to make them more readable.

    // [Internal]
    char[40]        Name;               // Name (strictly to ease debugging)
    ImFont*         DstFont;

    //this();
}

struct ImFontGlyph
{
    ImWchar         Codepoint;          // 0x0000..0xFFFF
    float           AdvanceX;           // Distance to next character (= data from font + ImFontConfig::GlyphExtraSpacing.x baked in)
    float           X0, Y0, X1, Y1;     // Glyph corners
    float           U0, V0, U1, V1;     // Texture coordinates
}

enum //ImFontAtlasFlags_
{
    ImFontAtlasFlags_NoPowerOfTwoHeight = 1 << 0,   // Don't round the height to next power of two
    ImFontAtlasFlags_NoMouseCursors     = 1 << 1    // Don't build software mouse cursors into the atlas
}




// Load and rasterize multiple TTF/OTF fonts into a same texture.
// Sharing a texture for multiple fonts allows us to reduce the number of draw calls during rendering.
// We also add custom graphic data into the texture that serves for ImGui.
//  1. (Optional) Call AddFont*** functions. If you don't call any, the default font will be loaded for you.
//  2. Call GetTexDataAsAlpha8() or GetTexDataAsRGBA32() to build and retrieve pixels data.
//  3. Upload the pixels data into a texture within your graphics system.
//  4. Call SetTexID(my_tex_id); and pass the pointer/identifier to your texture. This value will be passed back to you during rendering to identify the texture.
// IMPORTANT: If you pass a 'glyph_ranges' array to AddFont*** functions, you need to make sure that your array persist up until the ImFont is build (when calling GetTexData*** or Build()). We only copy the pointer, not the data.
extern(C++)
struct ImFontAtlas
{
    //this();
    ~this();
    ImFont*           AddFont(const(ImFontConfig)* font_cfg);
    ImFont*           AddFontDefault(const(ImFontConfig)* font_cfg = null);
    ImFont*           AddFontFromFileTTF(const(char)* filename, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null);
    ImFont*           AddFontFromMemoryTTF(void* font_data, int font_size, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null); // Note: Transfer ownership of 'ttf_data' to ImFontAtlas! Will be deleted after Build(). Set font_cfg->FontDataOwnedByAtlas to false to keep ownership.
    ImFont*           AddFontFromMemoryCompressedTTF(const void* compressed_font_data, int compressed_font_size, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null); // 'compressed_font_data' still owned by caller. Compress with binary_to_compressed_c.cpp.
    ImFont*           AddFontFromMemoryCompressedBase85TTF(const(char)* compressed_font_data_base85, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null);              // 'compressed_font_data_base85' still owned by caller. Compress with binary_to_compressed_c.cpp with -base85 parameter.
    void              ClearInputData();           // Clear input data (all ImFontConfig structures including sizes, TTF data, glyph ranges, etc.) = all the data used to build the texture and fonts.
    void              ClearTexData();             // Clear output texture data (CPU side). Saves RAM once the texture has been copied to graphics memory.
    void              ClearFonts();               // Clear output font data (glyphs storage, UV coordinates).
    void              Clear();                    // Clear all input and output.

    // Build atlas, retrieve pixel data.
    // User is in charge of copying the pixels into graphics memory (e.g. create a texture with your engine). Then store your texture handle with SetTexID().
    // RGBA32 format is provided for convenience and compatibility, but note that unless you use CustomRect to draw color data, the RGB pixels emitted from Fonts will all be white (~75% of waste).
    // Pitch = Width * BytesPerPixels
    bool              Build();                    // Build pixels data. This is called automatically for you by the GetTexData*** functions.
    bool              IsBuilt()                   { return Fonts.Size > 0 && (TexPixelsAlpha8 != null || TexPixelsRGBA32 != null); }
    void              GetTexDataAsAlpha8(ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel = null);  // 1 byte per-pixel
    void              GetTexDataAsRGBA32(ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel = null);  // 4 bytes-per-pixel
    void              SetTexID(ImTextureID id)    { TexID = id; }

    //-------------------------------------------
    // Glyph Ranges
    //-------------------------------------------

    // Helpers to retrieve list of common Unicode ranges (2 value per range, values are inclusive, zero-terminated list)
    // NB: Make sure that your string are UTF-8 and NOT in your local code page. In C++11, you can create UTF-8 string literal using the u8"Hello world" syntax. See FAQ for details.
    // NB: Consider using GlyphRangesBuilder to build glyph ranges from textual data.
    const(ImWchar)*    GetGlyphRangesDefault();                // Basic Latin, Extended Latin
    const(ImWchar)*    GetGlyphRangesKorean();                 // Default + Korean characters
    const(ImWchar)*    GetGlyphRangesJapanese();               // Default + Hiragana, Katakana, Half-Width, Selection of 1946 Ideographs
    const(ImWchar)*    GetGlyphRangesChineseFull();            // Default + Half-Width + Japanese Hiragana/Katakana + full set of about 21000 CJK Unified Ideographs
    const(ImWchar)*    GetGlyphRangesChineseSimplifiedCommon();// Default + Half-Width + Japanese Hiragana/Katakana + set of 2500 CJK Unified Ideographs for common simplified Chinese
    const(ImWchar)*    GetGlyphRangesCyrillic();               // Default + about 400 Cyrillic characters
    const(ImWchar)*    GetGlyphRangesThai();                   // Default + Thai characters

    // Helpers to build glyph ranges from text data. Feed your application strings/characters to it then call BuildRanges().
    struct GlyphRangesBuilder
    {
        ImVector!char UsedChars;  // Store 1-bit per Unicode code point (0=unused, 1=used)
        this(void* _ = null)                { UsedChars.resize(0x10000 / 8); memset(UsedChars.Data, 0, 0x10000 / 8); }
        bool           GetBit(int n) const  { return (UsedChars[n >> 3] & (1 << (n & 7))) != 0; }
        void           SetBit(int n)        { UsedChars[n >> 3] |= 1 << (n & 7); }  // Set bit 'c' in the array
        void           AddChar(ImWchar c)   { SetBit(c); }                          // Add character
        void AddText(const(char)* text, const(char)* text_end = null);      // Add string (each character of the UTF-8 string are added)
        void AddRanges(const(ImWchar)* ranges);                            // Add ranges, e.g. builder.AddRanges(ImFontAtlas::GetGlyphRangesDefault()) to force add all of ASCII/Latin+Ext
        void BuildRanges(ImVector!(ImWchar*) out_ranges);                  // Output new ranges
    };

    //-------------------------------------------
    // Custom Rectangles/Glyphs API
    //-------------------------------------------

    // You can request arbitrary rectangles to be packed into the atlas, for your own purposes. After calling Build(), you can query the rectangle position and render your pixels.
    // You can also request your rectangles to be mapped as font glyph (given a font + Unicode point), so you can render e.g. custom colorful icons and use them as regular glyphs.
    struct CustomRect
    {
        uint    ID;             // Input    // User ID. Use <0x10000 to map into a font glyph, >=0x10000 for other/internal/custom texture data.
        ushort  Width, Height;  // Input    // Desired rectangle dimension
        ushort  X, Y;           // Output   // Packed position in Atlas
        float           GlyphAdvanceX;  // Input    // For custom font glyphs only (ID<0x10000): glyph xadvance
        ImVec2          GlyphOffset;    // Input    // For custom font glyphs only (ID<0x10000): glyph display offset
        ImFont*         Font;           // Input    // For custom font glyphs only (ID<0x10000): target font
        this(void* = null)            { ID = 0xFFFFFFFF; Width = Height = 0; X = Y = 0xFFFF; GlyphAdvanceX = 0.0f; GlyphOffset = ImVec2(0,0); Font = null; }
        bool IsPacked() const   { return X != 0xFFFF; }
    };

    int       AddCustomRectRegular(uint id, int width, int height);                                                                   // Id needs to be >= 0x10000. Id >= 0x80000000 are reserved for ImGui and ImDrawList
    int       AddCustomRectFontGlyph(ImFont* font, ImWchar id, int width, int height, float advance_x, const ref ImVec2 offset /*= ImVec2(0,0)*/);   // Id needs to be < 0x10000 to register a rectangle to map into a specific font.
    const(CustomRect)*   GetCustomRectByIndex(int index) const { if (index < 0) return null; return &CustomRects[index]; }

    // [Internal]
    void      CalcCustomRectUV(const CustomRect* rect, ImVec2* out_uv_min, ImVec2* out_uv_max);
    bool      GetMouseCursorTexData(ImGuiMouseCursor cursor, ImVec2* out_offset, ImVec2* out_size, ImVec2[2] out_uv_border, ImVec2[2] out_uv_fill);

    //-------------------------------------------
    // Members
    //-------------------------------------------

    ImFontAtlasFlags            Flags;              // Build flags (see ImFontAtlasFlags_)
    ImTextureID                 TexID;              // User data to refer to the texture once it has been uploaded to user's graphic systems. It is passed back to you during rendering via the ImDrawCmd structure.
    int                         TexDesiredWidth;    // Texture width desired by user before Build(). Must be a power-of-two. If have many glyphs your graphics API have texture size restrictions you may want to increase texture width to decrease height.
    int                         TexGlyphPadding;    // Padding between glyphs within texture in pixels. Defaults to 1.

    // [Internal]
    // NB: Access texture data via GetTexData*() calls! Which will setup a default font for you.
    ubyte*                      TexPixelsAlpha8;    // 1 component per pixel, each component is unsigned 8-bit. Total size = TexWidth * TexHeight
    uint*                       TexPixelsRGBA32;    // 4 component per pixel, each component is unsigned 8-bit. Total size = TexWidth * TexHeight * 4
    int                         TexWidth;           // Texture width calculated during Build().
    int                         TexHeight;          // Texture height calculated during Build().
    ImVec2                      TexUvScale;         // = (1.0f/TexWidth, 1.0f/TexHeight)
    ImVec2                      TexUvWhitePixel;    // Texture coordinates to a white pixel
    ImVector!(ImFont*)          Fonts;              // Hold all the fonts returned by AddFont*. Fonts[0] is the default font upon calling ImGui::NewFrame(), use ImGui::PushFont()/PopFont() to change the current font.
    ImVector!CustomRect         CustomRects;        // Rectangles for packing custom texture data into the atlas.
    ImVector!ImFontConfig       ConfigData;         // Internal data
    int*                        CustomRectIds;   // Identifiers of custom texture rectangle used by ImFontAtlas/ImDrawList
}

// Font runtime data and rendering
// ImFontAtlas automatically loads a default embedded font for you when you call GetTexDataAsAlpha8() or GetTexDataAsRGBA32().
struct ImFont
{
    // Members: Hot ~62/78 bytes
    float                       FontSize;           // <user set>   // Height of characters, set during loading (don't change after loading)
    float                       Scale;              // = 1.f        // Base font scale, multiplied by the per-window font scale which you can adjust with SetFontScale()
    ImVec2                      DisplayOffset;      // = (0.f,0.f)  // Offset font rendering by xx pixels
    ImVector!ImFontGlyph        Glyphs;             //              // All glyphs.
    ImVector!float              IndexAdvanceX;      //              // Sparse. Glyphs->AdvanceX in a directly indexable way (more cache-friendly, for CalcTextSize functions which are often bottleneck in large UI).
    ImVector!ushort             IndexLookup;        //              // Sparse. Index glyphs by Unicode code-point.
    const(ImFontGlyph)*         FallbackGlyph;      // == FindGlyph(FontFallbackChar)
    float                       FallbackAdvanceX;   // == FallbackGlyph->AdvanceX
    ImWchar                     FallbackChar;       // = '?'        // Replacement glyph if one isn't found. Only set via SetFallbackChar()

    // Members: Cold ~18/26 bytes
    short                       ConfigDataCount;    // ~ 1          // Number of ImFontConfig involved in creating this font. Bigger than 1 when merging multiple font sources into one ImFont.
    ImFontConfig*               ConfigData;         //              // Pointer within ContainerAtlas->ConfigData
    ImFontAtlas*                ContainerAtlas;     //              // What we has been loaded into
    float                       Ascent, Descent;    //              // Ascent: distance from top to bottom of e.g. 'A' [0..FontSize]
    bool                        DirtyLookupTables;
    int                         MetricsTotalSurface;//              // Total surface in pixels to get an idea of the font rasterization/texture cost (not exact, we approximate the cost of padding between glyphs)

    ~this();
}