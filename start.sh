#!/bin/sh
erl -erly_juggernaut http_port 8081 -sname erly_juggernaut -pa ebin -pa deps/*/ebin -gproc gproc_dist all -s reloader -s erly_juggernaut \
	-eval "io:format(\"~n~nThe following examples are available:~n\")." \
	-eval "io:format(\"* Channel1: http://localhost:8081/static/index.html ~n\")." \
	-eval "io:format(\"* Channel2: http://localhost:8081/static/index2.html ~n\")." 
