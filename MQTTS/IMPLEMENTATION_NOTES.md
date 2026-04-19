# MQTTS Secure Connection Implementation

## Overview
Backend has been updated to use **secure MQTTS** (MQTT over TLS 1.3) instead of plain TCP MQTT. All changes compile successfully.

## Changes Made

### 1. Certificate Files (Already in place)
- `ca.crt` - Certificate Authority (CA) certificate
- `client.crt` - Client certificate  
- `client.key` - Client private key
- Copied to: `spring_boot-main/src/main/resources/`

### 2. Configuration (application.properties)
**Changed from:**
```properties
app.mqtt.broker-url=tcp://localhost:1883
```

**Changed to:**
```properties
app.mqtt.broker-url=ssl://localhost:8883
app.mqtt.ca-cert-path=classpath:ca.crt
app.mqtt.client-cert-path=classpath:client.crt
app.mqtt.client-key-path=classpath:client.key
```

### 3. MqttProperties.java
Added three new fields for certificate paths:
```java
private String caCertPath;
private String clientCertPath;
private String clientKeyPath;
```

### 4. MqttSubscriberConfig.java
- Added `createSSLContext()` method to load certificates and create TLS context
- Added `loadPrivateKey()` method to parse PEM private keys
- Updated `startSubscriber()` to apply SSL context when broker URL uses `ssl://`
- Imports TLS-related classes: `SSLContext`, `KeyStore`, `Certificate`, `KeyFactory`, etc.

### 5. MqttPublisherService.java  
- Same SSL context creation methods as subscriber (code reuse)
- Updated `initPublisher()` to apply SSL context for MQTTS connections
- Imports: All TLS and certificate handling imports added

## Broker Configuration

Mosquitto must listen on secure port **8883** with:
```conf
listener 8883
protocol mqtt
certfile /path/to/server.crt
keyfile /path/to/server.key
cafile /path/to/ca.crt
```

## How It Works

1. **On Startup:**
   - Both subscriber and publisher components detect `ssl://` broker URL
   - Load CA cert from classpath into trust store
   - Load client cert + key from classpath into key store
   - Create SSLContext with TLS 1.3
   - Set socket factory with SSL context

2. **On Connection:**
   - Client authenticates broker via CA certificate
   - Broker authenticates client via client certificate
   - All data encrypted with TLS 1.3

3. **Configuration-Driven:**
   - No hardcoding — all paths from `application.properties`
   - Easy to switch: just change `ssl://` to `tcp://` to disable TLS

## Testing

Verify connection:
```bash
# Check logs for:
# "MQTT TLS/SSL enabled with certificates"
# "CA certificate loaded: classpath:ca.crt"
# "Client certificate and key loaded"
# "MQTT connected to ssl://localhost:8883"
```

## Security Notes

- **TLS 1.3** enforced (latest standard)
- **CA certificate** validates broker identity
- **Client certificate** authenticates client to broker
- **Password auth** optional (in addition to certs)
- All certificate paths use `classpath:` for easy packaging in JAR

## Next Steps (Optional)

1. **Rotate certificates** if exposing to production
2. **Enable authentication** on broker (username/password + certs)
3. **Monitor** certificate expiry (add renewal process)
4. **Test** with real MQTT Explorer on port 8883
