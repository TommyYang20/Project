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
#include <list>
#include <vector>
#include <pthread.h>
#include <semaphore.h>

#define PORT 8840
#define BUF_SIZE 4096
#define CACHE_SIZE 4

void processHttpRequest(int requestFd, char* response, char* log);

void getHttpStatusString(int statusCode, char* httpStatusString);
void getHttpStatusHeader(int statusCode, char* header, const int* contentLength);
int get(char* pathParameter, char* header, char* log);
int putInit(char* pathParameter, int requestFd, char* header, char* log);
int putDataHandler(int uploadedFileFd, int requestFd, const int* contentLength, char* header, char* log, char* fileName);
int isValidRequestPath(char* path);

int findInCache(char* fileName);
bool readFile(int destFd, char* fileName);
void readFileAndCache(int destFd, int srcFd, char* fileName);
void writeFile(char* fileName, int fd, unsigned int length);
void updateLRU(unsigned int index);
unsigned int replaceCache(char* fileName);

/**
 * A cache entry along with its meta data
 */
typedef struct {

    // Least Recently Used tag
    int lru = CACHE_SIZE;

    // file name of this data
    char* fileName = nullptr;

    // length of data
    int length = 0;

    // Actual data
    std::list<char*> data;

} CacheEntry;

CacheEntry* cache;

bool cacheEnabled = false;

pthread_mutex_t logWriterLock = PTHREAD_MUTEX_INITIALIZER;
bool writing = false;

std::list<int> taskQueue;
pthread_mutex_t taskQueueLock = PTHREAD_MUTEX_INITIALIZER;

std::vector<pthread_t> workers;
sem_t workerMutex;
sem_t taskMutex;

unsigned int workerCount = 1;

unsigned int loggerFd;
char* loggerName;
bool logEnabled = false;

void writeLog(char* content) {
    while (writing) {
        pthread_mutex_lock(&logWriterLock);
    }
    writing = true;
    write(loggerFd, content, strlen(content));
    writing = false;
    pthread_mutex_unlock(&logWriterLock);
}

void enqueue(unsigned int clientFd) {
    pthread_mutex_lock(&taskQueueLock);
    taskQueue.push_front(clientFd);
    pthread_mutex_unlock(&taskQueueLock);
}

int dequeue() {
    pthread_mutex_lock(&taskQueueLock);
    int clientFd;
    if (!taskQueue.empty()) { // should not happen
        clientFd = taskQueue.back();
        taskQueue.pop_back();
    }
    pthread_mutex_unlock(&taskQueueLock);
    return clientFd;
}

void dispatch(unsigned int clientFd) {
    enqueue(clientFd);
    sem_post(&taskMutex);
}

void* processor(void* arg) {
    while(true) {
        while (taskQueue.empty()) {
            sem_wait(&taskMutex);
        }
        int clientSocketFd = dequeue();

        char response[BUF_SIZE];
        bzero(response, BUF_SIZE);

        char log[BUF_SIZE];

        sleep(1);

        processHttpRequest(clientSocketFd, response, log);

        close(clientSocketFd);

        if (logEnabled) {
            writeLog(log);
        }

    }
}

int main(int argc, char **argv) {

    // init cache
    cache = new CacheEntry[4];

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-c") == 0) {
            cacheEnabled = true;
        }
        if (strcmp(argv[i], "-N") == 0) {
            workerCount = atoi(argv[i + 1]);
            if (workerCount < 1) {
                workerCount = 1;
            }
        }
        if (strcmp(argv[i], "-l") == 0) {
            logEnabled = true;
            if (i + 1 < argc) {
                loggerName = argv[i + 1];
            } else {
                return -1;
            }
        }
    }

    if (logEnabled) {
        loggerFd = open(loggerName, O_WRONLY | O_CREAT | O_APPEND, 0644);
    }

    for (int i = 0; i < workerCount; i++) {
        workers.push_back(pthread_t());
    }
    sem_init(&workerMutex, 0, workerCount);
    sem_init(&taskMutex, 0, 0);
    for(auto& worker : workers) {
        pthread_create(&worker, nullptr, processor, nullptr);
    }

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
        bzero(request, BUF_SIZE);
        struct sockaddr_in clientAddress;

        int clientSocketFd;
        int clientAddressLength = sizeof(struct sockaddr_in);
        clientSocketFd = accept(serverSocketFd, (struct sockaddr *) &clientAddress, (socklen_t*) &clientAddressLength);
        dispatch(clientSocketFd);
    }

    close(serverSocketFd);

    return 0;
}
// process HTTP request, read requestFd, two methods one is get and one is put.
void processHttpRequest(int requestFd, char* response, char* log) {

    char request[BUF_SIZE];
    char partialLog[BUF_SIZE];
    int result = -1;

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
        sprintf(log, "FAIL: %s, --- response %d\n========\n", request, 400);
    } else {
        strcpy(partialLog, request);

        // find if there is a Content-Length attribute
        while(token != NULL) {
            sscanf(token, "Content-Length: %d", &contentLength);
            token = strtok(NULL, deliminators);
            if (contentLength > 0) {
                break;
            }
        }

        char formatBuffer[BUF_SIZE];
        if (contentLength > 0) {
            sprintf(formatBuffer, "%s length %d %s",
                    request,
                    contentLength,
                    cacheEnabled ? (findInCache(fileName) == -1 ? "[was not in cache]" : "[was in cache]") : "");
            strcpy(partialLog, formatBuffer);
        } else {
            sprintf(formatBuffer, "%s %s",
                    request,
                    cacheEnabled ? (findInCache(fileName) == -1 ? "[was not in cache]" : "[was in cache]") : "");
            strcpy(partialLog, formatBuffer);
        }


        if (strcmp(method, "GET") == 0) {
            result = get(fileName, response, partialLog);
            sprintf(log, "%s\n========\n", partialLog);
        }
        if (strcmp(method, "PUT") == 0) {
            int uploadedFileFd = putInit(fileName, requestFd, response, partialLog);
            result = putDataHandler(uploadedFileFd, requestFd, &contentLength, response, partialLog, fileName);
            sprintf(log, "%s\n========\n", partialLog);
        }
    }

    write(requestFd, response, strlen(response));

    // in case of no body
    if (result < 0) {
        return;
    } else if (result == 0) { // in case of cache hit
        readFile(requestFd, fileName);

    } else {
        if (cacheEnabled) {
            readFileAndCache(requestFd, result, fileName);
        } else {
            char buffer[BUF_SIZE];
            size_t n;
            while((n = read(result, buffer, strlen(response))) > 0){
                write(requestFd, buffer, n);
            }
        }
    }
}

