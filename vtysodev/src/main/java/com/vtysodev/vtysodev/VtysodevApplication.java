package com.vtysodev.vtysodev;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.WebApplicationType;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication

public class VtysodevApplication {

    public static void main(String[] args) {
        SpringApplication.run(VtysodevApplication.class, args);
    }

}
