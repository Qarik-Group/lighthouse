.PHONY: bosh bosh-login bosh-logout cf cf-logout cf-login

all: cf-logout cf-login cf

bosh:
	@bin/bosh/run

bosh-login:
	@bin/bosh/login

bosh-logout:
	@bin/bosh/logout

check: bosh-login cf-login

cf: 
	@bin/cf/run

cf-login:
	@bin/cf/login

cf-logout:
	@bin/cf/logout


