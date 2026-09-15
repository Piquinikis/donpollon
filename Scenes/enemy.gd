extends CharacterBody2D

const MAX_HEALTH = 50
const DEATH_ANIM = "Death_E"
const SPEED = 80.0
const ATTACK_RANGE = 40.0
const DAMAGE_AMOUNT = 10

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var health := MAX_HEALTH
var dead := false
var is_hurting := false
var is_attacking := false

# Referencia al jugador (se busca automáticamente en la escena)
var player: CharacterBody2D = null


func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)
	anim.play("Idle_E") if anim.sprite_frames.has_animation("Idle_E") else anim.play("Idle_E")
	
	# Busca al jugador por su grupo (Asegúrate de añadir a tu jugador al grupo "player")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Si está muerto, reaccionando al dolor o atacando, detiene el movimiento horizontal
	if dead or is_hurting or is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# Lógica de persecución y ataque si encuentra al jugador
	if player:
		var distance = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()

		# Voltear el sprite hacia donde mira
		if direction.x != 0:
			anim.flip_h = direction.x < 0

		# Rango de ataque
		if distance <= ATTACK_RANGE:
			attack()
		else:
			# Caminar hacia el jugador
			velocity.x = direction.x * SPEED
			anim.play("Walk_E")
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()


func attack() -> void:
	is_attacking = true
	velocity.x = 0
	
	# Selecciona aleatoriamente entre Hit1_E y Hit2_E
	var attack_anims = ["Hit1_E", "Hit2_E"]
	var selected_anim = attack_anims[randi() % attack_anims.size()]
	anim.play(selected_anim)


func deal_damage_to_player() -> void:
	# Método para aplicar daño al jugador si está a distancia de golpe
	if player and global_position.distance_to(player.global_position) <= ATTACK_RANGE + 10:
		if player.has_method("take_damage"):
			player.take_damage(DAMAGE_AMOUNT)


func take_damage(amount: int) -> void:
	if dead:
		return
		
	health -= amount
	print("Enemigo recibió ", amount, " de daño. Vida restante: ", health)
	
	if health <= 0:
		die()
	else:
		is_hurting = true
		is_attacking = false # Interrumpe el ataque si recibe un golpe
		anim.play("Hurt_E")


func die() -> void:
	dead = true
	is_hurting = false
	is_attacking = false
	anim.play(DEATH_ANIM)
	collision.set_deferred("disabled", true)


func _on_anim_finished() -> void:
	match anim.animation:
		"Hit1_E", "Hit2_E":
			deal_damage_to_player() # Aplica el daño al terminar el golpe
			is_attacking = false
		"Hurt_E":
			is_hurting = false
		DEATH_ANIM:
			queue_free()
