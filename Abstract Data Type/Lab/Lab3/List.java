//Zhijun Yang
//1658412
//pa3

public class List{
	private class Node{
		Object data;
        Node next;
        Node previous;

    	Node(Object data) {
            this.data = data;
            next = null;
            previous = null;
        }

		Node(Object data, Node nextNode, Node prevNode) {
            this.data = data;
            next = nextNode;
            previous = prevNode;
    	}

    	public String toString() {
			return String.valueOf(data);
		}
	}
	private int length;
    private Node cursor; 
    private int index;
    private Node front; 
    private Node back; 

    List(){
    	front = null;
		back = null;
		cursor = null;
		index = -1;
		length = 0;
    }

    public int length() {
		return length;
	}

	int index() {
        if (index > length - 1) {
            index = -1;
        }
        return index;
    }

    Object front() {
        if (length <= 0) {
            return null;
        }
        return front.data;
    }

    Object back() {
        if (length <= 0) {
            return null;
        }
        return back.data;
    }

    Object get() {
        if (length() == 0) {
            return null;
        } else if (index == -1) {
            return null;
        } else {
            return cursor.data;
        }

    }

    public boolean equals(List list) {
        boolean check = true;

        Node firstNode = this.front;
        Node nodeSecondNode = list.front;

        if (this.length == list.length) {
            if (check && firstNode != null) {
                do {
                    check = (firstNode.data == nodeSecondNode.data);
                    firstNode = firstNode.next;
                    nodeSecondNode = nodeSecondNode.next;
                } while (check && firstNode != null);
            }
            return check;
        }
        return false;
    }

    void clear(){
    	cursor = front;
        if (cursor != null) {
            if (cursor.next != null) {
                do {
                    Node temp = cursor;
                    cursor = cursor.next;
                    temp.next = null;
                    temp.previous = null;
                } while (cursor.next != null);
            }
            cursor = null;
            front = null;
            back = null;
            length = 0;
            index = -1;
        }
    }

    void moveFront(){
        if (length > 0) {
            cursor = front;
            index = 0;
        }
    }

    void moveBack(){
        if (length > 0) {
            cursor = back;
            index = length - 1;
        }
    }

    void movePrev() {
		if ( cursor != null && !cursor.equals(front)) {
			cursor = cursor.previous;
			index--;
		} else if (cursor != null && cursor.equals((front))) {
			cursor = null;
			index = -1;
		} 
	}

	void moveNext(){
		if (cursor != null && !cursor.equals(back)) {
			cursor = cursor.next;
			index++;
		} else if (cursor != null && cursor.equals(back)) {
			cursor = null;
			index = -1;
		} 
	}

	void prepend(Object data){
		if ( length > 0) {
			Node newElement = new Node(data, front, null);
			front.previous = newElement;
			front = newElement;
			length++;
			index++;
		} else {
			Node newElement = new Node(data) ;
			front = newElement;
			back = newElement;
			length++;
			index++;
		}
	}

	void append(Object data){
		if (length > 0) {
			Node newElement = new Node(data, null, back);
			back.next = newElement;
			back = newElement;
			length++;
		} else {
			Node newElement = new Node(data);
			front = newElement;
			back = newElement;
			length++;
		}
	}

	void insertBefore(Object data) {
		if (length() <= 0) {
			return;
		} else if (index() < 0) {
			return;
		} 
		Node newElement = new Node(data);
		if (index() == 0) {
			prepend(data);
		} else {
			newElement.next = cursor;
			newElement.previous = cursor.previous;
			cursor.previous.next = newElement;
			cursor.previous = newElement;
			index++;
			length++;
		}
	}

	void insertAfter(Object data) {
		if (length() <= 0) {
			return;
		} else if (index() < 0) {
			return;
		}
		Node newElement = new Node(data);
		if ( index() == length() - 1) {
			append(data);
		} else {
			newElement.previous = cursor;
			newElement.next = cursor.next;
			cursor.next.previous = newElement;
			cursor.next = newElement;
			length++;
		}
	}

	void deleteFront(){
		if (length == 1) {
            clear();
        } else {
            if (cursor == front) {
                cursor = null;
                index = -1;
            } else if (cursor != null) {
                index--;
            }
            front = front.next;
            front.previous = null;
            length--;
        }
    }

    void deleteBack(){
    	if(length == 1) {
			clear();
		} else if(length > 0) {
			if(cursor == back){
				index =-1;
			}
			back = back.previous;
			if(back != null) {
				back.next = null;
			}
			length--;
		} else {
			back = null;
		}
    }

    void delete(){
    	if(cursor == front){
			deleteFront();
		} else if (cursor == back){
			deleteBack();
		} else if (length > 0 && index >= 0) {
			cursor.next.previous = cursor.previous;
			cursor.previous.next = cursor.next;
			cursor = null;
			index = -1;
			length --;
		}
    }

    public String toString() {
        StringBuilder str = new StringBuilder();
        Node N = front;
        if (N != null) {
            do {
                if (N == back) {
                    str.append(N.toString());
                } else {
                    str.append(N.toString()).append(" ");
                }
                N = N.next;
            } while (N != null);
        }
        return str.toString();
    }
}

    



