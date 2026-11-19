package com.opsoft.pip;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.atomic.AtomicBoolean;

public class App {
    private static final AtomicBoolean HEALTHY = new AtomicBoolean(true);

    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(env("PORT", "8080"));
        String version = env("APP_VERSION", "dev");
        String appEnv = env("APP_ENV", "unset");
        String greeting = env("GREETING", "Hello");
        String token = env("API_TOKEN", "");
        String tokenInfo = token.isEmpty() ? "missing" : "set (" + token.length() + " chars)";
        String pod = InetAddress.getLocalHost().getHostName();

        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", ex -> {
            System.out.println("GET " + ex.getRequestURI() + " from " + ex.getRemoteAddress());
            reply(ex, 200, greeting + " from day5-app " + version + " [" + appEnv + "] on pod " + pod
                    + " | api token: " + tokenInfo + "\n");
        });
        server.createContext("/health", ex -> {
            if (HEALTHY.get()) {
                reply(ex, 200, "OK\n");
            } else {
                reply(ex, 500, "BROKEN\n");
            }
        });
        server.createContext("/fail", ex -> {
            HEALTHY.set(false);
            System.out.println("FAIL switch hit: /health now returns 500");
            reply(ex, 200, "pod " + pod + " marked unhealthy\n");
        });
        server.start();
        System.out.println("day5-app " + version + " [" + appEnv + "] listening on port " + port + ", api token " + tokenInfo);
    }

    private static String env(String key, String fallback) {
        String value = System.getenv(key);
        return (value == null || value.isEmpty()) ? fallback : value;
    }

    private static void reply(HttpExchange ex, int code, String text) throws IOException {
        byte[] body = text.getBytes(StandardCharsets.UTF_8);
        ex.sendResponseHeaders(code, body.length);
        try (OutputStream os = ex.getResponseBody()) {
            os.write(body);
        }
    }
}
