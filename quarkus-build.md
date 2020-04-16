This is using multistage docker build.

If you are doing build form Docker Desktop for Windows, first go to settings and change the following:
- Memory to at least 10GB (required)
- CPU - to at least 4 (more if you can)

![docker settings](docker-settings.png) 

Being in the stock-quote directory issue

`docker build -f src/main/docker/Dockerfile.multistage -t quarkus-stock-quote/stock-quote .`

After a successful build (it takes a while), start the image:

`docker run -i -p 8080:8080 quarkus-stock-quote/stock-quote`

Access with the browser http://localhost:8080/stock-quote/IBM