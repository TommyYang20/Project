//Zhijun Yang
//zyang100
//pa4



#include<stdio.h>
#include<stdlib.h>
#include"Graph.h"

int main(int argc, char* argv[]){
   Graph G = NULL;
   int n = 5;

   G = newGraph(n);
 
   addEdge(G, 1, 2);
   addEdge(G, 1, 3);
   addEdge(G, 2, 6);
   addEdge(G, 5, 6);
   addEdge(G, 7, 8)

   printGraph(stdout, G);
   printf("Order: %d\nSize: %d\n", getOrder(G), getSize(G));
   addArc(G, 3, 5);
   printGraph(stdout, G);
   printf("Size:%d\n", getSize(G));
   addArc(G, 4, 6);
   printGraph(stdout, G);
   printf("Size:%d\n", getSize(G));

   BFS(G,1);
   getPath(C,G,5);
   printf("distance to 5:%d\n", getDist(G,5));
   printList(stdout,C);
   printf("\n");

   BFS(G,3);
   getPath(C,G,5);
   printf("distance to 5:%d\n", getDist(G,5));
   printList(stdout,C);
   printf("\n");


   freeGraph(&G);

   return(0);
}