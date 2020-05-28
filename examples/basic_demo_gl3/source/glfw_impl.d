module glfw_impl;

import core.stdc.string;
import std.string;

import bindbc.glfw;

import imgui;
import core.stdc.float_;

static GLFWwindow*      g_Window = null;
//static GlfwClientApi    g_ClientApi = GlfwClientApi_Unknown;
static double           g_Time = 0.0;
static bool[5]          g_MouseJustPressed;
static GLFWcursor*[ImGuiMouseCursor_COUNT]      g_MouseCursors;

void ImGui_ImplGlfw_InitOpenGL(GLFWwindow* window)
{
	g_Window = window;

    // Setup back-end capabilities flags
    auto io = &ImGui.GetIO();
    io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;         // We can honor GetMouseCursor() values (optional)
    io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)

    // Keyboard mapping. ImGui will use those indices to peek into the io.KeysDown[] array.
    io.KeyMap[ImGuiKey_Tab] = GLFW_KEY_TAB;
    io.KeyMap[ImGuiKey_LeftArrow] = GLFW_KEY_LEFT;
    io.KeyMap[ImGuiKey_RightArrow] = GLFW_KEY_RIGHT;
    io.KeyMap[ImGuiKey_UpArrow] = GLFW_KEY_UP;
    io.KeyMap[ImGuiKey_DownArrow] = GLFW_KEY_DOWN;
    io.KeyMap[ImGuiKey_PageUp] = GLFW_KEY_PAGE_UP;
    io.KeyMap[ImGuiKey_PageDown] = GLFW_KEY_PAGE_DOWN;
    io.KeyMap[ImGuiKey_Home] = GLFW_KEY_HOME;
    io.KeyMap[ImGuiKey_End] = GLFW_KEY_END;
    io.KeyMap[ImGuiKey_Insert] = GLFW_KEY_INSERT;
    io.KeyMap[ImGuiKey_Delete] = GLFW_KEY_DELETE;
    io.KeyMap[ImGuiKey_Backspace] = GLFW_KEY_BACKSPACE;
    io.KeyMap[ImGuiKey_Space] = GLFW_KEY_SPACE;
    io.KeyMap[ImGuiKey_Enter] = GLFW_KEY_ENTER;
    io.KeyMap[ImGuiKey_Escape] = GLFW_KEY_ESCAPE;
    io.KeyMap[ImGuiKey_A] = GLFW_KEY_A;
    io.KeyMap[ImGuiKey_C] = GLFW_KEY_C;
    io.KeyMap[ImGuiKey_V] = GLFW_KEY_V;
    io.KeyMap[ImGuiKey_X] = GLFW_KEY_X;
    io.KeyMap[ImGuiKey_Y] = GLFW_KEY_Y;
    io.KeyMap[ImGuiKey_Z] = GLFW_KEY_Z;

    io.SetClipboardTextFn = &ImGui_ImplGlfw_SetClipboardText;
    io.GetClipboardTextFn = &ImGui_ImplGlfw_GetClipboardText;
    io.ClipboardUserData = g_Window;

version(Window)
    io.ImeWindowHandle = cast(void*)glfwGetWin32Window(g_Window);

    g_MouseCursors[ImGuiMouseCursor_Arrow] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);
    g_MouseCursors[ImGuiMouseCursor_TextInput] = glfwCreateStandardCursor(GLFW_IBEAM_CURSOR);
    g_MouseCursors[ImGuiMouseCursor_ResizeAll] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);   // FIXME: GLFW doesn't have this.
    g_MouseCursors[ImGuiMouseCursor_ResizeNS] = glfwCreateStandardCursor(GLFW_VRESIZE_CURSOR);
    g_MouseCursors[ImGuiMouseCursor_ResizeEW] = glfwCreateStandardCursor(GLFW_HRESIZE_CURSOR);
    g_MouseCursors[ImGuiMouseCursor_ResizeNESW] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);  // FIXME: GLFW doesn't have this.
    g_MouseCursors[ImGuiMouseCursor_ResizeNWSE] = glfwCreateStandardCursor(GLFW_ARROW_CURSOR);  // FIXME: GLFW doesn't have this.

    ImGui_ImplGlfw_InstallCallbacks(window);
}

extern(C++) static const(char)* ImGui_ImplGlfw_GetClipboardText(void* user_data)
{
    return glfwGetClipboardString(cast(GLFWwindow*)user_data);
}

extern(C++) static void ImGui_ImplGlfw_SetClipboardText(void* user_data, const(char)* text)
{
    glfwSetClipboardString(cast(GLFWwindow*)user_data, text);
}

