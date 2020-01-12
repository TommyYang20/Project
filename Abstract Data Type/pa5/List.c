//Zhijun Yang
//zyang100
//pa4

#include <stdio.h>
#include <stdlib.h>
#include "List.h"

// private NodeObj type
typedef struct NodeObj{
	struct NodeObj* next;
	struct NodeObj* prev;
	int data;
}NodeObj;

// private Node type
typedef NodeObj* Node;

// private ListObj type
typedef struct ListObj{
	Node back;
	Node front;
	int length;
	Node cursor;
	int index;
}ListObj;

// newNode()
// Returns reference to new Node object. Initializes next and data fields.
// Private.
Node newNode(int data){
	Node n = malloc(sizeof(NodeObj));
	n->data = data;
	n->next = NULL;
	n->prev = NULL;
	return (n);
}

// freeNode()
// Frees heap memory pointed to by *pN, sets *pN to NULL.
// Private.
void freeNode(Node *n){
	if(n != NULL && *n != NULL){
		free(*n);
		*n = NULL;
	}
}

//newList()
List newList(void){
	List L = malloc(sizeof(ListObj));
	L->front = NULL;
	L->back = NULL;
	L->length = 0;
	L->index = -1;
	return (L);
}

//freeList()
void freeList(List *pL){
	if(pL != NULL && *pL != NULL){
		clear(*pL);
		free(*pL);
		*pL = NULL;
	}
}

// Access functions 
//length()
int length(List L){
	if(L != NULL){
		return(L->length);
	}else{
		printf("List: length() on NULL List reference\n");
		exit(1);
	}
}

//index()
int index(List L){
	if (L != NULL){
		return(L->index);
	}else{
		printf("List: index() on NULL List reference\n");
		exit(1);
	}
}

//front()
int front(List L){
	if(L->length > 0){
		return L->front->data;
	}
	if (L == NULL){
		printf("List: front() on NULL List reference\n");
		exit(1);
	}
	if (L->length == 0){
		printf("List: front() on empty list\n");
		exit(1);
	}
	return -1;
}

//back()
int back(List L){
	if(L->length > 0){
		return L->back->data;
	}
	if(L == NULL){
		printf("List: back() on NULL List reference\n");
		exit(1);
	}
	if (L->length == 0){
		printf("List: back() on empty list\n");
		exit(1);
	}
	return -1;
}

//get()
int get(List L){
	if(L->length > 0){
		return L->cursor->data;
	}
	if (L == NULL || L->index == -1){
		printf("List:get() on NULL List reference\n");
		exit(1);
	}
	if (L->length == 0){
		printf("List:get() on empty list\n");
		exit(1);
	}
	return -1;
}

//equal()
int equals(List A, List B){
	int eq = 0;
	Node N = NULL;
	Node M = NULL;

	if (A == NULL || B == NULL){
		printf("List: equals() on NULL List reference\n");
		exit(1);
	}
	eq = (A->length == B->length);
	N = A->front;
	M = B->front;
	while (eq && N != NULL){
		eq = (N->data == M->data);
		N = N->next;
		M = M->next;
	} 
	return eq;
}

// Manipulation procedures
//clear()
void clear(List L){
	if(L == NULL){
		printf("List: clear() on NULL list reference\n");
		exit(1);
	}
		L->cursor = NULL;
		L->index = -1;
		L->front = NULL;
		L->back = NULL;
		L->length = 0;
	}


//moveFront()
void moveFront(List L){
	if(L->length > 0){	
		L->cursor = L->front;
		L->index = 0;
	}
}

//moveBack()
void moveBack(List L){
	if(L->length > 0){
		L->cursor = L->back;
		L->index = L->length -1;
	}
}

//movePrev()
void movePrev(List L){
	if(L->cursor != NULL && L->cursor == L->front){
		L->cursor = NULL;
		L->index = -1;
	}
	else if(L->cursor != NULL && L->cursor != L->front){
		L->cursor = L->cursor->prev;
		L->index--;
	}
}

//moveNext()
void moveNext(List L){
	if(L->cursor != NULL && L->cursor == L->back){
		L->cursor = NULL;
		L->index = -1;
	}
	else if(L->cursor != NULL && L->cursor != L->back){
		L->cursor = L->cursor->next;
		L->index++;
	}
	else if (L->cursor == NULL){
		L->cursor = NULL;
		L->index = -1;
	}
}