//check the URL it matches the format, and it also check the length of filename, if it meatches return true, otherwise return false
int isValidRequestPath(char* path) {
    char compare[256];
    bzero(compare, 256);
    sscanf(path, "%[0-9a-zA-Z_-]", compare);
    return strcmp(path, compare) == 0 && strlen(path) == 27;
}

//get request, open the file first, check if the htmlfd exists and return -1, return the filedescriptor of file
int get(char* pathParameter, char* header, char* log) {

    int contentLength;

    // if result is 0, cache will be used. otherwise it will be a fd to the file
    int result = 0;

    // if cache is not enabled or content is not in cache
    if (!cacheEnabled || findInCache(pathParameter) == -1) {
        int htmlFd = open(pathParameter, O_RDONLY);

        if (htmlFd < 0) {
            getHttpStatusHeader(404,header, NULL);
            char logBuffer[BUF_SIZE];
            strcpy(logBuffer, log);
            sprintf(log, "FAIL: %s, --- response %d\n========\n", logBuffer, 400);
            return -1;
        }

        // get file size for contentLength
        struct stat htmlStat;
        fstat(htmlFd, &htmlStat);
        contentLength = htmlStat.st_size;

        result = htmlFd;
    }

    // peek into the meta data of cache
    if (findInCache(pathParameter) != -1) {
        contentLength = cache[findInCache(pathParameter)].length;
    }

    getHttpStatusHeader(200,header, &contentLength);
    strcat(header, "\r\n");

    return result;
}

//create a new file, write requestFd to header, also, file descriptor is to store teh data from the request

int putInit(char* pathParameter, int requestFd, char* header, char* log) {

    int uploadedFileFd = creat(pathParameter, 0644); // TODO: deal with file already existed

    if (uploadedFileFd < 2){
        uploadedFileFd = open(pathParameter, O_WRONLY | O_CREAT, 0644);
    }

    if (uploadedFileFd < 2){
        getHttpStatusHeader(500,header, NULL);
        char logBuffer[BUF_SIZE];
        strcpy(logBuffer, log);
        sprintf(log, "FAIL: %s, --- response %d\n========\n", logBuffer, 500);
        return -1;
    }

    getHttpStatusHeader(100, header, NULL);
    write(requestFd, header, strlen(header));

    return uploadedFileFd;
}

