package agrismart.gateway.filter;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class JwtAuthFilter implements GlobalFilter, Ordered {
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthFilter.class);
    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();
    private static final Pattern JWT_ALG_PATTERN = Pattern.compile("\"alg\"\\s*:\\s*\"([^\"]+)\"");
    private static final List<String> PUBLIC_PATHS = List.of(
            "/api/auth/**",
            "/api/health",
            "/uploads/**",
            "/chatbot/health",
            "/api/plant-ai/**"
    );

    @Value("${jwt.secret:}")
    private String jwtSecret;

    @Value("${jwt.algorithm:HS256}")
    private String jwtAlgorithm;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();
        HttpMethod method = exchange.getRequest().getMethod();

        // DEBBUGING MARKERS
        exchange.getResponse().getHeaders().add("X-Gateway-Debug-Path", path);
        exchange.getResponse().getHeaders().add("X-Gateway-Debug-Method", method.name());

        logger.info(">>> GATEWAY FILTER - Path: {}, Method: {}", path, method);

        if (method == HttpMethod.OPTIONS || isPublicPath(path, method)) {
            logger.info(">>> PATH IS EXEMPT: {}", path);
            return chain.filter(exchange);
        }

        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return unauthorized(exchange, "authorization token required");
        }

        if (jwtSecret == null || jwtSecret.isBlank()) {
            logger.warn("JWT secret not configured on gateway.");
            return unauthorized(exchange, "gateway jwt secret not configured");
        }

        String token = authHeader.substring(7).trim();
        try {
            String configuredAlgorithm = (jwtAlgorithm == null || jwtAlgorithm.isBlank())
                    ? "HS256"
                    : jwtAlgorithm.trim().toUpperCase(Locale.ROOT);

            Claims claims = Jwts.parser()
                    .verifyWith(Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8)))
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

                String tokenAlgorithm = extractTokenAlgorithm(token);

            if (tokenAlgorithm == null || !configuredAlgorithm.equalsIgnoreCase(tokenAlgorithm)) {
                return unauthorized(exchange, "invalid token algorithm");
            }

            String tokenType = claims.get("token_type", String.class);
            if (!"access".equals(tokenType)) {
                return unauthorized(exchange, "access token required");
            }
        } catch (Exception ex) {
            logger.debug("gateway_jwt_rejected path={} reason={}", path, ex.getMessage());
            return unauthorized(exchange, "invalid token");
        }

        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -20;
    }

    private boolean isPublicPath(String path, HttpMethod method) {
        // ROBUST MATCHING FOR PLANT-AI
        if (path.contains("plant-ai")) {
            return true;
        }

        for (String pattern : PUBLIC_PATHS) {
            if (PATH_MATCHER.match(pattern, path)) {
                return true;
            }
        }

        if (HttpMethod.GET.equals(method)) {
            return PATH_MATCHER.match("/api/market/offers", path)
                    || PATH_MATCHER.match("/api/market/prices", path);
        }

        return false;
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange, String message) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);
        byte[] payload = ("{\"error\":\"unauthorized\",\"message\":\"" + message + "\"}")
                .getBytes(StandardCharsets.UTF_8);
        return response.writeWith(Mono.just(response.bufferFactory().wrap(payload)));
    }

    private String extractTokenAlgorithm(String token) {
        String[] parts = token.split("\\.");
        if (parts.length < 2) {
            return "";
        }

        String headerPart = parts[0].replace('-', '+').replace('_', '/');
        int mod = headerPart.length() % 4;
        if (mod == 2) {
            headerPart = headerPart + "==";
        } else if (mod == 3) {
            headerPart = headerPart + "=";
        }

        try {
            String headerJson = new String(Base64.getDecoder().decode(headerPart), StandardCharsets.UTF_8);
            Matcher matcher = JWT_ALG_PATTERN.matcher(headerJson);
            return matcher.find() ? matcher.group(1) : "";
        } catch (Exception ex) {
            return "";
        }
    }
}
