//Zhijun Yang
//zyang100
//pa3

public class List{

	private class Node{
		
		Object data;
		Node next;
		Node prev;

		
		Node(Object data) {
			this.data = data;
			next = null;
			prev = null;
		}

		public String toString(){
			return String.valueOf(data);
		}

		Node(Object data, Node nextNode, Node prevNode){
			this.data = data;
			next = nextNode;
			prev = prevNode;
		}
	}

	//Fields
	private Node back;
	private Node front;
	private int length = 0;
	private Node cursor;
	private int index;

	//Constructor
	List(){
		front = back = cursor = null;
		length = 0;
		index = -1;
	}
	// Access Functions --------------------------------------------------------
	// Returns the number of elements in this List
	public int length(){
		return length;
	}

	// If cursor is defined, returns the index of the cursor element,
 	// otherwise returns -1.
 	int index(){
 		if (cursor != null){
 			return index;
 		}
 		else{
 			return -1;
 		}
 	}

 	// Returns front element. Pre: length()>0
 	Object front(){
 		if (length > 0){
 			return front.data;
 		}else{
 			throw new RuntimeException("List Error: front() called on empty List");
 		}
 	}

 	// Returns back element. Pre: length()>0
 	Object back(){
 		if(length > 0){
 			return back.data;
 		}else{
 			throw new RuntimeException("List Error: front() called on empty List");
 		}
 	}

 	// Returns cursor element. Pre: length()>0, index()>=0
 	Object get() {
 		if (length() > 0 && index() >= 0){
 			return cursor.data;
 		}
 		else{
 			return -1;
 		}

	}

 	// Returns true if and only if this List and L are the same
 	// integer sequence. The states of the cursors in the two Lists
 	// are not used in determining equality.
 	boolean equals(List L){
 		boolean eq = true;
 		Node a = this.front;
 		Node b = L.front;

 		if(this.length == L.length){
 			while(eq && a !=  null){
 				eq = (a.data == b.data);
 				a = a.next;
 				b = b.next;
 			}
 			return eq;
 		}
 		else{
 			return false;
 		}
 	}

 	// Manipulation procedures 
 	// Resets this List to its original empty state.
 	void clear(){
 		front = back = cursor = null;
 		length = 0;
 		index = -1;
 		
 	}

 	void moveFront(){
 		/*if (length <= 0){
 			throw new RuntimeException("List Error: movefront() called on empty List");
 		}
 		else{*/
 		if (length > 0){
 			cursor = front;
 			index = 0;
 		}
 	}

 	void moveBack(){
 		/*if (length <= 0){
 			throw new RuntimeException("List Error: moveBack() called on empty List");
 		}
 		else*/
 		if (length > 0){
 			cursor = back;
 			index = length - 1;
 		}
 	}

	// If cursor is defined and not at front, moves cursor one step toward
 	// front of this List, if cursor is defined and at front, cursor becomes
	// undefined, if cursor is undefined does nothing.
 	void movePrev(){
 		if (cursor != null && index == 0){
 			cursor = null;
 			index = -1;
 		}
 		else if (cursor != null && index != 0) {
 			cursor = cursor.prev;
 			index--;
 		}
 	}

 	// If cursor is defined and not at back, moves cursor one step toward
 	// back of this List, if cursor is defined and at back, cursor becomes
	// undefined, if cursor is undefined does nothing.
	void moveNext(){
		if (cursor != null && cursor == back ){
 			cursor = null;
 			index = -1;
 		}
 		else if (cursor != null && cursor != back) {
 			cursor = cursor.next;
 			index++;
 		}
 		else if (cursor == null){
 			cursor = null;
 			index = -1;
 		}
 	}

	// Insert new element into this List. If List is non-empty,
 	// insertion takes place before front element.
 	void prepend(Object data){
 		if(length <= 0){
 			Node N = new Node(data);
			front = back = N;
 		}else{
 			Node N = new Node(data, front ,null);
 			front.prev = N;
 			front = N;
 		}
 		length++;
 		index++;
 	}

 	// Insert new element into this List. If List is non-empty,
 	// insertion takes place after back element.
 	void append(Object data){
 		if(length <= 0){
 			Node N = new Node(data);
 			front = back = N;
 		}
 		else{
 			Node N = new Node(data, null, back);
 			back.next = N; 
 			back = N;
 		}
 		length++;
 	}

 	// Insert new element before cursor.
 	// Pre: length()>0, index()>=0
 	void insertBefore(Object data){
 		Node N = new Node(data);
 		if(length() <= 0 || index() < 0){
 			throw new RuntimeException("List Error: insertBefore() called on empty List");
 		}
 		if(cursor == front){
 			prepend(data);
 		}
 		else{
 			N.prev = cursor.prev;
 			N.next = cursor;
 			cursor.prev.next = N;
 			cursor.prev = N;
 			length++;
 			index++;
 		}
 	}

 	// Inserts new element after cursor.
 	// Pre: length()>0, index()>=0
 	void insertAfter(Object data){
 		Node N = new Node(data);
 		if(length() <= 0 || index() < 0){
 			throw new RuntimeException("List Error: insertAfter() called on empty List");
 		}
 		if (index() == length()-1){
 			append(data);
 		}
 		else{
 			N.prev = cursor;
 			N.next = cursor.next;
 			cursor.next.prev = N;
 			cursor.next = N;
 			length++;
 		}
 	}

 	 // Deletes the front element. Pre: length()>0
 	void deleteFront() {
 	if (length() == 0){
 		throw new RuntimeException("List Error: deleteFront() called on empty List");
 	}else{
 		if (length() == 1){
 			clear();
 		}
 		else{
			if(cursor == front){
				cursor = null;
				index =-1;
			} else if (cursor != null){
				index--;
			}
			front = front.next;
			//front.prev.next = null;
			front.prev = null;
			length--;
		}
 	}
}

 	// Deletes the back element. Pre: length()>0
 	void deleteBack(){
 		if(length() <= 0){
 			throw new RuntimeException("List Error: deleteBack() called on empty List");
 		}
 		if(length == 1) {
			clear();
		} else if(length > 0) {
			if(cursor == back){
				index =-1;
			}
			back = back.prev;
			if(back != null) {
				back.next = null;
			}
			length--;
		} else {
			back = null;
		}
	}

 	// Deletes cursor element, making cursor undefined.
 	// Pre: length()>0, index()>=0
 	void delete() {
 		if (length() <= 0){
 			throw new RuntimeException("List Error: delete() called on empty List");
 		}
 		if (index < 0){
 			throw new RuntimeException("List Error: delete() called on empty index");
 		}
		if(cursor == front){
			deleteFront();
			return;
		} else if (cursor == back){
			deleteBack();
			return;
		} else 
		{
			cursor.next.prev = cursor.prev;
			cursor.prev.next = cursor.next;
			cursor = null;
			index = -1;
			length --;
		}
	}


 	// Other methods 
 	// Overrides Object's toString method. Returns a String
 	// representation of this List consisting of a space
 	// separated sequence of integers, with front on left.
 	public String toString(){
 		String str = "";
 		for (Node N = front; N != null; N = N.next){
 			str += N.toString() + " ";
 		}
 		return str;
 	}

 	// Returns a new List representing the same integer sequence as this
 	// List. The cursor in the new list is undefined, regardless of the
 	// state of the cursor in this List. This List is unchanged.
 	 public List copy(){
        List newList = new List();
        if (length() > 0)
        {
            Node N = front;
            while (N != null)
            {
                newList.append(N.data);
                N = N.next;
            }
        }
        newList.cursor = null;
        newList.index = -1;
        return newList;
    }

}

