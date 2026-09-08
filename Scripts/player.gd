extends CharacterBody2D


const SPEED = 100.0
const RUN_SPEED = 250.0
const JUMP_VELOCITY = -200.0

@onready var anim = $AnimatedSprite2D
@onready var combo_timer = $"Combo timer"
var combo_step = 0
var is_attacking = false
var buffered_attack = false
func _ready() -> void: 
	combo_timer.timeout.connect(_reset_combo)
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var current_speed = SPEED
	if Input.is_action_pressed("correr"):
		current_speed = RUN_SPEED
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("izquierda", "derecha")
	if direction:
		velocity.x = direction * current_speed
		anim.flip_h=direction<0
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()
	if anim.animation not in ["Hit1", "Hit2", "Hit3"]: 
		if not is_on_floor():
			if anim.animation != "Jump":
				anim.play("Jump")
		elif direction != 0:
			if Input.is_action_pressed("correr"):
				anim.play("Run")
			else: 
				anim.play("Walk")
		else:
			anim.play("Idle")
func _input(event: InputEvent) -> void: 
		if event.is_action_pressed("Attack"):
			if not is_attacking:
				combo_step = 1
				is_attacking = true
				buffered_attack = false
				anim.play("Hit1")
				combo_timer.start()
			else:
				buffered_attack = true
			
func advance_combo() -> void:
	combo_step += 1
	if combo_step > 3:
		combo_step = 1
		
	if combo_step == 1: 
		anim.play("Hit1")
	elif combo_step == 2:
		anim.play("Hit2")
	elif combo_step == 3:
		anim.play("Hit3")

	combo_timer.start()

func _on_animation_finished() -> void:
	if anim.animation in ["Hit1", "Hit2", "Hit3"]:
		if buffered_attack and combo_step < 3:
			buffered_attack = false
		advance_combo()
	else:
		is_attacking = false
		buffered_attack = false
		combo_step = 0
		anim.play("Idle")
	
func _reset_combo() -> void:
		combo_step = 0
		is_attacking = false
		buffered_attack = false 
	
	
