class_name NPC
extends Node2D

@export var color: Enum.NPCColors = Enum.NPCColors.RED

@onready var state_machine: StateMachine = $StateMachine
