#！/bin/sh
curl -T t1 http://localhost:8856 --request-target ABCDEFabcdef012345XYZxyz-mm >
cmd1.output &
curl -T t1 http://localhost:8856 --request-target ABCDEFabcdef012345XYZxyz-mm >
cmd2.output	&