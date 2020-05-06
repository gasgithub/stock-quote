# Configuring JWT authorization 
This instruction is based on the Quarkus documentation - https://quarkus.io/guides/security-jwt

The following steps are required to setup JWT:

- addd following entries to `application.properties` file:

```
mp.jwt.verify.publickey.location=default-cert.pem
mp.jwt.verify.issuer=http://stock-trader.ibm.com
quarkus.smallrye-jwt.enabled=true
```

Optionally, if you want to validate audiences, you need to add the following:

```
smallrye.jwt.verify.aud=stock-trader
```

- add following to `pom.xml`:

```
    <dependency>
      <groupId>io.quarkus</groupId>
      <artifactId>quarkus-smallrye-jwt</artifactId>
    </dependency>
```

## Deploying to OpenShift 

Add following entries to the environment section of deployment yaml:

```
          env:
            - name: MP_JWT_VERIFY_PUBLICKEY
              valueFrom:
                configMapKeyRef:
                  name: jwt-config
                  key: jwt-ca.crt
            - name: MP_JWT_VERIFY_ISSUER
              valueFrom:
                configMapKeyRef:
                  name: jwt-config
                  key: mp.jwt.verify.issuer
            - name: SMALLRYE_JWT_VERIFY_AUD
              valueFrom:
                configMapKeyRef:
                  name: jwt-config
                  key: smallrye.jwt.verify.aud

```

and create config map with required values. Sample config map is provided [here](manifests\quarkus\cm-jwt-config.yaml)


