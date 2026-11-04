package com.wozhendeshifwa.yupicture.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.wozhendeshifwa.yupicture.mapper.HealthMapper;

/**
 * 骨架期的两个健康端点： /api/health 只回答「进程活着」； /api/health/db 回答「数据库通道通不通」。
 *
 * <p>分开的理由：一次数据库抖动不该把整个前端标成「未连通」。
 */
@RestController
@RequestMapping("/api")
public class HealthController {

    private static final int MAX_DETAIL_LENGTH = 300;

    private final HealthMapper healthMapper;

    public HealthController(HealthMapper healthMapper) {
        this.healthMapper = healthMapper;
    }

    @GetMapping("/health")
    public HealthResponse health() {
        return new HealthResponse("ok");
    }

    @GetMapping("/health/db")
    public DbHealthResponse dbHealth() {
        long startedAt = System.nanoTime();
        try {
            Integer probe = healthMapper.ping();
            long latencyMs = elapsedMs(startedAt);
            if (probe != null && probe == 1) {
                return new DbHealthResponse("ok", latencyMs, null);
            }
            return new DbHealthResponse("down", latencyMs, "SELECT 1 返回了意外结果: " + probe);
        } catch (Exception error) {
            return new DbHealthResponse("down", elapsedMs(startedAt), rootCauseMessage(error));
        }
    }

    private static long elapsedMs(long startedAt) {
        return (System.nanoTime() - startedAt) / 1_000_000;
    }

    private static String rootCauseMessage(Throwable error) {
        Throwable root = error;
        while (root.getCause() != null && root.getCause() != root) {
            root = root.getCause();
        }
        String message = root.getMessage();
        if (message == null) {
            return root.getClass().getSimpleName();
        }
        return message.length() > MAX_DETAIL_LENGTH ? message.substring(0, MAX_DETAIL_LENGTH) : message;
    }

    public record HealthResponse(String status) {}

    /**
     * @param db ok / down
     * @param latencyMs 探针耗时
     * @param detail 仅在 down 时给原因，便于一眼区分「隧道没开」和「密码错了」
     */
    public record DbHealthResponse(String db, long latencyMs, String detail) {}
}
