vcc: vcc.v
	v vcc.v
test: vcc
	./test.sh
clean:
	rm rm -f vcc *.o *~ tmp*
