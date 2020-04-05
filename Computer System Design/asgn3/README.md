README
CruzID:zyang100
CSE 130

Httpserver.cpp is a program that implement caching, and the server will maintain the buffer that contains a subset of the pages. The server can handle multiple requests until the user exits the program. I used curl --uploadfile [filename] http://localhost:8840/[name] for PUT methdod, 8840 is my port number. In addition, I also use curl http://local host:8840/[name] for GET method. It fills the cache up with over 4 requests and see if it acts properly. All of the test cases passed.