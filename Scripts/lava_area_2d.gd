extends Area2D

@export var velocidad_hundimiento: float = 40.0  
@export var daño_por_contacto: int = 20          

var jugador_atrapado: CharacterBody2D = null
@onready var timer_daño: Timer = $Timer  

func _ready() -> void:
	if get_parent().has_method("play"):
		get_parent().play("Movement")
	
	# Conectamos las señales del Area2D por código para evitar que falten conexiones
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)
	
	# Configuramos el timer
	if timer_daño:
		timer_daño.stop()
		if not timer_daño.timeout.is_connected(_on_timer_daño_timeout):
			timer_daño.timeout.connect(_on_timer_daño_timeout)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		jugador_atrapado = body as CharacterBody2D
		
		if jugador_atrapado and jugador_atrapado.has_method("take_damage"):
			jugador_atrapado.take_damage(daño_por_contacto)
			
			
			# Si con el primer toque el jugador muere, dejamos que el script del jugador maneje su muerte
			if jugador_atrapado.health <= 0:
				return
		
		if jugador_atrapado and jugador_atrapado.has_method("hundir_en_lava"):
			jugador_atrapado.hundir_en_lava(velocidad_hundimiento)
		
		if timer_daño:
			timer_daño.start()

func _on_body_exited(body: Node2D) -> void:
	if body == jugador_atrapado:
		if jugador_atrapado and jugador_atrapado.has_method("salir_de_lava"):
			jugador_atrapado.salir_de_lava()
		jugador_atrapado = null
		
		if timer_daño:
			timer_daño.stop()

func _on_timer_daño_timeout() -> void:
	if jugador_atrapado:
		if jugador_atrapado.has_method("take_damage"):
			jugador_atrapado.take_damage(daño_por_contacto)
			
			# Si la vida llega a 0, detenemos el timer y dejamos que el jugador ejecute su propia muerte
			if jugador_atrapado.health <= 0:
				if timer_daño:
					timer_daño.stop()
