#============================================================
#    Timeline
#============================================================
# - author: zhangxuetu
# - datetime: 2023-09-24 23:10:53
# - version: 4.1
#============================================================
## 执行功能时间线
##
##执行不同时间段的阶段的事务。通过设置 [member stages] 属性，设置数据执行的阶段顺序，
##在调用 [method execute] 方法执行的时候，会根据 [member stages] 顺序执行给予数据的
##消耗的时间，并发出 [signal executed_stage] 信号来响应执行到的每个阶段
class_name TimeLine
extends Node


## 准备执行
signal ready_execute
## 执行完这个阶段时发出这个信号，last_data 数据为调用 [method execute] 执行后的数据
signal executed_stage(stage, last_data: Dictionary)
## 手动停止执行
signal stopped
## 暂停执行
signal paused
## 继续执行
signal resumed
## 执行完成
signal finished


## process 执行方式
enum ProcessExecuteMode {
	PROCESS, ## _process 执行
	PHYSICS, ## _physics_process 执行
}

enum {
	UNEXECUTED, ## 未执行
	EXECUTING, ## 执行中
	PAUSED, ## 暂停中
}


## 时间阶段名称。这关系到 [method execute] 方法中的数据获取的时间数据
@export var stages : Array = []
## process 执行方式。如果设置为 [enum ProcessExecuteMode.PROCESS] 或 [enum ProcessExecuteMode.PHYSICS] 以外的值，
## 则当前节点的线程将不会执行
@export var process_execute_mode : ProcessExecuteMode = ProcessExecuteMode.PROCESS

## 当前阶段的剩余时间。修改这个时间会改变剩余时间
var stage_time_left : float = 0.0

# 上次执行后的数据
var _last_data : Dictionary = {}
# 所在阶段的指针
var _stage_point : int = -1:
	set(v):
		if _stage_point != v:
			_stage_point = v
			if _stage_point >= 0 and _stage_point < stages.size():
				self.executed_stage.emit(stages[_stage_point], _last_data)
# 当前执行到的阶段
var _execute_state : int = UNEXECUTED:
	set(v):
		if _execute_state == v:
			return
		
		_execute_state = v
		match _execute_state:
			UNEXECUTED:
				set_process(false)
				set_physics_process(false)
			EXECUTING:
				if process_execute_mode == ProcessExecuteMode.PROCESS:
					set_process(true)
				elif process_execute_mode == ProcessExecuteMode.PHYSICS:
					set_physics_process(true)
			PAUSED:
				set_process(false)
				set_physics_process(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		set_process(false)
		set_physics_process(false)

func _process(delta):
	_exec(delta)

func _physics_process(delta):
	_exec(delta)

func _exec(delta):
	stage_time_left -= delta
	# 当前阶段执行完时，开始不断向后执行到 时间>0 的阶段
	while stage_time_left <= 0:
		_stage_point += 1
		if _stage_point < stages.size():
			stage_time_left += _last_data[stages[_stage_point]]
		else:
			# 所有阶段执行完毕
			stage_time_left = 0
			_stage_point = -1
			_execute_state = UNEXECUTED
			self.finished.emit()
			break

## 获取当前阶段剩余执行时间
func get_time_left():
	return stage_time_left

## 获取上次执行时的数据
func get_last_data() -> Dictionary:
	return _last_data

## 获取当前执行到的阶段
func get_current_stage():
	return stages[_stage_point]

## 修改这个阶段耗费的时间
func alter_stage_time(stage, time: float):
	_last_data[stage] = time

## 执行功能。这个数据里需要有 [member stages] 中的 key 的数据，且需要是 [int] 或 [float]
## 类型作为判断执行的时间。否则默认时间为 0
func execute(data: Dictionary):
	if data.is_empty():
		push_warning("时间线数据为空，没有执行功能")
		return
	_last_data = data.duplicate()
	_stage_point = 0
	if not stages.is_empty():
		_execute_state = EXECUTING
		for stage in stages:
			_last_data[stage] = float(data.get(stage, 0))
		# 执行时会先执行一下
		stage_time_left = _last_data[stages[0]]
		self.ready_execute.emit()
		_exec(0)
		
	else:
		printerr("没有设置 stages，必须要设置每个执行的阶段的 key 值！")

## 获取执行状态
func get_execute_state():
	return _execute_state

## 是否正在执行
func is_executing():
	return _execute_state == EXECUTING

## 停止执行
func stop():
	if _execute_state == EXECUTING:
		_execute_state = UNEXECUTED
		self.stopped.emit()

## 暂停执行
func pause():
	if _execute_state == EXECUTING:
		_execute_state = PAUSED
		self.paused.emit()

## 恢复执行
func resume():
	if _execute_state == PAUSED:
		_execute_state = EXECUTING
		self.resumed.emit()

## 跳跃到这个阶段（不会发出 [signal executed_stage] 信号，需要手动发出）
func goto(stage):
	if _execute_state == EXECUTING:
		if stages.has(stage):
			_stage_point = stages.find(stage)
			stage_time_left = _last_data[stages[_stage_point]]
		else:
			push_error("stages 中没有 ", stage, ". 所有 stage: ", stages)
