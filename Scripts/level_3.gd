extends Node2D

@onready var camara = $Player/Camera2D 

func _ready() -> void:
	# Ajustamos el zoom de la cueva exclusivamente
	if camara:
		camara.zoom = Vector2(8.0, 8.0)
