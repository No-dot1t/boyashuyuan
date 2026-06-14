/**
 * ===========================================================================
 * NotificationScheduler —— 定时通知调度器
 * ===========================================================================
 *
 * 包路径    com.ebookBuy301.scheduler
 * 注解      @WebListener（基于 ServletContextListener）
 *
 * ── 用途 ─────────────────────────────────────────────────────────────────
 *  使用 {@link Timer} 定时扫描 notification 表的定时通知、到期自动发送。
 *  整个调度器以守护线程（daemon=true）运行，Web 容器关闭时自动清理。
 *
 * ── 方法索引 ─────────────────────────────────────────────────────────────
 *  方法                                  用途
 *  ----------------------------------------------------------------------
 *  contextInitialized(ServletContextEvent) 启动调度器（容器启动）
 *  contextDestroyed(ServletContextEvent)  停止调度器（容器关闭）
 *  processScheduledNotifications()        处理到期通知的核心方法
 *
 * ── 调度策略 ─────────────────────────────────────────────────────────────
 *  - 启动后立即执行一次（delay = 0）
 *  - 之后每 60 秒扫描一次（period = 60 * 1000）
 *  - 每次扫描查询 status = scheduled 且 schedule_time &lt;= NOW() 的记录
 *  - 更新状态为 sending → 调用 dao.sendNotificationToAll() → 标记为 sent / failed
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────
 *  - java.util.Timer / TimerTask    定时任务调度
 *  - ServletContextListener 生命周期钩子
 *  - DAO 模式（CultureNotificationDao） 数据访问
 *
 * ===========================================================================
 */
package com.ebookBuy301.scheduler;

import com.ebookBuy301.dao.CultureNotificationDao;
import com.ebookBuy301.pojo.Notification;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

@WebListener
public class NotificationScheduler implements ServletContextListener {

    /** 全局定时器实例（守护线程模式） */
    private Timer timer;

    /**
     * 容器启动时启动调度器。
     * <p>
     * 算法：创建守护 Timer → 调度 {@link #processScheduledNotifications}，
     * 首次延迟 0（立即执行一次），之后每 60 秒执行一次。
     *
     * @param sce ServletContextEvent 事件对象
     */
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer("NotificationScheduler", true);

        // 每分钟检查一次定时任务
        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                processScheduledNotifications();
            }
        }, 0, 60 * 1000);

        System.out.println("【定时任务】通知调度器已启动");
    }

    /**
     * 容器关闭时停止调度器，释放 Timer 线程。
     *
     * @param sce ServletContextEvent 事件对象
     */
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            System.out.println("【定时任务】通知调度器已停止");
        }
    }

    /**
     * 处理定时发送的通知。
     * <p>
     * 算法流程：
     *   ① 调用 {@code CultureNotificationDao.getScheduledNotifications()} 获取待发列表
     *   ② 遍历每条记录，先将状态置为 {@code sending}（避免重复发送）
     *   ③ 调用 {@code dao.sendNotificationToAll(notification)} 真正发送
     *   ④ 发送成功则标记为 {@code sent}，否则标记为 {@code failed}
     *   ⑤ 捕获并打印异常，保证定时任务不会因单次失败而终止
     */
    private void processScheduledNotifications() {
        try {
            CultureNotificationDao dao = new CultureNotificationDao();
            List<Notification> scheduledList = dao.getScheduledNotifications();

            for (Notification notification : scheduledList) {
                // 更新状态为发送中
                dao.updateNotificationStatus(notification.getId(), "sending");

                // 执行发送
                boolean success = dao.sendNotificationToAll(notification);

                // 更新最终状态
                if (success) {
                    dao.updateNotificationStatus(notification.getId(), "sent");
                    System.out.println("【定时任务】通知发送成功: " + notification.getTitle());
                } else {
                    dao.updateNotificationStatus(notification.getId(), "failed");
                    System.out.println("【定时任务】通知发送失败: " + notification.getTitle());
                }
            }
        } catch (Exception e) {
            System.err.println("【定时任务】处理定时通知时发生错误: " + e.getMessage());
            e.printStackTrace();
        }
    }
}