extern(C) nothrow
{
void ImGui_ImplGlfw_MouseButtonCallback(GLFWwindow*, int button, int action, int /*mods*/)
{
    if (action == GLFW_PRESS && button >= 0 && button < g_MouseJustPressed.length)
        g_MouseJustPressed[button] = true;
}

void ImGui_ImplGlfw_ScrollCallback(GLFWwindow*, double xoffset, double yoffset)
{
    auto io = &ImGui.GetIO();
    io.MouseWheelH += cast(float)xoffset;
    io.MouseWheel += cast(float)yoffset;
}

void ImGui_ImplGlfw_KeyCallback(GLFWwindow*, int key, int, int action, int mods)
{
    auto io = &ImGui.GetIO();
    if (action == GLFW_PRESS)
        io.KeysDown[key] = true;
    if (action == GLFW_RELEASE)
        io.KeysDown[key] = false;

    //(void)mods; // Modifiers are not reliable across systems
    io.KeyCtrl = io.KeysDown[GLFW_KEY_LEFT_CONTROL] || io.KeysDown[GLFW_KEY_RIGHT_CONTROL];
    io.KeyShift = io.KeysDown[GLFW_KEY_LEFT_SHIFT] || io.KeysDown[GLFW_KEY_RIGHT_SHIFT];
    io.KeyAlt = io.KeysDown[GLFW_KEY_LEFT_ALT] || io.KeysDown[GLFW_KEY_RIGHT_ALT];
    io.KeySuper = io.KeysDown[GLFW_KEY_LEFT_SUPER] || io.KeysDown[GLFW_KEY_RIGHT_SUPER];
}

void ImGui_ImplGlfw_CharCallback(GLFWwindow*, uint c)
{
    try {
        auto io = &ImGui.GetIO();
        if (c > 0 && c < 0x10000)
            io.AddInputCharacter(cast(ushort)c);
    }
    catch (Exception e)
    {
        import core.stdc.stdio : printf;
        printf("%s", toStringz(e.msg) );
    }
}
}

static void ImGui_ImplGlfw_UpdateMousePosAndButtons()
{
    // Update buttons
    auto io = &ImGui.GetIO();
    for (int i = 0; i < io.MouseDown.length; i++)
    {
        // If a mouse press event came, always pass it as "mouse held this frame", so we don't miss click-release events that are shorter than 1 frame.
        io.MouseDown[i] = g_MouseJustPressed[i] || glfwGetMouseButton(g_Window, i) != 0;
        g_MouseJustPressed[i] = false;
    }

    // Update mouse position
    const ImVec2 mouse_pos_backup = io.MousePos;
    io.MousePos = ImVec2(-FLT_MAX, -FLT_MAX);
    if (glfwGetWindowAttrib(g_Window, GLFW_FOCUSED))
    {
        if (io.WantSetMousePos)
        {
            glfwSetCursorPos(g_Window, cast(double)mouse_pos_backup.x, cast(double)mouse_pos_backup.y);
        }
        else
        {
            double mouse_x, mouse_y;
            glfwGetCursorPos(g_Window, &mouse_x, &mouse_y);
            io.MousePos = ImVec2(cast(float)mouse_x, cast(float)mouse_y);
        }
    }
}

