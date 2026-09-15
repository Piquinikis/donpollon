extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -200.0
const DAMAGE = 10
const HIT1 = "Hit1"

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $HitBox
@onready var hitbox_shape = $HitBox/ShapeGolpeEnemigo

var attacking := false
var facing_direction := 1  # 1 = derecha, -1 = izquierda
var hitbox_base_offset: float  # distancia original del hitbox al personaje


func _ready() -> void:
	hitbox_shape.set_deferred("disabled", true)
	anim.animation_finished.connect(_on_anim_finished)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Guardamos la distancia real del CollisionShape2, no la del HitBox
	hitbox_base_offset = abs(hitbox_shape.position.x)
	_update_facing()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Attack") and not attacking:
		attack()

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var current_speed = SPEED
	if Input.is_action_pressed("correr"):
		current_speed = RUN_SPEED

	var direction := Input.get_axis("izquierda", "derecha")
	if direction:
		velocity.x = direction * current_speed

		if not attacking:
			facing_direction = 1 if direction > 0 else -1
			_update_facing()
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

	if attacking:
		return

	if not is_on_floor():
		if anim.animation != "Jump":
			anim.play("Jump")
	else:
		if direction != 0:
			anim.play("Run" if Input.is_action_pressed("correr") else "Walk")
		else:
			anim.play("Idle")


func _update_facing() -> void:
	print("Antes: ", hitbox_shape.position.x)
	anim.flip_h = facing_direction < 0
	# Movemos el CollisionShape2 (el que tiene el offset real), no el HitBox
	hitbox_shape.position.x = hitbox_base_offset * facing_direction
	print("Despues: ", hitbox_shape.position.x)


func attack() -> void:
	attacking = true
	_update_facing()
	anim.play(HIT1)
	hitbox_shape.set_deferred("disabled", false)


func _on_anim_finished() -> void:
	if anim.animation == HIT1:
		attacking = false
		hitbox_shape.set_deferred("disabled", true)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos") and body.has_method("take_damage"):
		body.take_damage(DAMAGE)
