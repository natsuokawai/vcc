vcc: main.v
	v -o vcc main.v
test: vcc
	./test.sh
clean:
	rm rm -f vcc *.o *~ tmp*
