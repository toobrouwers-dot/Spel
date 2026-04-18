class_name GameOverScreen
extends CanvasLayer

const WIN_COLOR := Color(0.2, 0.9, 0.5)
const LOSE_COLOR := Color(0.9, 0.2, 0.2)
const BG_COLOR := Color(0.05, 0.05, 0.1, 0.88)

var _panel: ColorRect
var _title: Label
var _subtitle: Label
var _stats: Label
var _button: Button
var _tween: Tween

signal next_fight_requested()
signal restart_run_requested()

func _ready() -> void:
	layer = 20
	visible = false
	_build_ui()

func show_win(fight_number: int, enemies_defeated: int) -> void:
	_title.text = "GEVECHT %d GEWONNEN" % fight_number
	_title.add_theme_color_override("font_color", WIN_COLOR)
	_subtitle.text = "Alle vijanden verslagen"
	_stats.text = "Totaal verslagen: %d" % enemies_defeated
	_button.text = "Volgend gevecht →"
	_button.pressed.disconnect(_button.pressed.get_connections()[0]["callable"]) if _button.pressed.get_connections().size() > 0 else null
	_button.pressed.connect(func() -> void: next_fight_requested.emit())
	_show_animated()

func show_lose(fight_number: int, enemies_defeated: int) -> void:
	_title.text = "VERSLAGEN"
	_title.add_theme_color_override("font_color", LOSE_COLOR)
	_subtitle.text = "Run beëindigd na gevecht %d" % fight_number
	_stats.text = "Totaal verslagen: %d vijanden" % enemies_defeated
	_button.text = "Nieuwe run starten"
	_button.pressed.disconnect(_button.pressed.get_connections()[0]["callable"]) if _button.pressed.get_connections().size() > 0 else null
	_button.pressed.connect(func() -> void: restart_run_requested.emit())
	_show_animated()

func _show_animated() -> void:
	visible = true
	modulate.a = 0.0
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)

func _build_ui() -> void:
	_panel = ColorRect.new()
	_panel.color = BG_COLOR
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.set_anchor(SIDE_LEFT, 0.1)
	vbox.set_anchor(SIDE_RIGHT, 0.9)
	vbox.set_anchor(SIDE_TOP, 0.3)
	vbox.set_anchor(SIDE_BOTTOM, 0.7)
	vbox.add_theme_constant_override("separation", 24)
	_panel.add_child(vbox)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 60)
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(_title)

	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.add_theme_font_size_override("font_size", 30)
	_subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	vbox.add_child(_subtitle)

	_stats = Label.new()
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats.add_theme_font_size_override("font_size", 26)
	_stats.add_theme_color_override("font_color", Color(0.5, 0.5, 0.7))
	vbox.add_child(_stats)

	_button = Button.new()
	_button.custom_minimum_size = Vector2(360.0, 88.0)
	_button.add_theme_font_size_override("font_size", 36)
	vbox.add_child(_button)
