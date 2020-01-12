//Zhijun Yang
//zyang100
//pa4

#include<stdio.h>
#include<stdlib.h>
#include"List.h"

typedef struct NodeObj{
	int data;
	struct NodeObj* prev;
	struct NodeObj* next;
}NodeObj;

typedef NodeObj* Node;

typedef struct ListObj{
	Node front;
	Node back;
	Node cursor;
	int index;
	int length;
}ListObj;

void freeNode(Node *n){
	if (n != NULL && *n != NULL){
		free(*n);
		*n = NULL;
	}
}

Node newNode(int data){
	Node newNode = malloc(sizeof(NodeObj));
	newNode->data = data;
	newNode->next = NULL;
	newNode->prev = NULL;
	return (newNode);
}

List newList(void){
	List L;
	L = malloc(sizeof(ListObj));
	L->front = NULL;
	L->back = NULL;
	L->cursor = NULL;
	L->length = 0;
	L->index = -1;
	return(L);
}

void freeList(List* pL){
	if (pL != NULL && *pL != NULL){
		clear(*pL);
		free(*pL);
		*pL = NULL;
	}
}

int length(List L){
	if (L != NULL){
		return (L->length);
	}else{
		printf("List error: length() is NULL");
		exit(1);
	}
}

int index(List L){
	if (L != NULL){
		return (L->index);
	}else{
		printf("List error: index() is NULL");
		exit(1);
	}
}

int front(List L){
	if (L != NULL){
		return (L->front->data);
	}else{
		printf ("List error: front() is NULL");
		exit(1);
	}
}

int back(List L){
	if (L != NULL){
		return (L->back->data);
	}else{
		printf("List error: back() is NULL");
		exit(1);
	}
}

int get(List L){
	if (L == NULL){
		printf("List error: Null list");
		exit(1);
	}
	if (length(L) <= 0){
		printf("List error: get() is NULL");
		exit(1);
	}
	if (L->index == -1){
		printf("List error: index() is NULL");
		exit(1);
	}
		return L->cursor->data;
}

int equals(List A, List B){
	if (A == NULL || B == NULL){
		printf("List error: equals() is NULL");
	}
	Node aNode = A->front;
	Node bNode = B->front;

	if (length (A) != length(B))
		return 0;
	while (aNode != NULL){
		if (aNode->data != bNode->data){
			aNode = bNode = NULL;
			return 0;
		}
		else{
			aNode = aNode->next;
			bNode = bNode->next;
		}
	}
	return 1;
}

void clear(List L){
	L->front = L->back = L->cursor = NULL;
	L->length = 0;
	L->index = -1;
}

void moveFront(List L){
	if(L == NULL){
		printf("List error: moveFront() is NULL");
		exit(1);
	}
	if (L->length > 0){
		L->cursor = L -> front;
		L->index = 0;
	}
}

void moveBack(List L){
	if (L == NULL){
		printf("List error: moveBack() is NULL");
		exit(1);
	}
	if (L->length > 0){
		L->cursor = L->back;
		L->index = L->length - 1;
	}
}

void movePrev(List L){
	if(L == NULL){
		printf("List error: movePrev is NULL");
		exit(1);
	}
	if (L->cursor != NULL && L->cursor != L->front){
		L->cursor = L->cursor -> prev;
		L->index--;
	}
	else if (L->cursor != NULL && L->cursor == L->front){
		L->cursor = NULL;
		L->index = -1;
	}
}

void moveNext(List L){
	if(L == NULL){
		printf("List error: moveNext is NULL");
		exit(1);
	}
	if(L->cursor != NULL && L-> cursor != L->back){
		L->cursor = L->cursor-> next;
		L->index++;
	}
	else if (L->cursor != NULL && L->cursor == L->back){
		L->cursor = NULL;
		L->index= -1;
	}
}

void prepend(List L, int data){
	if(L == NULL){
		printf("List error: prepend is NULL");
		exit(1);
	}
	Node N = newNode(data);
	if(L-> length == 0){
		L->front = L->back = N;
	} 
	else{
		N->next = L->front;
		L->front->prev = N;
		L->front = N;
	}
	L-> length++;
	L-> index++;
}

