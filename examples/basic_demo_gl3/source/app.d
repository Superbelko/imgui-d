import core.stdc.float_;
import core.stdc.stdlib;
import std.stdio;

import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import imgui;

import glfw_impl;
import gl3_impl;


extern(C) static nothrow void glfw_error_callback(int error, const char* description) 
{
	import core.stdc.stdio : fprintf, stderr;
	fprintf(stderr, "Glfw Error %d: %s\n", error, description);
}

void main()
{
	DerelictGL3.load();
	DerelictGLFW3.load();

	// Setup window
	glfwSetErrorCallback(&glfw_error_callback);
	if (!glfwInit())
		throw new Exception("Unable to initialize GLFW");
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	//glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);

	auto window = glfwCreateWindow(1280, 720, "ImGui GLFW+OpenGL3 example", null, null);
	glfwMakeContextCurrent(window);
	glfwSwapInterval(1); // Enable vsync

	DerelictGL3.reload();


	IMGUI_CHECKVERSION();
	ImGui.CreateContext();
	ImGuiIO* io = &ImGui.GetIO();
	//io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;  // Enable Keyboard Controls
	//io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;   // Enable Gamepad Controls

	ImGui_ImplGlfw_InitOpenGL(window);
	//ImGui_ImplOpenGL_Init();

	// Setup style
	ImGui.StyleColorsDark();
	//ImGui.StyleColorsClassic();

	// this scaling code is not the part of orignal tutorial
	// but I consider this useful so I keep it there for now
	// ---- DPI SCALE 2x
	/*
	auto style = &ImGui.GetStyle();
	style.ScaleAllSizes(2f);

	ImFontConfig cfg;
	float scale = 2.0f;
	cfg.SizePixels = 13f * scale;
	io.Fonts.AddFontDefault(&cfg).DisplayOffset.y = scale;
	*/
	// ----------------

	// Load Fonts
	// - If no fonts are loaded, dear imgui will use the default font. You can also load multiple fonts and use ImGui::PushFont()/PopFont() to select them. 
	// - AddFontFromFileTTF() will return the ImFont* so you can store it if you need to select the font among multiple. 
	// - If the file cannot be loaded, the function will return NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
	// - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling ImFontAtlas::Build()/GetTexDataAsXXXX(), which ImGui_ImplXXXX_NewFrame below will call.
	// - Read 'misc/fonts/README.txt' for more instructions and details.
	// - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
	//auto font = io.Fonts.AddFontDefault();
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf", 15.0f);
	//io.Fonts.AddFontFromFileTTF("misc/fonts/DroidSans.ttf", 16.0f);
	//io.Fonts->AddFontFromFileTTF("../../misc/fonts/ProggyTiny.ttf", 10.0f);
	//ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf", 18.0f, NULL, io.Fonts->GetGlyphRangesJapanese());
	//IM_ASSERT(font != NULL);

	//ubyte* pixels; 
	//int width, height, bytes_per_pixels;
	//io.Fonts.GetTexDataAsRGBA32(&pixels, &width, &height, &bytes_per_pixels);
	//ImGui.PushFont(font);

	bool show_demo_window = true;
	bool show_another_window = false;
	auto clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
	
	// Main loop
	while (!glfwWindowShouldClose(window))
	{
		// Poll and handle events (inputs, window resize, etc.)
		// You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
		// - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
		// - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
		// Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
		glfwPollEvents();

		// Start the ImGui frame
		ImGui_ImplOpengl3_NewFrame();
		ImGui_ImplGlfw_NewFrame();
		ImGui.NewFrame();
		

		// 1. Show a simple window.
		// Tip: if we don't call ImGui::Begin()/ImGui::End() the widgets automatically appears in a window called "Debug".
		{
			static float scale = 1f;
			static float f = 0.0f;
			static int counter = 0;
			static int item;
			ImGui.Text("Hello, world!");                           // Display some text (you can use a format string too)
			ImGui.SliderFloat("float", &f, 0.0f, 1.0f);            // Edit 1 float using a slider from 0.0f to 1.0f    
			ImGui.ColorEdit3("clear color", cast(float*)&clear_color); // Edit 3 floats representing a color

			ImGui.Checkbox("Demo Window", &show_demo_window);      // Edit bools storing our windows open/close state
			ImGui.Checkbox("Another Window", &show_another_window);

			if (ImGui.Button("Button"))                            // Buttons return true when clicked (NB: most widgets return true when edited/activated)
				counter++;
			ImGui.SameLine();
			ImGui.Text("counter = %d", counter);

			ImGui.Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui.GetIO().Framerate, ImGui.GetIO().Framerate);
		}

		// 2. Show another simple window. In most cases you will use an explicit Begin/End pair to name your windows.
		if (show_another_window)
		{
			ImGui.Begin("Another Window", &show_another_window);
			ImGui.Text("Hello from another window!");
			if (ImGui.Button("Close Me"))
				show_another_window = false;
			ImGui.End();
		}

		// 3. Show the ImGui demo window. Most of the sample code is in ImGui::ShowDemoWindow(). Read its code to learn more about Dear ImGui!
		if (show_demo_window)
		{
			static auto pos = ImVec2(650, 20);
			ImGui.SetNextWindowPos(pos, ImGuiCond_FirstUseEver); // Normally user code doesn't need/want to call this because positions are saved in .ini file anyway. Here we just want to make the demo initial state a bit more friendly!
			ImGui.ShowDemoWindow(&show_demo_window);
		}

		// Rendering
		ImGui.Render();
		int display_w, display_h;
		glfwMakeContextCurrent(window);
		glfwGetFramebufferSize(window, &display_w, &display_h);
		glViewport(0, 0, display_w, display_h);
		glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
		glClear(GL_COLOR_BUFFER_BIT);
		ImGui_ImplOpengl3_RenderDrawData(ImGui.GetDrawData());

		glfwMakeContextCurrent(window);
		glfwSwapBuffers(window);
	}

	// Cleanup
	ImGui_ImplOpengl3_Shutdown();
	ImGui_ImplGlfw_Shutdown();
	ImGui.DestroyContext();
}



