```
    ui_basic(img::AstroImage, indx::Int = 1)

Opens a basic GUI panel to visualize AstroImages.
```
function ui_basic(img::AstroImage, indx::Int = 1)
    header = img.wcs[indx]
    win = Window("Image", 700,700) 
    g = Grid()
    set_gtk_property!(g, :column_homogeneous, true)
    set_gtk_property!(g, :column_spacing, 15)  
    push!(win, g)
    
    # Sets toolbar widget
    toolbar = Toolbar()
    headerbtn = get_button("Header")
    closebtn = get_button("Close")
    map(w->push!(toolbar,w),[headerbtn,closebtn])
    g[1:2,1] = toolbar

    # Create canvas to display image
    c = canvas(UserUnit)
    g[1:2,2] = c
    set_gtk_property!(c, :expand, true)
    fv,zr,surf = form_image(img, indx)
    
    # Sets labels showing informations
    g[1,3] = get_label("Physical Coordinate X =")
    g[2,3] = get_label("Physical Coordinate Y =")
    g[1,4] = get_label("World Coordinate X =")
    g[2,4] = get_label("World Coordinate Y =")
    g[1:2,5] = get_label("Value = ")
    
    # interactive signals
    signal_connect(headerbtn, :clicked) do widget
        showall(header_window(header))
    end
    init_zoom_scroll(c,zr)
    close_window(closebtn, win)
    map_mouse_motion(img, indx, c, g, header)
    draw_canvas(c,zr,surf)
    
    showall(win)
end
