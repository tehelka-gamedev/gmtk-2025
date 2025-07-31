extends Node2D
class_name RoomBase
# Base for an object that can holds npc

@warning_ignore_start("unused_signal")
signal full # emitted when it is full
signal empty # emitted when it is empty
signal waiting_for_someone
@warning_ignore_restore("unused_signal")

@export var slot_manager: SlotManager
