extends Node

# TODO: Possibly remove from global autoload and move to Player scene
signal player_direction_changed(direction: float)
signal player_aiming_requested
signal player_aiming_called_off
signal player_exited_ladder
signal player_hurt
signal player_dead
signal player_bounce_up_requested
signal player_pickup_drop_requested

# Global events
signal change_level_requested
signal reload_level_requested
signal pause_level_requested
