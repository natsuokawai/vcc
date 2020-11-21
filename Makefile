vcc: ./src/*
	v -o vcc ./src/main.v
test: vcc
	./test.sh
clean:
	rm rm -f vcc *.o *~ tmp*
