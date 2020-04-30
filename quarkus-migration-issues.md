# Summarizes migration issues with StockQuote to Quarkus 
Issue found

## Constuctor/@PostConstruct mehtods ran at build time 
Quarkus when run in native mode initializes at compile to native time, not on startup 
This doesn't work in the constructor:

`System.getenv("REDIS_URL");`

Constructor replaced with  method

```void onStart(@Observes StartupEvent ev) {
   .... constuctor code here

```

## Quarkus doesnt support JMX - default Jedis pool configuration not works
Default `jedisPool = new JedisPool(jedisURI);` causes NullPointer.
Changed to disable jmx:

```
JedisPoolConfig jedisConfiguration = new JedisPoolConfig();
				jedisConfiguration.setJmxEnabled(false);
				jedisPool = new JedisPool(jedisConfiguration, jedisURI);
```

## Problem in the commons pool implementation
App fails to start with ClassNotFoundException
```
2020-04-29 17:35:37,724 INFO  [com.ibm.hyb.clo.sam.sto.sto.StockQuote] (main) java.lang.IllegalArgumentException: Unable to create org.apache.commons.pool2.impl.EvictionPolicy instance of type org.apache.commons.pool2.impl.DefaultEvictionPolicy
	at org.apache.commons.pool2.impl.BaseGenericObjectPool.setEvictionPolicyClassName(BaseGenericObjectPool.java:662)
	at org.apache.commons.pool2.impl.BaseGenericObjectPool.setEvictionPolicyClassName(BaseGenericObjectPool.java:687)
	at org.apache.commons.pool2.impl.BaseGenericObjectPool.setConfig(BaseGenericObjectPool.java:235)
	at org.apache.commons.pool2.impl.GenericObjectPool.setConfig(GenericObjectPool.java:302)
	at org.apache.commons.pool2.impl.GenericObjectPool.<init>(GenericObjectPool.java:115)
	at redis.clients.jedis.util.Pool.initPool(Pool.java:45)
	...
 Caused by: java.lang.ClassNotFoundException: org.apache.commons.pool2.impl.DefaultEvictionPolicy
	at com.oracle.svm.core.hub.ClassForNameSupport.forName(ClassForNameSupport.java:60)
	at java.lang.Class.forName(DynamicHub.java:1197)
```	
	
Temporary workaround - change Jedis pool to single Jedis connection.	