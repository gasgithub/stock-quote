This is using multistage docker build.

If you are doing build form Docker Desktop for Windows, first go to settings and change the following:
- Memory to at least 10GB (required)
- CPU - to at least 4 (more if you can)

![docker settings](docker-settings.png) 

Being in the stock-quote directory issue

`docker build -f src/main/docker/Dockerfile.multistage -t quarkus-stock-quote .`

After a successful build (it takes a while), start the image:

`docker run -i --rm -p 8080:8080 quarkus-stock-quote`

Access with the browser http://localhost:8080/stock-quote/IBM

Deploying to OpenShift 

Configure OCP registry:

`oc project openshift-image-registry`  

`oc create route reencrypt --service=image-registry` 
 
`oc get route image-registry`  


`docker login -u $(oc whoami) -p $(oc whoami -t) $(oc get route image-registry -n openshift-image-registry -o jsonpath={.spec.host})` 


Create project to store app
`oc new-project quarkus-test`

Tag image:
`docker tag quarkus-stock-quote image-registry-CLUSTER_URL/quarkus-test/quarkus-stock-quote`

Push image: 
`docker push image-registry-CLUSTER_URL/quarkus-test/quarkus-stock-quote`




