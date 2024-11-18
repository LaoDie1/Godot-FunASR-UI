#============================================================
#    Take Damage Component
#============================================================
# - author: zhangxuetu
# - datetime: 2024-06-09 20:32:46
# - version: 4.3.0.beta1
#============================================================
## 受伤组件
class_name TakeDamageComponent
extends MyNode


signal took_damage(data: Dictionary)


@export var target: Node
@export var method: StringName
@export var parameter: Array


func execute(data: Dictionary):
	assert(data.has("value"), "数据中必须包含 value 键的值")
	
	var idx = parameter.find("{value}")
	assert(idx > -1, "参数中必须包含 {value} 的参数作为占位符")
	
	var para = parameter.duplicate()
	para[idx] = data["value"]
	target.callv(method, parameter[idx])
	took_damage.emit(data)
