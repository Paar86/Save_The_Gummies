class_name State extends Node

## States which this state can transition into.
@export var states_for_transition: Array[State] = []

## Marks the state as abstract.
## Abstract state cannot be transitioned into and is used only for code sharing.
@export var abstract := false

var state_machine: StateMachine = null
var physics_body: PhysicsBody2D = null

var state_name: String:
	get:
		return self.name


func on_enter(params: StateParams) -> void:
	pass


func on_exit() -> void:
	pass


func unhandled_input(event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	pass


func propagate_effects(effects: Array[String]) -> void:
	pass
