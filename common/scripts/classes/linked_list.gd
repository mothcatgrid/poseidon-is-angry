class_name LinkedList


var head: ListNode = null
var tail: ListNode = null
var length: int = 0


func insert_after(node: ListNode, new_node: ListNode):
	new_node.prev = node      
	if node.next == null:
		new_node.next = null
		tail = new_node
	else:
		new_node.next = node.next
		node.next.prev = new_node
	node.next = new_node


func insert_before(node: ListNode, new_node: ListNode):
	new_node.next = node
	if node.prev == null:
		new_node.prev = null
		head = new_node
	else:
		new_node.prev = node.prev
		node.prev.next = new_node
	node.prev = new_node


func insert_beginning(new_node: ListNode):
	if head == null:
		head = new_node
		tail  = new_node
		new_node.prev = null
		new_node.next = null
	else:
		insert_before(head, new_node)


func insert_end(new_node: ListNode):
	if head == null:
		insert_beginning(new_node)
	else:
		insert_after(tail, new_node)


func remove(node: ListNode):
	if node.prev == null:
		head = node.next
	else:
		node.prev.next = node.next
	if node.next == null:
		tail = node.prev
	else:
		node.next.prev = node.prev
