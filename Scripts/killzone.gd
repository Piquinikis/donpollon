extends Area2D

@onready var pantalla_negra = $CanvasLayer/PantallaNegra
var jugador_muerto = false

func _ready() -> void:
	# Arranca invisible al iniciar el nivel
	pantalla_negra.modulate.a = 0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not jugador_muerto:
		jugador_muerto = true
		
		# 1. Congelamos al jugador para que no caiga más
		body.set_physics_process(false)
		
		# 2. Hacemos aparecer la pantalla negra y el texto suavemente
		var tween = get_tree().create_tween()
		tween.tween_property(pantalla_negra, "modulate:a", 1.0, 0.5)
		
		# 3. Esperamos 2 segundos para que el jugador lea el mensaje de muerte
		await get_tree().create_timer(2.0).timeout
		
		# 4. Reiniciamos el nivel actual
		get_tree().reload_current_scene()
