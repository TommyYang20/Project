README
CruzID:zyang100
CSE 130

Server.cpp is a program that implement a multi-threading and logging, and the server will respond the log record, and the log record looks like hex. The server can handle multiple requests until the user exits the program. I used xargs -I % -P 200 curl http://localhost:8856/Qw++ < <(printf '%s\n' {1..400}) to test, and I also used curl -T t1 http://localhost:8856 --request-target ABCDEFabcdef012345XYZxyz-mm > cmd1.output & curl -T t1 http://localhost:8856 --request-target ABCDEFabcdef012345XYZxyz-mm > cmd2.output to test. All of the test cases passed.