extends Timer

# This "grace period" timer exists to fix a wierd bug caused by _input and process being asyncronous
# Can probably re-work the input to not cause this, later
func _ready() -> void:
	connect("timeout", get_parent(),"exit_grace")


