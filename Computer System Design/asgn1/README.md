README
CruzID:zyang100
CSE 130

server.cpp is a program that implement a single-thread HTTP server, and the server will respond GET and PUT commands to read and write "files" named by 27-character ASCII names. The server will store the file in the directory. I used curl --uploadfile [filename] http://localhost:8868/[name] forPUT methdod, 8868 is my port number. In addition, I also use curl http://local host:8868/[name] for GET method. Also, we cannot use port 80 unless we use sudo. All of the test cases passed.