extends MarginContainer

@export var mute_se_button:TextureButton = null
@export var mute_bgm_button:TextureButton = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if mute_se_button == null:
		push_error("No mute sound effects button found in %s" % self)
		return
	
	if mute_bgm_button == null:
		push_error("No mute background music button found in %s" % self)
		return

	mute_se_button.toggled.connect(_on_mute_se_button_toggled)
	
	mute_bgm_button.toggled.connect(_on_mute_bgm_button_toggled)
	
	
	#if OS.has_feature("editor"):
		#mute_bgm_button.set_pressed_no_signal(true)
		#_on_mute_bgm_button_toggled(true)
	
	var is_muted:bool = AudioManager.is_bgm_muted()
	mute_bgm_button.set_pressed_no_signal(is_muted)
	_on_mute_bgm_button_toggled(is_muted)



func _on_mute_se_button_toggled(toggled_on:bool):
	AudioManager.mute_se(toggled_on)

func _on_mute_bgm_button_toggled(toggled_on:bool):
	AudioManager.mute_bgm(toggled_on)
