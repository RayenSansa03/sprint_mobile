package agrismart.gateway.filter;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitFilter implements GlobalFilter, Ordered {
    private static final AntPathMatcher PATH_MATCHER = new AntPathMatcher();
    private static final List<String> EXEMPT_PATHS = List.of(
            "/api/auth/**",
            "/api/health",
            "/chatbot/health",
            "/api/plant-ai/**"
    );

    private final ConcurrentHashMap<String, Deque<Long>> hits = new ConcurrentHashMap<>();

    @Value("${gateway.rate-limit.per-minute:120}")
    private int limitPerMinute;

    @Value("${gateway.rate-limit.window-seconds:60}")
    private int windowSeconds;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();
        HttpMethod method = exchange.getRequest().getMethod();

        if (isExempt(path, method)) {
            return chain.filter(exchange);
        }

        String key = resolveClientKey(exchange);
        if (!allowRequest(key)) {
            return rateLimited(exchange);
        }

        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -10;
    }

    private boolean isExempt(String path, HttpMethod method) {
        for (String pattern : EXEMPT_PATHS) {
            if (PATH_MATCHER.match(pattern, path)) {
                return true;
            }
        }

        return HttpMethod.GET.equals(method)
                && (PATH_MATCHER.match("/api/market/offers", path)
                || PATH_MATCHER.match("/api/market/prices", path));
    }

    private String resolveClientKey(ServerWebExchange exchange) {
        String forwarded = exchange.getRequest().getHeaders().getFirst("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        if (exchange.getRequest().getRemoteAddress() != null) {
            return exchange.getRequest().getRemoteAddress().getAddress().getHostAddress();
        }
        return "unknown";
    }

    private boolean allowRequest(String key) {
        long now = Instant.now().getEpochSecond();
        long threshold = now - windowSeconds;
        Deque<Long> queue = hits.computeIfAbsent(key, ignored -> new ArrayDeque<>());
        synchronized (queue) {
            while (!queue.isEmpty() && queue.peekFirst() < threshold) {
                queue.pollFirst();
            }
            if (queue.size() >= limitPerMinute) {
                return false;
            }
            queue.addLast(now);
            return true;
        }
    }

    private Mono<Void> rateLimited(ServerWebExchange exchange) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);
        byte[] payload = "{\"error\":\"rate_limit_exceeded\"}".getBytes(StandardCharsets.UTF_8);
        return response.writeWith(Mono.just(response.bufferFactory().wrap(payload)));
    }
}
