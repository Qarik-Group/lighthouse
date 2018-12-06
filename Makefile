.PHONY: cf logout login

all: cf-logout cf-login cf

check: login

cf:
	@bin/cf/run

cf-login:
	@bin/cf/login

cf-logout:
	@bin/cf/logout

