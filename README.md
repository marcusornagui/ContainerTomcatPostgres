# Container com Alpine, Tomcat e Postgres
Dokerfile utilizando Alpine, Tomcat e Postgres no mesmo container.

## Criando container

### Docker build
No diretório do projeto basta executar o comando abaixo para a criação do container:

```
 docker build . -t marcusornagui/tomcatpostgres:1.0
```

### Docker-Compose
No diretório do projeto basta executar o comando abaixo para iniciar o container:

```
 docker-compose -f docker-compose-tp.yml up -d
```
