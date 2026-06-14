/**
 * ===========================================================================
 * Course —— 课程信息实体 / 数据库实体映射
 * ===========================================================================
 *
 * 包路径       com.ebookBuy301.pojo
 * 对应数据表   course
 * 最后更新     2026-06-13
 *
 * ── 字段说明 ────────────────────────────────────────────────────────────────
 *
 * 字段           类型            对应列             说明
 * ----------------------------------------------------------------------
 * id            long            id                主键
 * courseName    String          course_name       课程名称
 * courseCategory String         course_category   课程分类
 * courseLevel   String          course_level      课程难度(beginner/intermediate/advanced)
 * instructorId  Integer         instructor_id     讲师ID
 * instructorName String         instructor_name   讲师姓名
 * courseHours   int             course_hours      课时数
 * rating        double          rating            评分
 * enrolledCount int             enrolled_count    已报名人数
 * coverImage    String          cover_image       封面图片
 * description   String          description       课程描述
 * status        String          status            状态(active/inactive)
 *
 * ── 使用的关键 API / 算法 ────────────────────────────────────────────────────
 *
 *   Java POJO 标准实现——Get/Set 方法 + toString()
 *
 * ===========================================================================
 */

package com.ebookBuy301.pojo;

public class Course {
    private long id;                        // 主键
    private String courseName;              // 课程名称
    private String courseCategory;          // 课程分类
    private String courseLevel;             // 课程难度(beginner/intermediate/advanced)
    private Integer instructorId;           // 讲师ID
    private String instructorName;          // 讲师姓名
    private int courseHours;                // 课时数
    private double rating;                  // 评分
    private int enrolledCount;              // 已报名人数
    private String coverImage;              // 封面图片
    private String description;             // 课程描述
    private String status;                  // 状态(active/inactive)

    public Course() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getCourseCategory() {
        return courseCategory;
    }

    public void setCourseCategory(String courseCategory) {
        this.courseCategory = courseCategory;
    }

    public String getCourseLevel() {
        return courseLevel;
    }

    public void setCourseLevel(String courseLevel) {
        this.courseLevel = courseLevel;
    }

    public Integer getInstructorId() {
        return instructorId;
    }

    public void setInstructorId(Integer instructorId) {
        this.instructorId = instructorId;
    }

    public String getInstructorName() {
        return instructorName;
    }

    public void setInstructorName(String instructorName) {
        this.instructorName = instructorName;
    }

    public int getCourseHours() {
        return courseHours;
    }

    public void setCourseHours(int courseHours) {
        this.courseHours = courseHours;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getEnrolledCount() {
        return enrolledCount;
    }

    public void setEnrolledCount(int enrolledCount) {
        this.enrolledCount = enrolledCount;
    }

    public String getCoverImage() {
        return coverImage;
    }

    public void setCoverImage(String coverImage) {
        this.coverImage = coverImage;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    @Override
    public String toString() {
        return "Course{" +
                "id=" + id +
                ", courseName='" + courseName + '\'' +
                ", courseCategory='" + courseCategory + '\'' +
                ", courseLevel='" + courseLevel + '\'' +
                ", instructorName='" + instructorName + '\'' +
                ", courseHours=" + courseHours +
                ", rating=" + rating +
                ", enrolledCount=" + enrolledCount +
                ", status='" + status + '\'' +
                '}';
    }
}
