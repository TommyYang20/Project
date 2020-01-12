//Zhijun Yang
//zyang100
//pa4

#include <stdio.h>
#include <stdlib.h>
#include "Graph.h"
#include "List.h"

typedef struct GraphObj{
	int* parent;
	int* distance;
	int order;
	int size;
	int source;
	List* adj;
	char* color;
}GraphObj;

Graph newGraph(int n){
	if (n<1) {
		printf("Graph error:newGraph is invalid");
		exit(1);
	}
	Graph G = malloc(sizeof(GraphObj));
	G->size = 0;
	G->order = n;
	G->source = NIL;
	G->color = calloc((n+1), sizeof(char));
	G->parent = calloc((n+1), sizeof(int));
	G->adj = calloc((n+1), sizeof(List));
	G->distance = calloc((n+1), sizeof(int));
	
	int i = 1;
	while(i <= n){
		G->adj[i] = newList();
		G->parent[i] = NIL;
		G->distance[i] = INF;
		G->color[i] = 'w';
		i++;
	}
	return G;
}

void freeGraph(Graph* pG){
	int i = 1;
		while(i <=getOrder(*pG)){
			freeList(&(*pG)->adj[i]);
			free((*pG)->adj[i]);
			i++;
		}
	free((*pG)->adj);
	free((*pG)->parent);
	free((*pG)->color);
	free((*pG)->distance);
	free(*pG);
	(*pG) = NULL;
}

int getOrder(Graph G){
	if(G!=NULL){
		return G->order;
	}else{
		printf("Error: getOrder is NULL");
		exit(1);
	}
}
int getSize(Graph G){
	if(G!=NULL){
		return G->size;
	}else{
		printf("Error: getSize is NULL");
		exit(1);
	}
}
int getSource(Graph G){
	if (G != NULL) {
		return G->source;
	} else {
		printf("Error: getSource is NULL");
		exit(1);
	}
}

int getParent(Graph G, int u){
	if(G == NULL){
		printf("Error: getParent is NULL");
		exit(1);
	}else{
		if ((0 >= u) || (u > G->order)){
			printf("Error: getParent is invalid");
			exit(1);
		}
	}	
	return G->parent[u];
}

int getDist(Graph G, int u){
	if(getSource(G) == NIL){
		return INF;
	}else{
		if ((0 >= u) || u > (G->order)){
			printf("Error: getDist is invalid");
			exit(1);
		}	
	}
	return G->distance[u];
}

void getPath(List L, Graph G, int u){
	if( 1 > u || u > G->order ){
		printf("Error: getPath is invalid");
		exit(1);
	}
	if(getSource(G) == NIL){
		printf("Error: getPath is NIL");
		exit(1);
	}
	if(getSource(G) == u){
		append(L, getSource(G));
	} 
	else if (getParent(G,u) == NIL){
		append(L, NIL);
	}
	else{
		getPath(L, G, getParent(G,u));
		append(L, u);
	}
}

void makeNull(Graph G){
	if (G == NULL){
		printf("Error: makeNull is NULL");
		exit(1);
	}
	else if (G != NULL){
		for(int i = 1; i < getOrder(G); i++){
			clear(G->adj[i]);
	}
		G->size = 0;
	}else{
		printf("Error: makeNull is NULL");
		exit(1);
	}
}

void addEdge (Graph G, int u, int v){
	if (G == NULL){
		printf("Error: addEdge is NULL");
		exit(1);
	}else{
		if (1 > u || 1 > v){
			printf("Error: addEdge has invalid indices\n");
			exit(1);
		}
		if (u > getOrder(G) || v > getOrder(G)){
			printf("Error: addEdge is out of bound\n");
			exit(1);
		}
	}
	addArc(G, u , v);
	addArc(G, v, u);
	G->size--;
}

void addArc(Graph G, int u, int v){
	if(G == NULL){
		printf("Error: addArc is NULL");
		exit(1);
	}else{
		if (1 > u || 1 > v ){
			printf("Error: addArc has invalid indices");
			exit(1);
		}
		if (u > getOrder(G) || v > getOrder(G)){
			printf("Error:addArc is out of bound\n");
			exit(1);
		}
	}
	List L = G->adj[u];

	moveFront(L);
	while(index(L)!= -1 && v > get(L)){
		moveNext(L);
	}
	if (index(L) == -1){
		append(L, v);
	}
	else{
		insertBefore(L, v);
	}
	G->size++;
}

void BFS(Graph G, int s){
	if (G == NULL){
		printf("Error: BFS is NULL");
		exit(1);
	}
	if(s > getOrder(G)){
		printf("Error: BFS is out of bound");
		exit(1);
	}
	if (1 > s){
		printf("Error: BFS is less than 1");
		exit(1);
	}
	for(int i = 1; i <= G->order; i++){
		G->color[i] = 'w';
		G->distance[i] = INF;
		G->parent[i] = NIL;
	}
	G->source = s;
	G->color[s] = 'g';
	G->parent[s] = NIL;
	G->distance[s] =  0;

	List Q = newList(); 
	prepend(Q, s);

	while(length(Q) > 0){
		int u = back (Q);
		deleteBack(Q);
		List adj = G->adj[u];
		moveFront(adj);
		while (index(adj)!= -1){
			int v = get(adj);
			if (G->color [v] == 'w'){
				G->color[v] = 'g';
				G->parent[v] = u;
				G->distance[v] = G->distance[u] + 1;
				prepend(Q, v);
			}
			moveNext(G->adj[u]);
		}
		G->color[u] = 'b';
	}
	freeList(&Q);
}

void printGraph(FILE* out, Graph G){
	if(G == NULL){
		printf("Error: Graph is NULL");
		exit(1);
	}
	if (out == NULL){
		printf("Error: printGraph is NULL");
		exit(1);
	}

	for (int i = 1; i <= getOrder(G); i++){
		fprintf(out,"%d:", i);
		printList(out, G->adj[i]);
		fprintf(out, "\n");
	}
}








