HOSTS = master slave1 slave2 slave3 slave4 slave5

all:
	docker build -t lewuathe/hadoop-base:latest hadoop-base
	docker build -t lewuathe/hadoop-master:latest hadoop-master
	docker build -t lewuathe/hadoop-slave:latest hadoop-slave
	docker-compose build

.PHONY: test clean

run:
	docker-compose up -d;
	for host in $(HOSTS); do \
	docker exec $$host service ssh start;\
	done;
	   echo "Please check http://localhost:8080"

down:
	docker-compose down