void append(List L, int data){
	if(L == NULL){
		printf("List error: append() is NULL");
		exit(1);
	}
	Node N = newNode(data);
	if (L->length == 0){
		L->front = L->back = N;
	} 
	else{
		N->prev = L ->back;
		L->back->next  = N;
		L->back = N;
	}
	L->length++;
}

void insertBefore(List L, int data){
	if(L->length<= 0){
		printf("List error: insertBefore() is empty");
		exit(1);
	}
	if (L->index < 0){
		printf ("List error: insertBefore() when index is less than 0");
		exit(1);
	}
	if (index(L) == 0) {
		prepend(L,data);
	}
	else{
		Node N = newNode(data);
		N->prev = L->cursor->prev;
		N->next = L->cursor;
		L->cursor->prev->next = N;
		L->cursor->prev = N;
		L->index++;
		L->length++;
	}
}

void insertAfter(List L, int data){
	if (L->length <= 0){
		printf("List error: insertAfter() is empty");
		exit(1);
	}
	if (L->index < 0){
		printf ("List error: insertAfter() when index is less than 0");
		exit(1);
	}
	if (index(L) == L->length-1) {
		append(L,data);
	}
	else{
		Node N = newNode(data);
		N->prev = L->cursor;
		N->next = L->cursor->next;
		L->cursor->next->prev = N ;
		L->cursor->next = N;
		L->length++;
	}
}

void deleteFront(List L){
	if(L == NULL){
		printf("List error: deleteFront() is NULL");
		exit(1);
	}
	if(L->length <= 0){
		printf("List error: deleteFront() is empty");
		exit(1);
	}
	Node N = L->front;
	if(L->length == 1){
		L->front = L->back = L->cursor = NULL;
		L->length = 0;
		L->index = -1;
	}
	else{
		 if (L->cursor == L->front){
			L->cursor = NULL;
			L->index = -1;
		}
		else if(L->cursor!= NULL){
			L->index--;
		}
		L->front = L->front->next;
		L->front->prev = NULL;
		L->length--;
	}
	freeNode(&N);
}

void deleteBack(List L){
	if(L == NULL){
		printf("List error: deleteBack() is NULL");
		exit(1);
	}
	if (L->length <= 0){
		printf("List error: deleteBack() is empty");
		exit(1);
	}
	Node N = L->back;
	if(L->length == 1){
		L->front = L->back = L->cursor = NULL;
		L->length = 0;
		L->index = -1;
	}
	else if (L->cursor == L->back){
			L->cursor = NULL;
			L->index = -1;
		}
		else{
		L->back = L->back->prev;
			if (L->back != NULL){
				L->back->next = NULL;
			}
		L->length--;
		}
	freeNode(&N);
}

void delete(List L){
	Node N = NULL;
	if(L == NULL){
		printf("List error: delete() is NULL");
	}
	if(L->length<=0){
		printf("List error: delete() is empty");
		exit(1);
	}
	if(L->index<0){
		printf("List error: delete() when index is less than 0");
		exit(1);
	}
	N = L ->cursor;
	if(L->cursor == L->back){
		deleteBack(L);
		return;
	}
	else if(L->cursor == L->front){
		deleteFront(L);
		return;
	}
	else{
		L->cursor->next->prev = L->cursor->prev;
		L->cursor->prev->next = L->cursor->next;
		L->index=-1;
		L->cursor = NULL;
		L->length--;
		freeNode(&N);
	}
}

void printList(FILE* out, List L){
	if(L->length <= 0){
		return;
	}
	Node N =  NULL;
	if(L == NULL){
		fprintf(out,"List error: printList() is NULL");
		exit(1);
	}
	if(out == NULL){
		printf("List error: printlist() on null file");
		exit(1);
	}
	for(N = L->front ; N!= NULL; N = N->next){
		fprintf(out, "%d", N->data);
	}
}

List copyList(List L){
	List l = newList();
	if (L == NULL){
		printf("List error: copyList() is NULL");
		exit(1);
	}
	if (L->length <= 0){
		return l;
	}
	Node N = L->front;
	while(N!= NULL){
		append(l, N->data);
		N = N->next;
	}
	return l;
}



