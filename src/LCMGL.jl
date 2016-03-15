module LCMGL

import Base: unsafe_convert
export LCM, LCMGLClient,
	GLConstant,
	switch_buffer,
	vertex,
	color,
	gl_begin,
	gl_end,
	sphere

POINTS         = 0x0000
LINES          = 0x0001
LINE_LOOP      = 0x0002
LINE_STRIP     = 0x0003
TRIANGLES      = 0x0004
TRIANGLE_STRIP = 0x0005
TRIANGLE_FAN   = 0x0006
QUADS          = 0x0007
QUAD_STRIP     = 0x0008
POLYGON        = 0x0009


type LCM
    pointer::Ptr{Void}
    
    LCM() = begin
        lc = new(ccall((:lcm_create, "liblcm"), Ptr{Void}, (Ptr{UInt8},), ""))
        finalizer(lc, x -> begin
            ccall((:lcm_destroy, "liblcm"), Void, (Ptr{Void},), x)
            end)
        lc
    end
end
unsafe_convert(::Type{Ptr{Void}}, lc::LCM) = lc.pointer

type LCMGLClient
    lcm::LCM
    pointer::Ptr{Void}
    
    LCMGLClient(lcm::LCM, name::AbstractString) = begin
        gl = new(lcm, 
            ccall((:bot_lcmgl_init, "libbot2-lcmgl-client"), Ptr{Void}, (Ptr{Void}, Ptr{UInt8}), lcm, name))
        finalizer(gl, x -> begin
            ccall((:bot_lcmgl_destroy, "libbot2-lcmgl-client"), Void, (Ptr{Void},), x)
            end)
        gl
    end
end
unsafe_convert(::Type{Ptr{Void}}, gl::LCMGLClient) = gl.pointer

LCMGLClient(name::AbstractString) = LCMGLClient(LCM(), name)

LCMGLClient(func::Function, name::AbstractString) = begin
    gl = LCMGLClient(name)
    try
        func(gl)
    finally
        finalize(gl.lcm)
        finalize(gl)
    end
end

LCMGLClient(func::Function, lcm::LCM, name::AbstractString) = begin
    gl = LCMGLClient(lcm, name)
    try
        func(gl)
    finally
        finalize(gl)
    end
end

sphere(gl::LCMGLClient, origin, radius, slices, stacks) = ccall((:bot_lcmgl_sphere, "libbot2-lcmgl-client"), 
    Void, (Ptr{Void}, Ptr{Cdouble}, Cdouble, Cint, Cint), gl, origin, radius, slices, stacks)

switch_buffer(gl::LCMGLClient) = ccall((:bot_lcmgl_switch_buffer, "libbot2-lcmgl-client"), Void, (Ptr{Void},), gl)

color(gl::LCMGLClient, red, green, blue) = ccall((:bot_lcmgl_color3f, "libbot2-lcmgl-client"), 
    Void, (Ptr{Void}, Cfloat, Cfloat, Cfloat), gl.pointer, red, green, blue)
color(gl::LCMGLClient, red, green, blue, alpha) = ccall((:bot_lcmgl_color4f, "libbot2-lcmgl-client"), 
    Void, (Ptr{Void}, Cfloat, Cfloat, Cfloat, Cfloat), gl.pointer, red, green, blue, alpha)

vertex(gl::LCMGLClient, x, y) = ccall((:bot_lcmgl_vertex2d, "libbot2-lcmgl-client"), Void, (Ptr{Void}, Cdouble, Cdouble), gl, x, y)
vertex(gl::LCMGLClient, x, y, z) = ccall((:bot_lcmgl_vertex3d, "libbot2-lcmgl-client"), Void, (Ptr{Void}, Cdouble, Cdouble, Cdouble), gl, x, y, z)

gl_begin(gl::LCMGLClient, mode::Integer) = ccall((:bot_lcmgl_begin, "libbot2-lcmgl-client"), Void, (Ptr{Void}, Cuint), gl, mode)
gl_end(gl::LCMGLClient) = ccall((:bot_lcmgl_end, "libbot2-lcmgl-client"), Void, (Ptr{Void},), gl)

end
    
import LCMGL