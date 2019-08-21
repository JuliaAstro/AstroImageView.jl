using AstroImageView
using AstroImageView: get_label, get_button, format_header, header_window, format_label, label_window
using AstroImages, GtkReactive, Gtk.ShortNames, Graphics, Gtk, Colors, IntervalSets, Cairo
using AstroImages: render
using WCS, FITSIO
using Test

@testset "labels" begin
    label = get_label("test")
    @test label isa GtkLabelLeaf
    @test get_gtk_property(label, :label, String) == "test"
end

@testset "butttons" begin
    btn = get_button("test")
    @test btn isa GtkToolButtonLeaf
    @test get_gtk_property(btn, :label, String) == "test"
    @test get_gtk_property(btn, :is_important, Bool) == true
end

@testset "format header" begin
    str = "testing the behaviour at line length 80 testing the behaviour at line length 80 testing the behaviour at line length 80 testing the behaviour at line length 80 testing the behaviour at line length 80 testing the behaviour at line length 80 "
    answer = "testing the behaviour at line length 80 testing the behaviour at line length 80 \ntesting the behaviour at line length 80 testing the behaviour at line length 80 \ntesting the behaviour at line length 80 testing the behaviour at line length 80 \n"
    @test answer == format_header(str)
end

@testset "header window" begin
    win = header_window(WCSTransform(2;))
    @test win isa GtkWindowLeaf
    @test win.txt isa Gtk.GLib.FieldRef{GtkWindowLeaf}
    @test get_gtk_property(win, :title, String) == "Header"
    @test get_gtk_property(win, :default_height, Int) == 500
    @test get_gtk_property(win, :default_width, Int) == 600
    destroy(win)
end

@testset "labels" begin
    img_labels = [((12.0,32.2), "This is a test label 1"), ((12.3,12.5), "This is a test label 2")]
    @test format_label(img_labels[1]) == ". (12.0,32.2)\tThis is a test label 1"
    
    win = label_window(img_labels)
    @test win isa GtkWindowLeaf
    @test win.txt isa Gtk.GLib.FieldRef{GtkWindowLeaf}
    @test get_gtk_property(win, :title, String) == "Labels"
    @test get_gtk_property(win, :default_height, Int) == 500
    @test get_gtk_property(win, :default_width, Int) == 600
    destroy(win)
end

@testset "basic panel" begin
    fname = tempname() * ".fits"
    inhdr = FITSHeader(["CTYPE1", "CTYPE2", "RADESYS", "FLTKEY", "INTKEY", "BOOLKEY", "STRKEY", "COMMENT",
                        "HISTORY"],
                       ["RA---TAN", "DEC--TAN", "UNK", 1.0, 1, true, "string value", nothing, nothing],
                       ["",
                        "",
                        "",
                        "floating point keyword",
                        "",
                        "boolean keyword",
                        "string value",
                        "this is a comment",
                        "this is a history"])

    indata = reshape(Float32[1:100;], 5, 20)
    FITS(fname, "w") do f
        write(f, indata; header=inhdr)
        write(f, indata; header=inhdr)
    end
    img = AstroImage(fname, (1,2))

    basic_ui = ui_basic(img)
    @test basic_ui isa GtkWindowLeaf
    @test get_gtk_property(basic_ui, :title, String) == "Image"
    @test basic_ui.g isa Gtk.GLib.FieldRef{GtkWindowLeaf}
    @test get_gtk_property(basic_ui, :default_height, Int) == 700
    @test get_gtk_property(basic_ui, :default_width, Int) == 700

    rm(fname, force = true)
    destroy(basic_ui)
end

@testset "advanced panel" begin
    fname = tempname() * ".fits"
    inhdr = FITSHeader(["CTYPE1", "CTYPE2", "RADESYS", "FLTKEY", "INTKEY", "BOOLKEY", "STRKEY", "COMMENT",
                        "HISTORY"],
                       ["RA---TAN", "DEC--TAN", "UNK", 1.0, 1, true, "string value", nothing, nothing],
                       ["",
                        "",
                        "",
                        "floating point keyword",
                        "",
                        "boolean keyword",
                        "string value",
                        "this is a comment",
                        "this is a history"])

    indata = reshape(Float32[1:100;], 5, 20)
    FITS(fname, "w") do f
        write(f, indata; header=inhdr)
        write(f, indata; header=inhdr)
    end
    img = AstroImage(fname, (1,2))

    adv_ui = ui_advanced(img)
    @test adv_ui isa GtkWindowLeaf
    @test get_gtk_property(adv_ui, :title, String) == "Image"
    @test adv_ui.g isa Gtk.GLib.FieldRef{GtkWindowLeaf}
    @test get_gtk_property(adv_ui, :default_height, Int) == 700
    @test get_gtk_property(adv_ui, :default_width, Int) == 700

    rm(fname, force = true)
    destroy(adv_ui)
end
