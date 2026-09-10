extends CharacterBody2D

const MAX_HEALTH = 30
const DEATH_ANIM = "Death_E"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var health := MAX_HEALTH
var dead := false


func _ready() -> void:
	anim.animation_finished.connect(_on_anim_finished)
	anim.play("Idle")   # cambiá por el nombre de tu animación de reposo


func _physics_process(delta: float) -> void:
	# Gravedad para que no flote
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Si está muerto, se queda quieto
	if dead:
		velocity.x = 0
		move_and_slide()
		return

	# Por ahora quieto; acá después va la IA (patrullar, perseguir, etc.)
	velocity.x = 0
	move_and_slide()


func take_damage(amount: int) -> void:
	if dead:
		return   # no recibe daño si ya está muerto
	health -= amount
	print("Enemigo recibió ", amount, " de daño. Vida: ", health)
	if health <= 0:
		die()


func die() -> void:
	dead = true
	anim.play(DEATH_ANIM)
	# Desactivar la colisión para que el jugador pueda pasar por encima del cadáver
	collision.set_deferred("disabled", true)


func _on_anim_finished() -> void:
	if anim.animation == DEATH_ANIM:
		queue_free()   # desaparece al terminar la animación de muerte
