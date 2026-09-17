extends CharacterBody2D

const SPEED = 100.0
const RUN_SPEED = 200.0
const JUMP_VELOCITY = -200.0
const DAMAGE = 10
const MAX_HEALTH = 100
const HIT1 = "Hit1"

@onready var anim = $AnimatedSprite2D
@onready var hitbox = $HitBox
@onready var hitbox_shape = $HitBox/ShapeGolpeEnemigo

@export var health_bar: TextureProgressBar

var health := MAX_HEALTH
var dead := false
var attacking := false
var facing_direction := 1  # 1 = derecha, -1 = izquierda
var hitbox_base_offset: float  # distancia original del hitbox al personaje


func _ready() -> void:
	hitbox_shape.set_deferred("disabled", true)
	anim.animation_finished.connect(_on_anim_finished)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

	# Guardamos la distancia real del CollisionShape
	hitbox_base_offset = abs(hitbox_shape.position.x)
	_update_facing()

	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health


func _physics_process(delta: float) -> void:
	if dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

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
	anim.flip_h = facing_direction < 0
	hitbox_shape.position.x = hitbox_base_offset * facing_direction


func attack() -> void:
	attacking = true
	_update_facing()
	anim.play(HIT1)
	hitbox_shape.set_deferred("disabled", false)

	# Por si el enemigo ya estaba pegado al jugador al presionar atacar
	await get_tree().process_frame
	if attacking:
		for body in hitbox.get_overlapping_bodies():
			_check_and_damage(body)


func take_damage(amount: int) -> void:
	if dead:
		return

	health -= amount
	health = max(health, 0)
	print("¡Jugador recibió ", amount, " de daño! Vida restante: ", health)

	if health_bar:
		var bar_tween = create_tween()
		bar_tween.tween_property(health_bar, "value", health, 0.2)

	# Efecto visual rápido de parpadeo rojo
	var tween = create_tween()
	tween.tween_property(anim, "modulate", Color.RED, 0.1)
	tween.tween_property(anim, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		die()


func heal(amount: int) -> void:
	if dead:
		return

	health += amount
	health = min(health, MAX_HEALTH)
	print("¡Jugador recuperó ", amount, " de vida! Vida actual: ", health)

	if health_bar:
		var bar_tween = create_tween()
		bar_tween.tween_property(health_bar, "value", health, 0.2)


func die() -> void:
	dead = true
	velocity.x = 0
	attacking = false
	hitbox_shape.set_deferred("disabled", true)
	anim.play("Death") # Reproduce la animación de muerte limpia
	print("El jugador ha muerto")


func _on_anim_finished() -> void:
	if anim.animation == HIT1:
		attacking = false
		hitbox_shape.set_deferred("disabled", true)
	elif anim.animation == "Death":
		# Pausamos en el último frame de la muerte para que no se repita
		anim.pause()


func _on_hitbox_body_entered(body: Node2D) -> void:
	_check_and_damage(body)


func _check_and_damage(body: Node2D) -> void:
	if body != self and body.is_in_group("enemigos") and body.has_method("take_damage"):
		body.take_damage(DAMAGE)
