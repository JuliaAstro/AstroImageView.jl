module AstroImageView

using AstroImages, GtkReactive, Gtk.ShortNames, Graphics, Gtk, Colors, IntervalSets, Cairo
using AstroImages: render
using WCS, FITSIO

export ui_basic

include("utils.jl")
include("basic.jl")

end # module
