module gl3_impl;

import derelict.opengl3.gl3;

import imgui;

/////////////////////////////////
//mixin glDecls!(GLVersion.highestSupported);
//mixin glFuncs!(GLVersion.highestSupported);

//__gshared GLFWwindow* g_Window;
__gshared double g_Time = 0.0;
__gshared const(char)* g_GlslVersion = "#version 150";
__gshared GLuint       g_FontTexture = 0;
__gshared int          g_ShaderHandle = 0, g_VertHandle = 0, g_FragHandle = 0;
__gshared int          g_AttribLocationTex = 0, g_AttribLocationProjMtx = 0;
__gshared int          g_AttribLocationPosition = 0, g_AttribLocationUV = 0, g_AttribLocationColor = 0;
__gshared uint g_VboHandle = 0, g_ElementsHandle = 0;


import core.stdc.stdio;

void ImGui_ImplOpengl3_NewFrame() 
{
	if (!g_FontTexture)
		ImGui_ImplOpengl3_CreateDeviceObjects();
}

void ImGui_ImplOpengl3_RenderDrawData(ImDrawData* draw_data)
{
	// Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
	auto io = &ImGui.GetIO();
	auto ddsize = draw_data.DisplaySize;
	int fb_width = cast(int)(draw_data.DisplaySize.x * io.DisplayFramebufferScale.x);
	int fb_height = cast(int)(draw_data.DisplaySize.y * io.DisplayFramebufferScale.y);
	if (fb_width <= 0 || fb_height <= 0)
		return;
	draw_data.ScaleClipRects(io.DisplayFramebufferScale);

	// Backup GL state
	GLenum last_active_texture; glGetIntegerv(GL_ACTIVE_TEXTURE, cast(GLint*)&last_active_texture);
	glActiveTexture(GL_TEXTURE0);
	GLint last_program; glGetIntegerv(GL_CURRENT_PROGRAM, &last_program);
	GLint last_texture; glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
	GLint last_sampler; glGetIntegerv(GL_SAMPLER_BINDING, &last_sampler);
	GLint last_array_buffer; glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
	GLint last_vertex_array; glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);
	//GLint last_polygon_mode[2]; glGetIntegerv(GL_POLYGON_MODE, last_polygon_mode.ptr);
	GLint[4] last_viewport; glGetIntegerv(GL_VIEWPORT, last_viewport.ptr);
	GLint[4] last_scissor_box; glGetIntegerv(GL_SCISSOR_BOX, last_scissor_box.ptr);
	GLenum last_blend_src_rgb; glGetIntegerv(GL_BLEND_SRC_RGB, cast(GLint*)&last_blend_src_rgb);
	GLenum last_blend_dst_rgb; glGetIntegerv(GL_BLEND_DST_RGB, cast(GLint*)&last_blend_dst_rgb);
	GLenum last_blend_src_alpha; glGetIntegerv(GL_BLEND_SRC_ALPHA, cast(GLint*)&last_blend_src_alpha);
	GLenum last_blend_dst_alpha; glGetIntegerv(GL_BLEND_DST_ALPHA, cast(GLint*)&last_blend_dst_alpha);
	GLenum last_blend_equation_rgb; glGetIntegerv(GL_BLEND_EQUATION_RGB, cast(GLint*)&last_blend_equation_rgb);
	GLenum last_blend_equation_alpha; glGetIntegerv(GL_BLEND_EQUATION_ALPHA, cast(GLint*)&last_blend_equation_alpha);
	GLboolean last_enable_blend = glIsEnabled(GL_BLEND);
	GLboolean last_enable_cull_face = glIsEnabled(GL_CULL_FACE);
	GLboolean last_enable_depth_test = glIsEnabled(GL_DEPTH_TEST);
	GLboolean last_enable_scissor_test = glIsEnabled(GL_SCISSOR_TEST);

	// Setup render state: alpha-blending enabled, no face culling, no depth testing, scissor enabled, polygon fill
	glEnable(GL_BLEND);
	glBlendEquation(GL_FUNC_ADD);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_CULL_FACE);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_SCISSOR_TEST);
	glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

	// Setup viewport, orthographic projection matrix
	// Our visible imgui space lies from draw_data->DisplayPps (top left) to draw_data->DisplayPos+data_data->DisplaySize (bottom right). DisplayMin is typically (0,0) for single viewport apps.
	glViewport(0, 0, cast(GLsizei)fb_width, cast(GLsizei)fb_height);
	float L = draw_data.DisplayPos.x;
	float R = draw_data.DisplayPos.x + draw_data.DisplaySize.x;
	float T = draw_data.DisplayPos.y;
	float B = draw_data.DisplayPos.y + draw_data.DisplaySize.y;
	const float[4][4] ortho_projection =
	[
		[ 2.0f/(R-L),   0.0f,         0.0f,   0.0f ],
		[ 0.0f,         2.0f/(T-B),   0.0f,   0.0f ],
		[ 0.0f,         0.0f,        -1.0f,   0.0f ],
		[ (R+L)/(L-R),  (T+B)/(B-T),  0.0f,   1.0f ],
	];
	glUseProgram(g_ShaderHandle);
	glUniform1i(g_AttribLocationTex, 0);
	glUniformMatrix4fv(g_AttribLocationProjMtx, 1, GL_FALSE, &ortho_projection[0][0]);
	if (glBindSampler) glBindSampler(0, 0); // We use combined texture/sampler state. Applications using GL 3.3 may set that otherwise.

	// Recreate the VAO every time 
	// (This is to easily allow multiple GL contexts. VAO are not shared among GL contexts, and we don't track creation/deletion of windows so we don't have an obvious key to use to cache them.)
	GLuint vao_handle = 0;
	glGenVertexArrays(1, &vao_handle);
	glBindVertexArray(vao_handle);
	glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
	glEnableVertexAttribArray(g_AttribLocationPosition);
	glEnableVertexAttribArray(g_AttribLocationUV);
	glEnableVertexAttribArray(g_AttribLocationColor);
	glVertexAttribPointer(g_AttribLocationPosition, 2, GL_FLOAT, GL_FALSE, ImDrawVert.sizeof, cast(GLvoid*)ImDrawVert.pos.offsetof);
	glVertexAttribPointer(g_AttribLocationUV, 2, GL_FLOAT, GL_FALSE, ImDrawVert.sizeof, cast(GLvoid*)ImDrawVert.uv.offsetof);
	glVertexAttribPointer(g_AttribLocationColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, ImDrawVert.sizeof, cast(GLvoid*)ImDrawVert.col.offsetof);

	// Draw
	ImVec2 pos = draw_data.DisplayPos;
	for (int n = 0; n < draw_data.CmdListsCount; n++)
	{
		const(ImDrawList)* cmd_list = draw_data.CmdLists[n];
		const(ImDrawIdx)* idx_buffer_offset = cast(ImDrawIdx*)0;

		glBindBuffer(GL_ARRAY_BUFFER, g_VboHandle);
		glBufferData(GL_ARRAY_BUFFER, cast(GLsizeiptr)cmd_list.VtxBuffer.Size * ImDrawVert.sizeof, cast(const GLvoid*)cmd_list.VtxBuffer.Data, GL_STREAM_DRAW);

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, g_ElementsHandle);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, cast(GLsizeiptr)cmd_list.IdxBuffer.Size * ImDrawIdx.sizeof, cast(const GLvoid*)cmd_list.IdxBuffer.Data, GL_STREAM_DRAW);

		for (int cmd_i = 0; cmd_i < cmd_list.CmdBuffer.Size; cmd_i++)
		{
			const ImDrawCmd* pcmd = &cmd_list.CmdBuffer[cmd_i];
			if (pcmd.UserCallback)
			{
				// User callback (registered via ImDrawList::AddCallback)
				pcmd.UserCallback(cmd_list, pcmd);
			}
			else
			{
				ImVec4 clip_rect = ImVec4(pcmd.ClipRect.x - pos.x, pcmd.ClipRect.y - pos.y, pcmd.ClipRect.z - pos.x, pcmd.ClipRect.w - pos.y);
				if (clip_rect.x < fb_width && clip_rect.y < fb_height && clip_rect.z >= 0.0f && clip_rect.w >= 0.0f)
				{
					// Apply scissor/clipping rectangle
					glScissor(cast(int)clip_rect.x, cast(int)(fb_height - clip_rect.w), cast(int)(clip_rect.z - clip_rect.x), cast(int)(clip_rect.w - clip_rect.y));

					// Bind texture, Draw
					glBindTexture(GL_TEXTURE_2D, cast(GLuint)cast(intptr_t)pcmd.TextureId);
					glDrawElements(GL_TRIANGLES, cast(GLsizei)pcmd.ElemCount, ImDrawIdx.sizeof == 2 ? GL_UNSIGNED_SHORT : GL_UNSIGNED_INT, cast(void*)idx_buffer_offset);
				}
			}
			idx_buffer_offset += pcmd.ElemCount;
		}
	}
	glDeleteVertexArrays(1, &vao_handle);

	// Restore modified GL state
	glUseProgram(last_program);
	glBindTexture(GL_TEXTURE_2D, last_texture);
	if (glBindSampler) glBindSampler(0, last_sampler);
	glActiveTexture(last_active_texture);
	glBindVertexArray(last_vertex_array);
	glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
	glBlendEquationSeparate(last_blend_equation_rgb, last_blend_equation_alpha);
	glBlendFuncSeparate(last_blend_src_rgb, last_blend_dst_rgb, last_blend_src_alpha, last_blend_dst_alpha);
	if (last_enable_blend) glEnable(GL_BLEND); else glDisable(GL_BLEND);
	if (last_enable_cull_face) glEnable(GL_CULL_FACE); else glDisable(GL_CULL_FACE);
	if (last_enable_depth_test) glEnable(GL_DEPTH_TEST); else glDisable(GL_DEPTH_TEST);
	if (last_enable_scissor_test) glEnable(GL_SCISSOR_TEST); else glDisable(GL_SCISSOR_TEST);
