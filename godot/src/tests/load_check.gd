extends SceneTree
func _init():
  print("LOAD_CHECK_BEGIN")
  var p = ResourceLoader.load("res://scenes/Player.tscn")
  if p == null:
    print("LOAD_FAIL Player")
  else:
    print("LOAD_OK Player")
  var e = ResourceLoader.load("res://scenes/Evidence.tscn")
  if e == null:
    print("LOAD_FAIL Evidence")
  else:
    print("LOAD_OK Evidence")
  if p != null and e != null:
    quit(0)
  else:
    quit(1)
