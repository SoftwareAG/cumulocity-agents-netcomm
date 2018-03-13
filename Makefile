build:
	docker build -t chef .

run_myorg:
	docker run -it -v $(pwd):/usr/src/app -e ORGNAME=myorg chef bash
