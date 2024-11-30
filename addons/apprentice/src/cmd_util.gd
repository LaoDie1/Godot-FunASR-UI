#============================================================
#    Cmd Util
#============================================================
# - author: zhangxuetu
# - datetime: 2024-11-30 14:47:07
# - version: 4.3.0.stable
#============================================================
class_name CMDUtil


## 带阻塞的执行
static func execute(params: Array, output: Array = []) -> int:
	var p = ["/C"]
	p.append_array(params)
	return OS.execute("CMD.exe", p, output)

## 线程执行 CMD。method 方法需要有一个参数接收执行结果
static func thread_execute(params: Array, method: Callable) -> void:
	var thread := Thread.new()
	thread.start(
		func():
			var output: Array = []
			execute(params, output)
			method.call_deferred(output[0])
			thread.wait_to_finish.call_deferred()
	)
