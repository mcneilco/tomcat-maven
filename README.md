
# tomcat-maven

### Docker-compose command examples

Run tomcat:  
```command: catalina.sh run```

Wait for a db then run tomcat:  
```command: ["./wait-for-it.sh", "db:5432", "--", "catalina.sh", "run"]```

### Full docker-compose example for ACAS

```
tomcat:
	image: mcneilco/tomcat-maven:1.0-openjdk8
	restart: always
	depends_on:
	 - db
	ports:
	 - "8080:8080"
	 - "8000:8000"
	environment:
	 - ACAS_HOME=/home/runner/build
	 - CATALINA_OPTS=-Xms512M -Xmx1024M -XX:MaxPermSize=512m
	 - JAVA_OPTS=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000
	volumes_from:
	 - roo
	 - acas
	 - cmpdreg
	env_file:
		- ./conf/docker/acas/environment/acas.env
		- ./conf/docker/roo/environment/roo.env
		- ./conf/docker/cmpdreg/environment/cmpdreg.env
	command: ["./wait-for-it.sh", "db:5432", "--", "catalina.sh", "run"]
	```