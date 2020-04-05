#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

#define PORT 8868
#define BUF_SIZE 4096

int processHttpRequest(int requestFd, char* response);
void returnHttpResponse(int clientSocketFd, char* response, int responseFd);
void getHttpStatusString(int statusCode, char* httpStatusString);
void getHttpStatusHeader(int statusCode, char* header, const int* contentLength);
int get(char* pathParameter, char* header);
int putInit(char* pathParameter, int requestFd, char* header);
int putDataHandler(int uploadedFileFd, int requestFd, const int* contentLength, char* header);
int isValidRequestPath(char* path);


int main() {

    int serverSocketFd = serverSocketFd = socket(AF_INET, SOCK_STREAM,0);
    //set up the server socket
    struct sockaddr_in serverAddress;
    serverAddress.sin_family = AF_INET;
    serverAddress.sin_port = htons(PORT);
    serverAddress.sin_addr.s_addr = INADDR_ANY;

    bind(serverSocketFd,(struct sockaddr*) &serverAddress, sizeof(struct sockaddr_in));
    //listen to the port
    listen(serverSocketFd, 16);

    while (1) {
        // allocate space for request header and response header
        char request[BUF_SIZE];
        char response[BUF_SIZE];
        bzero(request, BUF_SIZE);
        bzero(response, BUF_SIZE);
        struct sockaddr_in clientAddress;

        int clientSocketFd;
        int clientAddressLength = sizeof(struct sockaddr_in);
        clientSocketFd = accept(serverSocketFd, (struct sockaddr *) &clientAddress, (socklen_t*) &clientAddressLength);

        int responseFd = processHttpRequest(clientSocketFd, response);

        returnHttpResponse(clientSocketFd, response, responseFd);

        close(clientSocketFd);
    }

    close(serverSocketFd);

    return 0;
}
// process HTTP request, read requestFd, two methods one is get and one is put.
int processHttpRequest(int requestFd, char* response) {

    char request[BUF_SIZE];

    // assume header is smaller than BUF_SIZE
    read(requestFd, request, BUF_SIZE);
    printf("%s",request);
    char method[16];
    bzero(method, 16);

    char path[256];
    bzero(path, 256);

    char* fileName;

    int contentLength = -1;

    const char deliminators[3] = "\r\n";
    char* token;

    // first line
    token = strtok(request, deliminators);
    sscanf(request, "%s %s", method, path);

    // browsers add / to path. make an exception for them to use this character at the beginning of the path.
    if (path[0] == '/') {
        fileName = &path[1];
    } else {
        fileName = path;
    }

    // if file name is not correct, return bad request
    if (!isValidRequestPath(fileName)) {
        getHttpStatusHeader(400, response, NULL);
        return -1;
    }

    // find if there is a Content-Length attribute
    while(token != NULL) {
        sscanf(token, "Content-Length: %d", &contentLength);
        token = strtok(NULL, deliminators);
        if (contentLength > 0) {
            break;
        }
    }
    

    if (strcmp(method, "GET") == 0) { return get(fileName, response); }
    if (strcmp(method, "PUT") == 0) {
        int uploadedFileFd = putInit(fileName, requestFd, response);
        return putDataHandler(uploadedFileFd, requestFd, &contentLength, response);
    }

    return -1;

}

//check the URL it matches the format, and it also check the length of filename, if it meatches return true, otherwise return false
int isValidRequestPath(char* path) {
    char compare[256];
    bzero(compare, 256);
    sscanf(path, "%[a-zA-Z_-]", compare);
    return strcmp(path, compare) == 0 && strlen(path) == 27;
}

//get request, open the file first, check if the htmlfd exists and return -1, return the filedescriptor of file
int get(char* pathParameter, char* header) {

    int htmlFd = open(pathParameter, O_RDONLY);

    if (htmlFd < 0) {
        getHttpStatusHeader(404,header, NULL);
        return -1;
    }

    // get file size for contentLength
    struct stat htmlStat;
    fstat(htmlFd, &htmlStat);
    int contentLength = htmlStat.st_size;

    getHttpStatusHeader(200,header, &contentLength);
    strcat(header, "\r\n");

    return htmlFd;
}

//create a new file, write requestFd to header, also, file descriptor is to store teh data from the request

int putInit(char* pathParameter, int requestFd, char* header) {

    int uploadedFileFd = creat(pathParameter, 0644); // TODO: deal with file already existed

    if (uploadedFileFd < 0){
        uploadedFileFd = open(pathParameter, O_WRONLY | O_CREAT, 0644);
    }

    if (uploadedFileFd < 0){
        getHttpStatusHeader(500,header, NULL);
        return -1;
    }

    getHttpStatusHeader(100, header, NULL);
    write(requestFd, header, strlen(header));

    return uploadedFileFd;
}
//uploadedFileFd is to store the data, read requestFd and write it to uploadedFileFd.
int putDataHandler(int uploadedFileFd, int requestFd, const int* contentLength, char* header) {

    size_t n;
    char buffer[BUF_SIZE];

    if (!contentLength) {
        while((n=read(requestFd, buffer, BUF_SIZE))>0) {
            write(uploadedFileFd, buffer, n);
        }
    } else {
        size_t cl = *contentLength;
        while(cl>0 && (n=read(requestFd, buffer, BUF_SIZE))>0){
            if (cl < n){
                write(uploadedFileFd,buffer,cl);
            }else{
                write(uploadedFileFd, buffer, n);
            }
            cl -=n;
        }
    }
    close(uploadedFileFd);
    getHttpStatusHeader(201, header, NULL);

    return -1;
}
// send the response to client, it responses the http respond to be send
void returnHttpResponse(int clientSocketFd, char* response, int responseFd) {
    write(clientSocketFd, response, strlen(response));
    if (responseFd <= 1) {
        return;
    }
    char buffer[BUF_SIZE];
    size_t n;
    while((n = read(responseFd, buffer, strlen(response))) > 0){
        write(clientSocketFd, buffer, n);
    }
}

//different status code
void getHttpStatusString(int statusCode, char* httpStatusString) {
    if (statusCode == 100) { strcpy(httpStatusString, "100 Continue");              return; }
    if (statusCode == 200) { strcpy(httpStatusString, "200 OK");                    return; }
    if (statusCode == 201) { strcpy(httpStatusString, "201 Created");               return; }
    if (statusCode == 400) { strcpy(httpStatusString, "400 Bad Request");           return; }
    if (statusCode == 403) { strcpy(httpStatusString, "403 Forbidden");           return; }
    if (statusCode == 404) { strcpy(httpStatusString, "404 Not Found");             return; }
    if (statusCode == 500) { strcpy(httpStatusString, "500 Internal Server Error"); return; }
}
//a print out with status code, content length and header.
void getHttpStatusHeader(int statusCode, char* header, const int* contentLength) {
    char httpStatus[64];

    getHttpStatusString(statusCode, httpStatus);

    if (contentLength) {
        sprintf(header, "HTTP/1.1 %s\r\nContent-Length: %d\r\n", httpStatus, *contentLength);
    } else {
        sprintf(header, "HTTP/1.1 %s\r\n", httpStatus);
    }

}