static void ImGui_ImplGlfw_UpdateMouseCursor()
{
    auto io = &ImGui.GetIO();
    if ((io.ConfigFlags & ImGuiConfigFlags_NoMouseCursorChange) || glfwGetInputMode(g_Window, GLFW_CURSOR) == GLFW_CURSOR_DISABLED)
        return;

    ImGuiMouseCursor imgui_cursor = ImGui.GetMouseCursor();
    if (imgui_cursor == ImGuiMouseCursor_None || io.MouseDrawCursor)
    {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        glfwSetInputMode(g_Window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
    }
    else
    {
        // Show OS mouse cursor
        // FIXME-PLATFORM: Unfocused windows seems to fail changing the mouse cursor with GLFW 3.2, but 3.3 works here.
        glfwSetCursor(g_Window, g_MouseCursors[imgui_cursor] ? g_MouseCursors[imgui_cursor] : g_MouseCursors[ImGuiMouseCursor_Arrow]);
        glfwSetInputMode(g_Window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
    }
}

void ImGui_ImplGlfw_InstallCallbacks(GLFWwindow* window)
{
    glfwSetKeyCallback(window, &ImGui_ImplGlfw_KeyCallback);
    glfwSetCharCallback(window, &ImGui_ImplGlfw_CharCallback);
    glfwSetScrollCallback(window, &ImGui_ImplGlfw_ScrollCallback);
    glfwSetMouseButtonCallback(window, &ImGui_ImplGlfw_MouseButtonCallback);
}


void ImGui_ImplGlfw_NewFrame() 
{
	auto io = &ImGui.GetIO();
	assert(io.Fonts.IsBuilt());     // Font atlas needs to be built, call renderer _NewFrame() function e.g. ImGui_ImplOpenGL3_NewFrame() 

	// Setup display size
	int w, h;
	int display_w, display_h;
	glfwGetWindowSize(g_Window, &w, &h);
	glfwGetFramebufferSize(g_Window, &display_w, &display_h);
	io.DisplaySize = ImVec2(cast(float)w, cast(float)h);
	io.DisplayFramebufferScale = ImVec2(w > 0 ? (cast(float)display_w / w) : 0, h > 0 ? (cast(float)display_h / h) : 0);

	// Setup time step
	double current_time = glfwGetTime();
	io.DeltaTime = g_Time > 0.0 ? cast(float)(current_time - g_Time) : cast(float)(1.0f/60.0f);
	g_Time = current_time;

	ImGui_ImplGlfw_UpdateMousePosAndButtons();
	ImGui_ImplGlfw_UpdateMouseCursor();

	// Gamepad navigation mapping [BETA]
	memset(io.NavInputs.ptr, 0, io.NavInputs.sizeof);
	if (io.ConfigFlags & ImGuiConfigFlags_NavEnableGamepad)
	{
		int axes_count = 0, buttons_count = 0;
        /*
		// Update gamepad inputs
		void MAP_BUTTON(int NAV_NO, int BUTTON_NO) { if (buttons_count > BUTTON_NO && buttons[BUTTON_NO] == GLFW_PRESS) io.NavInputs[NAV_NO] = 1.0f; }
		void MAP_ANALOG(int NAV_NO, int AXIS_NO, float V0, float V1) { float v = (axes_count > AXIS_NO) ? axes[AXIS_NO] : V0; v = (v - V0) / (V1 - V0); if (v > 1.0f) v = 1.0f; if (io.NavInputs[NAV_NO] < v) io.NavInputs[NAV_NO] = v; }
		const(float)* axes = glfwGetJoystickAxes(GLFW_JOYSTICK_1, &axes_count);
		const ubyte* buttons = glfwGetJoystickButtons(GLFW_JOYSTICK_1, &buttons_count);
		MAP_BUTTON(ImGuiNavInput_Activate,   0);     // Cross / A
		MAP_BUTTON(ImGuiNavInput_Cancel,     1);     // Circle / B
		MAP_BUTTON(ImGuiNavInput_Menu,       2);     // Square / X
		MAP_BUTTON(ImGuiNavInput_Input,      3);     // Triangle / Y
		MAP_BUTTON(ImGuiNavInput_DpadLeft,   13);    // D-Pad Left
		MAP_BUTTON(ImGuiNavInput_DpadRight,  11);    // D-Pad Right
		MAP_BUTTON(ImGuiNavInput_DpadUp,     10);    // D-Pad Up
		MAP_BUTTON(ImGuiNavInput_DpadDown,   12);    // D-Pad Down
		MAP_BUTTON(ImGuiNavInput_FocusPrev,  4);     // L1 / LB
		MAP_BUTTON(ImGuiNavInput_FocusNext,  5);     // R1 / RB
		MAP_BUTTON(ImGuiNavInput_TweakSlow,  4);     // L1 / LB
		MAP_BUTTON(ImGuiNavInput_TweakFast,  5);     // R1 / RB
		MAP_ANALOG(ImGuiNavInput_LStickLeft, 0,  -0.3f,  -0.9f);
		MAP_ANALOG(ImGuiNavInput_LStickRight,0,  +0.3f,  +0.9f);
		MAP_ANALOG(ImGuiNavInput_LStickUp,   1,  +0.3f,  +0.9f);
		MAP_ANALOG(ImGuiNavInput_LStickDown, 1,  -0.3f,  -0.9f);
        */

		if (axes_count > 0 && buttons_count > 0)
			io.BackendFlags |= ImGuiBackendFlags_HasGamepad;
		else
			io.BackendFlags &= ~ImGuiBackendFlags_HasGamepad;
	}
	
}


void ImGui_ImplGlfw_Shutdown()
{
    glfwDestroyWindow(g_Window);
	glfwTerminate();
}