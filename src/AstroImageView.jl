module AstroImageView

using AstroImages, GtkReactive, Gtk.ShortNames, Graphics, Gtk, Colors, IntervalSets, Cairo
using AstroImages: render
using WCS, FITSIO

export ui_basic

function format_header(header::String)
    tmp = ""
    for i in 1:80:length(header)
        tmp *= i+79 < length(header) ? header[i:i+79] : header[i:end]
        tmp *= "\n"
    end
    return tmp
end

function get_button(name::String)
    btn =  ToolButton(name)
    set_gtk_property!(btn, :label, name)
    set_gtk_property!(btn, :is_important, true)
    return btn
end

get_label(name::String) = Label(name)

function header_window(header::WCSTransform)
    header = WCS.to_header(header)
    new_win = Window("Header",600,500)
    txt = get_label("Header")
    push!(new_win,txt)
    set_gtk_property!(txt, :label, format_header(header))
    return new_win  
end

function close_window(closebtn::GtkToolButtonLeaf, win::GtkWindow)
    signal_connect(closebtn, :clicked) do widget
       destroy(win) 
    end
end

function draw_canvas(c::GtkReactive.Canvas{UserUnit}, zr::Signal,surf::Cairo.CairoSurfaceImage)
   draw(c, zr) do widget, r
        ctx = getgc(widget)
        set_coordinates(ctx, r)
        rectangle(ctx, BoundingBox(r.currentview))
        set_source(ctx, surf)
        fill(ctx)
        end 
end
function map_mouse_motion(img::AstroImage, indx::Int, c::GtkReactive.Canvas{UserUnit}, g::GtkGrid, header::WCSTransform)
    map(c.mouse.motion) do btn
        xu, yu = btn.position.x.val, btn.position.y.val
        world_coord = pix_to_world(header, [xu, yu])
        GAccessor.text(g[1,3] ,"Pixel Coordinate X = $(round(xu, digits = 2))")
        GAccessor.text(g[2,3] ,"Pixel Coordinate Y = $(round(yu, digits = 2))")
        GAccessor.text(g[1,4] ,"World Coordinate X = $(round(world_coord[1], digits = 2))"*"°")
        GAccessor.text(g[2,4] ,"World Coordinate Y = $(round(world_coord[2], digits = 2))"*"°")
        if xu >= 1 && yu >= 1 
            GAccessor.text(g[1,5] ,"Value = $(img.data[indx][Int(round(xu)),Int(round(yu))])")
        else
            GAccessor.text(g[1,5] , "Value = ")
        end
    end
end

function ui_basic(img::AstroImage, indx::Int = 1)
    header = img.wcs[indx]
    win = Window("Image", 700,700) 
    g = Grid()
    set_gtk_property!(g, :column_homogeneous, true)
    set_gtk_property!(g, :column_spacing, 15)  
    push!(win, g)
    
    toolbar = Toolbar()
    headerbtn = get_button("Header")
    closebtn = get_button("Close")
    map(w->push!(toolbar,w),[headerbtn,closebtn])
    g[1:2,1] = toolbar
    
    # Sets labels showing informations
    g[1,3] = get_label("Physical Coordinate X =")
    g[2,3] = get_label("Physical Coordinate Y =")
    g[1,4] = get_label("World Coordinate X =")
    g[2,4] = get_label("World Coordinate Y =")
    g[1:2,5] = get_label("Value = ")
    
    c = canvas(UserUnit)
    g[1:2,2] = c
    set_gtk_property!(c, :expand, true)

    rimg = render(img)
    img24 = Matrix(UInt32[reinterpret(UInt32, convert(RGB24, rimg[i,j])) for i = 1:size(rimg,1), j = size(rimg,2):-1:1]')
    fv = XY(0.0..size(img24,2), 0.0..size(img24,1))
    zr = Signal(ZoomRegion(fv, fv))
    surf = Cairo.CairoRGBSurface(img24)
    
    # interactive signals
    signal_connect(headerbtn, :clicked) do widget
        showall(header_window(header))
    end
    close_window(closebtn, win)
    map_mouse_motion(img, indx, c, g, header)
    draw_canvas(c,zr,surf)
    
    showall(win)
end

end # module
