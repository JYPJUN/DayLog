package com.daylog.global.config;

import com.daylog.global.handler.CoupleIdArgumentResolver;
import com.daylog.global.handler.UserIdArgumentResolver;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    private final UserIdArgumentResolver userIdArgumentResolver;
    private final CoupleIdArgumentResolver coupleIdArgumentResolver;

    public WebConfig(UserIdArgumentResolver userIdArgumentResolver, CoupleIdArgumentResolver coupleIdArgumentResolver) {
        this.userIdArgumentResolver = userIdArgumentResolver;
        this.coupleIdArgumentResolver = coupleIdArgumentResolver;
    }

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        resolvers.add(userIdArgumentResolver);
        resolvers.add(coupleIdArgumentResolver);
    }
}