//prepend()
void prepend(List L, int data){
	if (L == NULL || L->length < 0){
		printf("List:prepend() on NULL list reference\n");
		exit(1);
	}
	Node N = newNode(data);
	if (L->length > 0){
		L->front->prev = N;
		N->next = L->front;
		L->front = N;
	}
	else{
		L->front = L->back = N;
	}
	L->length++;
	L->index++;
}

//append()
void append(List L, int data){
	if (L == NULL || L->length < 0){
		printf("List:append() on NULL list reference\n");
		exit(1);
	}
	Node N = newNode(data);
	if (L->length > 0){
		L->back->next = N;
		N->prev = L->back;
		L->back = N;
	}
	else{
		L->front = L->back = N;
	}
	L->length++;
}

//insertBefore()
void insertBefore(List L, int data){
	Node N = newNode(data);
	if(L == NULL || L->length<= 0){
		printf("List:insertBefore() on NULL list reference\n");
		exit(1);
	}
	if(L->index < 0){
		printf("List:insertBefore() on empty list\n");
		exit(1);
	}
	if (L->cursor == L->front){
		prepend(L, data);
	}
	else{
		N->prev = L->cursor->prev;
		N->next = L->cursor;
		L->cursor->prev->next = N;
		L->cursor->prev = N;
		L->length++;
		L->index++;
	}
}

//insertAfter
void insertAfter(List L, int data){
	Node N = newNode(data);
	if(L == NULL || L->length<= 0){
		printf("List:insertAfter() on NULL list reference\n");
		exit(1);
	}
	if(L->index < 0){
		printf("List:insertAfter() on empty list\n");
		exit(1);
	}
	if (index(L) == L->length-1){
		append(L, data);
	}
	else{
		N->prev = L->cursor;
		N->next = L->cursor->next;
		L->cursor->next->prev = N;
		L->cursor->next = N;
		L->length++;
	}
}

//deleteFront()
void deleteFront(List L){
	Node N = L->front;
	if(L == NULL || L->length <= 0){
		printf("List:deleteFront() on NULL list reference\n");
		exit(1);
	}
	else{
		if(L->length == 1){
			clear(L);
		}
		else{
			if(L->cursor == L->front){
				L->cursor = NULL;
				L->index = -1;
		}else if (L->cursor != NULL){
			L->index--;
		}
			L->front = L->front->next;
			//L->front->prev->next = NULL;
			L->front->prev = NULL;
			L->length--;
		}
	}
	freeNode(&N);
}

//deleteBack()
void deleteBack(List L){
	if(L == NULL || L->length <= 0){
		printf("List:deleteFront() on NULL list reference\n");
		exit(1);
	}
	Node N = L->back;
	if(L->length == 1){
		clear(L);
	} else if (L->length > 0){
		if(L->cursor == L->back){
			L->index = -1;
		}
		L->back = L->back->prev;
		if(L->back !=NULL){
			L->back->next = NULL;
		}
		L->length--;
	}else{
		L->back = NULL;
	}
	freeNode(&N);
}

//delete
void delete(List L){
	Node N = NULL;
	if(L == NULL || L->length <= 0){
		printf("List:delete() on NULL list reference\n");
		exit(1);
	}
	if(L->index < 0){
		printf("List:delete() on empty list\n");
		exit(1);
	}
	if(L->cursor == L->front){
		deleteFront(L);
		return;
	}else if (L->cursor == L->back){
		deleteBack(L);
		return;
	}else
	{
		L->cursor->next->prev = L->cursor->prev;
		L->cursor->prev->next = L->cursor->next;
		L->cursor = NULL;
		L->index = -1;
		L->length--;
	}
	freeNode(&N);
}

// Other operations 
void printList(FILE *out, List L){
	Node N = NULL;
	if(L == NULL){
		printf("List: printList on NULL list reference\n");
		exit(1);
	}
	N = L->front;
	while(N!=NULL){
		fprintf(out ,"%d ", N->data);
		N = N->next;
	}
}

List copyList(List L){
	List temp = newList();
	if(L->length == 0){
		return temp;
	}
	Node tempNode = NULL;
	for(tempNode = L->front; tempNode->next!= NULL; tempNode = tempNode->next){
		append(temp,tempNode->data);
	}
	append(temp, tempNode->data);
	return temp;
}
















