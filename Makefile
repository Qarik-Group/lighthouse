.PHONY: logout login start

all: login start

check: login

login:
	@bin/login

logout:
	@bin/logout

start:
	@bin/start