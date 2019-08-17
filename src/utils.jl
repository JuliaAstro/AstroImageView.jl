function format_header(header::String)
    tmp = ""
    for i in 1:80:length(header)
        tmp *= i+79 < length(header) ? header[i:i+79] : header[i:end]
        tmp *= "\n"
    end
    return tmp
end

function form_image(img::AstroImage, indx::Integer)
    rimg = render(img,indx)
    img24 = Matrix(UInt32[reinterpret(UInt32, convert(RGB24, rimg[i,j])) for i = 1:size(rimg,1), j = size(rimg,2):-1:1]')
    fv = XY(0.0..size(img24,2), 0.0..size(img24,1))
    zr = Signal(ZoomRegion(fv, fv))
    surf = Cairo.CairoRGBSurface(img24)
    
    return fv,zr,surf
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
