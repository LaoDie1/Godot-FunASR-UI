#============================================================
#    Linked List
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-01 23:01:10
# - version: 4.3.0.stable
#============================================================
## 链表
class_name LinkedList
extends RefCounted


class ListNode:
	var value
	
	var _parent: LinkedList
	var _previous : ListNode
	var _next : ListNode
	
	func _to_string():
		return "<%s#%s>" % ["ListNode", get_instance_id()]
	
	func erase():
		_parent.erase(self)


var _first: ListNode
var _last: ListNode
var _size : int = 0


func _init(items = []):
	if items:
		for item in items:
			append(item)

func _to_string():
	return "<%s#%s>" % ["LinkedList", get_instance_id()]

func append(item) -> void:
	var node := ListNode.new()
	node.value = item
	node._parent = self
	if _first == null:
		_first = node
	if _last != null:
		_last._next = node
		node._previous = _last
	_last = node
	_size += 1

func remove_at(position: int) -> void:
	assert(position < _size, "超出索引")
	var node = get_node(position)
	if _size == 1:
		_first = null
		_last = null
		_size -= 1
	else:
		erase(node)

func erase(node: ListNode) -> void:
	if node == null:
		return
	var previous = node._previous
	var next = node._next
	if previous:
		previous._next = next
	if next:
		next._previous = previous
	if self._first == node:
		self._first = next
	if self._last == node:
		self._last = previous
	self._size -= 1

func clear() -> void:
	_first = null
	_last = null
	_size = 0

func get_first() -> ListNode:
	return _first

func get_last() -> ListNode:
	return _last

func get_size() -> int:
	return _size

func get_node(position: int) -> ListNode:
	assert(position < _size, "超出索引")
	var i : int = -1
	var tmp_node : ListNode = _first
	while tmp_node:
		i += 1
		if i == position:
			return tmp_node
		tmp_node = tmp_node._next
	return null

func get_value(position: int):
	assert(position < _size, "超出索引")
	return get_node(position).value

func get_array() -> Array:
	if _first == null:
		return []
	var list : Array = []
	var tmp : ListNode = _first
	while tmp:
		list.append(tmp.value)
		tmp = tmp._next
	return list

func get_node_list():
	if _first == null:
		return []
	var list : Array = []
	var tmp : ListNode = _first
	while tmp:
		list.append(tmp)
		tmp = tmp._next
	return list
