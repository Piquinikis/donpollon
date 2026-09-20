extends Node2D

@onready var ui_controles = $UI_Controles
@onready var fondo_controles = $UI_Controles/FondoControles # Añadimos esta línea
@onready var player = $Player

var controles_activos = true

func _ready() -> void:
	# 1. Desactivamos al jugador al iniciar
	if player:
		player.set_physics_process(false)
	
	# 2. Desactivamos a los enemigos
	desactivar_enemigos(true)

func _input(event: InputEvent) -> void:
	# Permitir saltar la pantalla con Enter o Espacio
	if controles_activos and (event.is_action_pressed("ui_accept")):
		iniciar_nivel()

func _on_temporizador_controles_timeout() -> void:
	iniciar_nivel()

func iniciar_nivel() -> void:
	if not controles_activos:
		return
		
	controles_activos = false
	
	# Animamos el ColorRect (fondo_controles) en lugar del CanvasLayer
	var tween = get_tree().create_tween()
	tween.tween_property(fondo_controles, "modulate:a", 0.0, 0.8)
	await tween.finished
	
	ui_controles.hide()
	
	# Reactivamos todo
	if player:
		player.set_physics_process(true)
	
	desactivar_enemigos(false)

func desactivar_enemigos(bloquear: bool) -> void:
	for nodo in get_tree().get_nodes_in_group("enemigos"):
		nodo.set_physics_process(not bloquear)
		nodo.set_process(not bloquear)
