const eidx = 30

```
    ui_advanced(img::AstroImage, indx::Int = 1)

Opens an advanced GUI panel to visualize AstroImages.
```
function ui_advanced(img::AstroImage, indx::Int = 1)              # 3 X eidx grid
    win = Window("Image", 700,700, border_width = 5) 
    g = Grid()
    set_gtk_property!(g, :column_homogeneous, true)
    set_gtk_property!(g, :column_spacing, 15)  
    push!(win, g)
    img_labels = Array{Tuple{Tuple{Real,Real},String},1}(undef,0)
    
    # Sets toolbar widget
    toolbar = Toolbar()
    headerbtn = get_button("Header")
    closebtn = get_button("Close")
    labelbtn = get_button("Show Labels")
    savebtn = get_button("Save")
    resetbtn = get_button("Reset")
    map(w->push!(toolbar,w),[headerbtn, labelbtn, savebtn,resetbtn, closebtn])
    g[1:3,1] = toolbar
    
    # Create canvas to display image
    c = canvas(UserUnit)
    g[1:2,2:eidx-3] = c
    set_gtk_property!(c, :expand, true)
    
    if(length(img) > 1)
        g[3,6] = get_label("AstroImage index-> 1:"* string.(length(img)))
        g[3,7] = GtkEntry()
        g[3,8] = GtkButton("Change Index")
    end
    
    # Image Label widgets
    g[3,9] = get_label("Pixel Coordinate X")
    g[3,10] = GtkEntry()
    g[3,11]= get_label("Pixel Coordinate Y")
    g[3,12]= GtkEntry()
    g[3,13]= get_label("Label")
    g[3,14]= GtkEntry()
    g[3,15]= GtkButton("Add Label")
        
    # Sets labels showing informations
    g[1,eidx-2] = get_label("Physical Coordinate X =")
    g[2,eidx-2] = get_label("Physical Coordinate Y =")
    g[1,eidx-1] = get_label("World Coordinate X =")
    g[2,eidx-1] = get_label("World Coordinate Y =")
    g[1:2,eidx] = get_label("Value = ")
    g[3,eidx] = get_label("Tip: Ctrl+Scroll to zoom")
    
    fv,zr,surf = form_image(img, indx)
    
    # interactive signals
    init_zoom_scroll(c,zr)                     # Makes canvas scrollable
    close_window(closebtn, win)                # Handles close button
    draw_canvas(c,zr,surf)                     # Draws canvas on window
    
    # Mapping mouse motion
    map(c.mouse.motion) do btn
        xu, yu = btn.position.x.val, btn.position.y.val
        world_coord = pix_to_world(img.wcs[indx], [xu, yu])
        GAccessor.text(g[1,eidx-2] ,"Pixel Coordinate X = $(round(xu, digits = 2))")
        GAccessor.text(g[2,eidx-2] ,"Pixel Coordinate Y = $(round(yu, digits = 2))")
        GAccessor.text(g[1,eidx-1] ,"World Coordinate X = $(round(world_coord[1], digits = 2))"*"°")
        GAccessor.text(g[2,eidx-1] ,"World Coordinate Y = $(round(world_coord[2], digits = 2))"*"°")
        if xu >= 1 && yu >= 1
            GAccessor.text(g[1,eidx] ,"Value = $(img.data[indx][Int(round(xu)),Int(round(yu))])")
        else
            GAccessor.text(g[1,eidx] , "Value = ")
        end
    end
    
    # Handles label adding
    signal_connect(g[3,15], :clicked) do btn   
        x = parse(Float64, get_gtk_property(g[3,10], :text, String))
        y = parse(Float64, get_gtk_property(g[3,12], :text, String))
        label = get_gtk_property(g[3,14], :text, String)
        push!(img_labels, ((x,y), label))
        set_gtk_property!(g[3,10], :text, "")
        set_gtk_property!(g[3,12], :text, "")
        set_gtk_property!(g[3,14], :text, "")
    end
    
    # Handles index changing
    if(length(img) > 1)
        signal_connect(g[3,8], :clicked) do btn     
            tmp = parse(Int, get_gtk_property(g[3,7], :text, String))
            if tmp <= length(img)
                indx = tmp
                set_gtk_property!(g[3,7], :text, "")
                fv,zr,surf = form_image(img, indx)
                draw_canvas(c,zr,surf) 
                map(c.mouse.motion) do btn
                    xu, yu = btn.position.x.val, btn.position.y.val
                    world_coord = pix_to_world(img.wcs[indx], [xu, yu])
                    GAccessor.text(g[1,eidx-2] ,"Pixel Coordinate X = $(round(xu, digits = 2))")
                    GAccessor.text(g[2,eidx-2] ,"Pixel Coordinate Y = $(round(yu, digits = 2))")
                    GAccessor.text(g[1,eidx-1] ,"World Coordinate X = $(round(world_coord[1], digits = 2))"*"°")
                    GAccessor.text(g[2,eidx-1] ,"World Coordinate Y = $(round(world_coord[2], digits = 2))"*"°")
                    if xu >= 1 && yu >= 1
                        GAccessor.text(g[1,eidx] ,"Value = $(img.data[indx][Int(round(xu)),Int(round(yu))])")
                    else
                        GAccessor.text(g[1,eidx] , "Value = ")
                    end
                end
                init_zoom_scroll(c,zr)
            else
                set_gtk_property!(g[3,7], :text, "Set index within bound")
            end
        end  
    end
    
    # Handles header showing
    signal_connect(headerbtn, :clicked) do widget       
        showall(header_window(img.wcs[indx]))
    end
    
    # Handles Label showing
    signal_connect(labelbtn, :clicked) do widget       
        showall(label_window(img_labels))
    end
    
    # Handles reset button
    signal_connect(resetbtn, :clicked) do widget       
        img_labels = Array{Tuple{Tuple{Real,Real},String},1}(undef,0)
    end
    
    showall(win)
end