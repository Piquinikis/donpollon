extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -200.0
const DAMAGE = 10
const HIT1 = "Hit1"


@onready var anim = $AnimatedSprite2D
@onready var hitbox = $HitBox
@onready var hitbox_shape = $HitBox/CollisionShape2D

var attacking := false

func _ready() -> void:
	hitbox_shape.disabled = true
	anim.animation_finished.connect(_on_anim_finished)
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Iniciar ataque (una sola vez por pulsación, y solo si no está atacando)
	if Input.is_action_just_pressed("Attack") and not attacking:
		attack()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var current_speed = SPEED
	if Input.is_action_pressed("correr"):
		current_speed = RUN_SPEED

	var direction := Input.get_axis("izquierda", "derecha")
	if direction:
		velocity.x = direction * current_speed
		anim.flip_h = direction < 0
		hitbox.scale.x = -1 if anim.flip_h else 1
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

	# Mientras ataca, no pisar la animación de golpe con Idle/Walk/Run/Jump
	if attacking:
		return

	if not is_on_floor():
		if anim.animation != "Jump":
			anim.play("Jump")
	else:
		if direction != 0:
			if Input.is_action_pressed("correr"):
				anim.play("Run")
			else:
				anim.play("Walk")
		else:
			anim.play("Idle")


func attack() -> void:
	print("Atacando")
	attacking = true
	anim.play(HIT1)
	hitbox_shape.disabled = false


func _on_anim_finished() -> void:
	print("_on_anim_finished")
	if anim.animation == HIT1:
		print("Termino Ataque")
		attacking = false
		hitbox_shape.disabled = true


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") and body.has_method("take_damage"):
		body.take_damage(DAMAGE)
