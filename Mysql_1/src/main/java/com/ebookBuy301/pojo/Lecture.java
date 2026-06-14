/**
 * ===========================================================================
 * Lecture —— 讲座信息实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   lecture
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列           说明
 * ----------------------------------------------------------------------
 * id            int             id              主键
 * title         String          title           讲座标题
 * speaker       String          speaker         主讲人
 * speakerTitle  String          speaker_title   主讲人头衔
 * speakerAvatar String          speaker_avatar  主讲人头像
 * lectureDate   Timestamp       lecture_date    讲座日期
 * lectureTime   String          lecture_time    讲座时间
 * description   String          description     讲座描述
 * isOnline      boolean         is_online       是否线上
 * meetingUrl    String          meeting_url     线上会议链接
 * status        String          status          状态(upcoming/ongoing/completed/cancelled)
 * sortOrder     int             sort_order      排序序号
 * isActive      boolean         is_active       是否启用
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + isOnline()/isActive() 判断方法
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

import java.sql.Timestamp;

public class Lecture {
    private int id;                         // 主键
    private String title;                   // 讲座标题
    private String speaker;                 // 主讲人
    private String speakerTitle;            // 主讲人头衔
    private String speakerAvatar;           // 主讲人头像
    private Timestamp lectureDate;          // 讲座日期
    private String lectureTime;             // 讲座时间
    private String description;             // 讲座描述
    private boolean isOnline;               // 是否线上
    private String meetingUrl;              // 线上会议链接
    private String status;                  // 状态(upcoming/ongoing/completed/cancelled)
    private int sortOrder;                  // 排序序号
    private boolean isActive;               // 是否启用

    public Lecture() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSpeaker() { return speaker; }
    public void setSpeaker(String speaker) { this.speaker = speaker; }

    public String getSpeakerTitle() { return speakerTitle; }
    public void setSpeakerTitle(String speakerTitle) { this.speakerTitle = speakerTitle; }

    public String getSpeakerAvatar() { return speakerAvatar; }
    public void setSpeakerAvatar(String speakerAvatar) { this.speakerAvatar = speakerAvatar; }

    public Timestamp getLectureDate() { return lectureDate; }
    public void setLectureDate(Timestamp lectureDate) { this.lectureDate = lectureDate; }

    public String getLectureTime() { return lectureTime; }
    public void setLectureTime(String lectureTime) { this.lectureTime = lectureTime; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isOnline() { return isOnline; }
    public void setOnline(boolean online) { isOnline = online; }

    public String getMeetingUrl() { return meetingUrl; }
    public void setMeetingUrl(String meetingUrl) { this.meetingUrl = meetingUrl; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getSortOrder() { return sortOrder; }
    public void setSortOrder(int sortOrder) { this.sortOrder = sortOrder; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
