extends HBoxContainer

signal parameter_updated(which_parameter, on_or_off)
@onready var check_box: CheckBox = $CheckBox
@onready var label: Label = $Label

func _ready() -> void:
	check_box.mouse_entered.connect(func():
		if !Input.is_action_pressed("click"):
			return
		var on_or_off = check_box.button_pressed
		check_box.button_pressed = !on_or_off
		)
	
	check_box.toggled.connect(func(on_or_off):
		parameter_updated.emit(label.text, on_or_off))
		
	#check_box.button_pressed = false
	#parameter_updated.emit(label.text, false)
