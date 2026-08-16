class_name UiFactory
extends RefCounted
## Pure UI construction helpers.
## The game controller supplies content and colors; this factory owns widget setup.

static func label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	return label

static func button(text: String, color: Color, background: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", Color("#d7c56d"))
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_stylebox_override("normal", style(background, Color("#4b443c"), 1, 8))
	button.add_theme_stylebox_override("hover", style(Color("#312d24"), Color("#d7c56d"), 1, 8))
	button.add_theme_stylebox_override("pressed", style(Color("#3c3527"), Color("#d7c56d"), 1, 8))
	button.add_theme_stylebox_override("disabled", style(Color("#191719"), Color("#302c2b"), 1, 8))
	return button

static func style(background: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = background
	style_box.border_color = border
	style_box.set_border_width_all(width)
	style_box.set_corner_radius_all(radius)
	style_box.content_margin_left = 16.0
	style_box.content_margin_right = 16.0
	style_box.content_margin_top = 10.0
	style_box.content_margin_bottom = 10.0
	return style_box
