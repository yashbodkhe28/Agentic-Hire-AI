package com.agenthire.livecoding;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class LiveCodingServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(LiveCodingServiceApplication.class, args);
    }
}
