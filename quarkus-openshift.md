# Deploying StockQuote application (Quarkus version) to OpenShift 
This guide assumes that you have application available in the some kind of the Git repo which is accessible by the OpenShift cluster.
Application can be deployed in ways:

- using manifests (yaml files)
- using s2i tooling (via `oc new-app`)
- using Quarkus Openshift extension (via mvn build)

In this guide we will show deloyment using manifest files, as it might be easily incorporated to CI/CD process.

## Deploying to OpenShift using manifestes (BuildConfig, ImageStreams and Deployment)
Quarkus provides images that can be used to build application directly on OpenShift. 
We will utilize that method to compile and build application directly on the target cluster.

Create ImageStreams that will hold build tools and application images:

- [is-quarkus-maven.yaml](manifests\quarkus\is-quarkus-maven.yaml) - image stream holding building tools
- [is-stock-quote-quarkus.yaml](manifests\quarkus\is-stock-quote-quarkus.yaml) - image stream for built application

Create BuildConfig definition that will tell OpenShift how to process the application.
[bc-stock-quote-quarkus.yaml](manifests\quarkus\bc-stock-quote-quarkus.yaml) is build config that is using Git and Docker strategy. Config pulls application from
specified git repository and branch:

```
  source:
    type: Git
    git:
      uri: 'https://github.com/fritsjen/stock-quote.git'
      ref: quarkus
```

It is using Docerfile located in the root of the project, and source image stream that we specified in previous step:

```
  strategy:
    type: Docker
    dockerStrategy:
      from:
        kind: ImageStreamTag
        name: 'centos-quarkus-maven:19.3.1-java11'
```

As output, it produces new image stream with build application:

```
  output:
    to:
      kind: ImageStreamTag
      name: 'stock-quote-quarkus:latest'
```

We could already deploy and run this image using [depl-stock-quote-quarkus.yaml](manifests\quarkus\depl-stock-quote-quarkus.yaml), however this image is quite big (920MB) as it contains lots of tools used during build. 
It is recommended to create minimal image that will use only created application. 
To achieve this we will create 2 additional image streams: 

- [is-ubi-minimal.yaml](manifests\quarkus\is-ubi-minimal.yaml) - stream that holds minimal ubi base image 
- [is-minimal-stock-quote-quarkus.yaml](manifests\quarkus\is-minimal-stock-quote-quarkus.yaml) - image stream holding building tools 

and build config that will build small target image (70MB) - [bc-minimal-stock-quote-quarkus.yaml](manifests\quarkus\bc-minimal-stock-quote-quarkus.yaml)

This build config is using previously built image and inline dockerfile to copy built application and run it:

```
  source:
    type: Dockerfile
    dockerfile: |-
      FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
      COPY application /application
      CMD /application
      EXPOSE 8080
    images:
      - from:
          kind: ImageStreamTag
          name: 'stock-quote-quarkus:latest'
        as: null
        paths:
          - sourcePath: /usr/src/app/target/application
            destinationDir: .
      
```

Application is deployed using yaml file, that defines deployment, service and route - [depl-minimal-stock-quote-quarkus.yaml](manifests\quarkus\depl-minimal-stock-quote-quarkus.yaml). 
To deploy application issue: 

`oc apply -f depl-minimal-stock-quote-quarkus.yaml`

Application can be validated using url similar to:
http://minimal-stock-quote-quarkus-NAMESPACE.CLUSTER-URL/stock-quote/IBM

You can find your URL using the following command: 
`oc get route/minimal-stock-quote-quarkus`