//uploadedFileFd is to store the data, read requestFd and write it to uploadedFileFd.
int putDataHandler(int uploadedFileFd, int requestFd, const int* contentLength, char* header, char* log, char* fileName) {

    size_t n;
    unsigned char buffer[BUF_SIZE];

    while (writing) {
        pthread_mutex_lock(&logWriterLock);
    }
    writing = true;
    if (logEnabled) {
        write(loggerFd, log, strlen(log));
        bzero(log, BUF_SIZE);
    }

    int i = 0;

    // always find new block, even if it is a hit (this is 0 in case where cache is not enabled)
    unsigned int index = replaceCache(fileName);

    if (!contentLength) {
        while((n=read(requestFd, buffer, BUF_SIZE))>0) {

            if (logEnabled) {
                for (int j = 0; j < n; j++, i++) {
                    if (i % 20 == 0) {
                        write(loggerFd, log, strlen(log));
                        bzero(log, BUF_SIZE);
                        char tmp[16];
                        sprintf(tmp, "\n%8.8d ", i);
                        strcat(log, tmp);
                    }

                    char tmp[4];
                    sprintf(tmp, "%2.2x ", buffer[i % BUF_SIZE]);
                    strcat(log, tmp);
                }
            }

            if (cacheEnabled) {
                char* newPage = new char[n];
                memcpy(newPage, buffer, n);
                cache[index].data.push_back(newPage);
                cache[index].length += n;
            }

            write(uploadedFileFd, buffer, n);
        }
    } else {
        size_t cl = *contentLength;

        while(cl>0 && (n=read(requestFd, buffer, BUF_SIZE))>0){

            if (logEnabled) {
                for (int j = 0; j < cl && j < n; j++, i++) {
                    if (i % 20 == 0) {
                        write(loggerFd, log, strlen(log));
                        bzero(log, BUF_SIZE);
                        char tmp[16];
                        sprintf(tmp, "\n%8.8d ", i);
                        strcat(log, tmp);
                    }

                    char tmp[4];
                    sprintf(tmp, "%2.2x ", buffer[i % BUF_SIZE]);
                    strcat(log, tmp);
                }
            }

            if (cl < n){
                char* newPage = new char[cl];
                memcpy(newPage, buffer, cl);
                cache[index].data.push_back(newPage);
                cache[index].length += cl;
                write(uploadedFileFd,buffer,cl);
            }else{
                char* newPage = new char[n];
                memcpy(newPage, buffer, n);
                cache[index].data.push_back(newPage);
                cache[index].length += n;
                write(uploadedFileFd, buffer, n);
            }
            cl -=n;
        }
    }
    close(uploadedFileFd);

    writing = false;
    pthread_mutex_unlock(&logWriterLock);

    getHttpStatusHeader(201, header, NULL);

    return -1;
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

/**
 * Try reading file from cache.
 *
 * @param destFd the destination file descriptor
 * @param fileName the name of the file to be read
 * @return true if cache hit, false otherwise
 */
bool readFile(int destFd, char* fileName) {
    unsigned int i = 0;
    for (; i < CACHE_SIZE; i++) {
        if (strcmp(cache[i].fileName, fileName) == 0) {
            int remainSize = cache[i].length;

            for (char* page : cache[i].data) {

                // page size
                int size = 0;

                if (remainSize < BUF_SIZE) {
                    size = remainSize;
                } else {
                    size = BUF_SIZE;
                }

                remainSize -= size;
                write(destFd, page, size);
            }

            updateLRU(i);
            return true;
        }
    }
    return false;
}

/**
 * @return the index of new cache block
 */
unsigned int replaceCache(char* fileName) {

    if (!cacheEnabled) {
        return 0;
    }

    // find new slot
    unsigned int index = 0;
    int maxLRU = -1;
    for (unsigned int i = 0; i < CACHE_SIZE; i++) {
        if (cache[i].fileName != nullptr && strcmp(cache[i].fileName, fileName) == 0) {
            index = i;
            break;
        }
        if (cache[i].lru > maxLRU) {
            maxLRU = cache[i].lru;
            index = i;
        }
    }

    // update LRU
    updateLRU(index);

    // free old memory
    if (cache[index].fileName != nullptr) {
        for (auto page : cache[index].data) {
            delete page;
        }
        cache[index].data.clear();
    }

    cache[index].length = 0;
    cache[index].fileName = fileName;

    return index;
}

void writeFile(char* fileName, int fd, unsigned int length) {

    unsigned int index = replaceCache(fileName);

    // write data to cache
    int n = 0;
    char buffer[BUF_SIZE];
    if (!length) {
        while ((n=read(fd, buffer, BUF_SIZE)) > 0) {
            char* newPage = new char[n];
            memcpy(newPage, buffer, n);
            cache[index].data.push_back(newPage);
            cache[index].length += n;
        }
    } else {
        int remainingLength = length;
        while (remainingLength > 0 && (n=read(fd, buffer, BUF_SIZE)) > 0) {
            if (remainingLength < n) {
                char* newPage = new char[remainingLength];
                memcpy(newPage, buffer, remainingLength);
                cache[index].data.push_back(newPage);
                cache[index].length += remainingLength;
            } else {
                char* newPage = new char[n];
                memcpy(newPage, buffer, n);
                cache[index].data.push_back(newPage);
                cache[index].length += n;
            }
            remainingLength -= n;
        }
    }


}

void readFileAndCache(int destFd, int srcFd, char* fileName) {

    unsigned int index = replaceCache(fileName);

    char buffer[BUF_SIZE];
    size_t n;
    int totalSize = 0;
    while((n = read(srcFd, buffer, BUF_SIZE)) > 0){
        char* newPage = new char[n];
        memcpy(newPage, buffer, n);
        cache[index].data.push_back(newPage);
        totalSize += n;
        write(destFd, buffer, n);
    }
    cache[index].length = totalSize;

}

void updateLRU(unsigned int index) {
    int thisLRU = cache[index].lru;
    for (unsigned int i = 0; i < CACHE_SIZE; i++) {
        if (cache[i].lru < thisLRU) {
            cache[i].lru++;
        }
    }
    cache[index].lru = 0;
}

int findInCache(char* fileName) {
    for (int i = 0; i < CACHE_SIZE; i++) {
        if (cache[i].fileName != nullptr &&strcmp(cache[i].fileName, fileName) == 0) {
            return i;
        }
    }
    return -1;
}