pragma(msg, "FIX ME: ", __FILE__, ":", __LINE__+1, );
    // commented out, latest derelict-gl3 versions doesn't seems to include such deprecated functions by default
	//glPolygonMode(GL_FRONT_AND_BACK, cast(GLenum)last_polygon_mode[0]);  
	glViewport(last_viewport[0], last_viewport[1], cast(GLsizei)last_viewport[2], cast(GLsizei)last_viewport[3]);
	glScissor(last_scissor_box[0], last_scissor_box[1], cast(GLsizei)last_scissor_box[2], cast(GLsizei)last_scissor_box[3]);
}

void ImGui_ImplOpengl3_Shutdown()
{
	ImGui_ImplOpengl3_DestroyDeviceObjects(); 
}

bool ImGui_ImplOpengl3_CreateFontsTexture()
{
	// Build texture atlas
	auto io = &ImGui.GetIO();
	ubyte* pixels;
	int width, height;
	io.Fonts.GetTexDataAsRGBA32(&pixels, &width, &height);   // Load as RGBA 32-bits (75% of the memory is wasted, but default font is so small) because it is more likely to be compatible with user's existing shaders. If your ImTextureId represent a higher-level concept than just a GL texture id, consider calling GetTexDataAsAlpha8() instead to save on GPU memory.

	// Upload texture to graphics system
	GLint last_texture;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
	glGenTextures(1, &g_FontTexture);
	glBindTexture(GL_TEXTURE_2D, g_FontTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

	// Store our identifier
	io.Fonts.TexID = cast(void*)g_FontTexture;

	// Restore state
	glBindTexture(GL_TEXTURE_2D, last_texture);

	return true;
}

void ImGui_ImplOpengl3_DestroyFontsTexture()
{
	if (g_FontTexture)
	{
		auto io = &ImGui.GetIO();
		glDeleteTextures(1, &g_FontTexture);
		io.Fonts.TexID = cast(void*)0;
		g_FontTexture = 0;
	}
}

bool ImGui_ImplOpengl3_CreateDeviceObjects() 
{
	// Backup GL state
	GLint last_texture, last_array_buffer, last_vertex_array;
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &last_texture);
	glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &last_array_buffer);
	glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &last_vertex_array);

	// Create shaders
	static const GLchar* vertex_shader = q{
		uniform mat4 ProjMtx;
		in vec2 Position;
		in vec2 UV;
		in vec4 Color;
		out vec2 Frag_UV;
		out vec4 Frag_Color;
		void main()
		{
			Frag_UV = UV;
			Frag_Color = Color;
			gl_Position = ProjMtx * vec4(Position.xy,0,1);
		}
	};

	static const GLchar* fragment_shader = q{
		uniform sampler2D Texture;
		in vec2 Frag_UV;
		in vec4 Frag_Color;
		out vec4 Out_Color;
		void main()
		{
			Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
		}
	};

	const (GLchar*)[2] vertex_shader_with_version = [ g_GlslVersion, vertex_shader ];
	const (GLchar*)[2] fragment_shader_with_version = [ g_GlslVersion, fragment_shader ];

	g_ShaderHandle = glCreateProgram();
	g_VertHandle = glCreateShader(GL_VERTEX_SHADER);
	g_FragHandle = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(g_VertHandle, 2, vertex_shader_with_version.ptr, null);
	glShaderSource(g_FragHandle, 2, fragment_shader_with_version.ptr, null);
	glCompileShader(g_VertHandle);
	glCompileShader(g_FragHandle);
	glAttachShader(g_ShaderHandle, g_VertHandle);
	glAttachShader(g_ShaderHandle, g_FragHandle);
	glLinkProgram(g_ShaderHandle);

	g_AttribLocationTex = glGetUniformLocation(g_ShaderHandle, "Texture");
	g_AttribLocationProjMtx = glGetUniformLocation(g_ShaderHandle, "ProjMtx");
	g_AttribLocationPosition = glGetAttribLocation(g_ShaderHandle, "Position");
	g_AttribLocationUV = glGetAttribLocation(g_ShaderHandle, "UV");
	g_AttribLocationColor = glGetAttribLocation(g_ShaderHandle, "Color");

	glGenBuffers(1, &g_VboHandle);
	glGenBuffers(1, &g_ElementsHandle);

	ImGui_ImplOpengl3_CreateFontsTexture();

	// Restore modified GL state
	glBindTexture(GL_TEXTURE_2D, last_texture);
	glBindBuffer(GL_ARRAY_BUFFER, last_array_buffer);
	glBindVertexArray(last_vertex_array);

	return true;
}


void ImGui_ImplOpengl3_DestroyDeviceObjects()
{
	if (g_VboHandle) glDeleteBuffers(1, &g_VboHandle);
	if (g_ElementsHandle) glDeleteBuffers(1, &g_ElementsHandle);
	g_VboHandle = g_ElementsHandle = 0;

	if (g_ShaderHandle && g_VertHandle) glDetachShader(g_ShaderHandle, g_VertHandle);
	if (g_VertHandle) glDeleteShader(g_VertHandle);
	g_VertHandle = 0;

	if (g_ShaderHandle && g_FragHandle) glDetachShader(g_ShaderHandle, g_FragHandle);
	if (g_FragHandle) glDeleteShader(g_FragHandle);
	g_FragHandle = 0;

	if (g_ShaderHandle) glDeleteProgram(g_ShaderHandle);
	g_ShaderHandle = 0;

	ImGui_ImplOpengl3_DestroyFontsTexture();
}
