extends Area2D

# Esto crea una casilla en el Inspector para que elijas el nivel
@export var escena_siguiente: PackedScene

@onready var pantalla_negra = $CanvasLayer/PantallaNegra
var nivel_terminado = false

func _ready() -> void:
	pantalla_negra.modulate.a = 0

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not nivel_terminado:
		nivel_terminado = true 
		
		body.set_physics_process(false) 
		
		var tween = get_tree().create_tween()
		tween.tween_property(body, "global_position:x", global_position.x, 1.0)
		tween.tween_callback(body.hide)
		tween.tween_property(pantalla_negra, "modulate:a", 1.0, 1.5)
		
		await get_tree().create_timer(4.5).timeout
		
		# Cambiamos al nivel que hayas puesto en el Inspector
		if escena_siguiente != null:
			get_tree().change_scene_to_packed(escena_siguiente)
