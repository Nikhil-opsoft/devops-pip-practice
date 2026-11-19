package com.opsoft.pip;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public class App {
    public static void main(String[] args) throws IOException {
        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));
        String pod = InetAddress.getLocalHost().getHostName();
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", ex -> {
            System.out.println("GET " + ex.getRequestURI() + " from " + ex.getRemoteAddress());
            reply(ex, "Hello from day5-app 1.1 on pod " + pod + "\n");
        });
        server.createContext("/health", ex -> reply(ex, "OK\n"));
        server.start();
        System.out.println("day5-app 1.1 listening on port " + port);
    }

    private static void reply(HttpExchange ex, String text) throws IOException {
        byte[] body = text.getBytes(StandardCharsets.UTF_8);
        ex.sendResponseHeaders(200, body.length);
        try (OutputStream os = ex.getResponseBody()) {
            os.write(body);
        }
    }
}
