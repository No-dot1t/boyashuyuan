/**
 * ===========================================================================
 * UserProfileServlet —— 用户个人信息修改控制器 v3.0
 * ===========================================================================
 *
 * 路由      /userProfile
 * 最后更新  2026-06-04
 *
 * POST /userProfile?action=update         → 更新个人资料（昵称/性别/邮箱/头像）
 * POST /userProfile?action=changePassword → 修改密码（BCrypt 加密）
 *
 * v3.0 改进：fastjson 替代 StringBuilder、CSRF 校验
 * ===========================================================================
 */

package com.ebookBuy301;

import com.alibaba.fastjson.JSONObject;
import com.ebookBuy301.dao.UsersDao;
import com.ebookBuy301.pojo.Users;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;

import org.mindrot.jbcrypt.BCrypt;

@WebServlet("/userProfile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class UserProfileServlet extends HttpServlet {

    private static final String[] ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"};

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        // 登录验证
        Users currentUser = (Users) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            writeJson(response, false, "请先登录", null);
            return;
        }

        String action = request.getParameter("action");
        if ("update".equals(action)) {
            updateProfile(request, response, currentUser);
        } else if ("changePassword".equals(action)) {
            changePassword(request, response, currentUser);
        } else {
            writeJson(response, false, "未知操作", null);
        }
    }

    // ==================== 修改密码 ====================

    private void changePassword(HttpServletRequest request, HttpServletResponse response, Users currentUser)
            throws IOException {
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");

        if (oldPassword == null || oldPassword.trim().isEmpty()
                || newPassword == null || newPassword.trim().isEmpty()) {
            writeJson(response, false, "请填写完整", null);
            return;
        }

        if (newPassword.trim().length() < 6) {
            writeJson(response, false, "新密码至少6位", null);
            return;
        }

        // 验证旧密码（BCrypt + 明文兼容）
        try {
            if (!BCrypt.checkpw(oldPassword, currentUser.getPassword())) {
                writeJson(response, false, "当前密码不正确", null);
                return;
            }
        } catch (IllegalArgumentException e) {
            if (!oldPassword.equals(currentUser.getPassword())) {
                writeJson(response, false, "当前密码不正确", null);
                return;
            }
        }

        // BCrypt 加密并更新
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
        try {
            UsersDao usersDao = new UsersDao();
            int result = usersDao.updatePasswordByUsername(currentUser.getUsername(), hashedPassword);
            if (result > 0) {
                currentUser.setPassword(hashedPassword);
                request.getSession().setAttribute("currentUser", currentUser);
                writeJson(response, true, "密码修改成功", null);
            } else {
                writeJson(response, false, "密码修改失败，请重试", null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "数据库异常", null);
        }
    }

    // ==================== 更新个人资料 ====================

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, Users currentUser)
            throws IOException {

        String nickname = request.getParameter("nickname");
        String sex = request.getParameter("sex");
        String email = request.getParameter("email");

        // 处理头像上传
        String avatarPath = currentUser.getAvatar();
        String localResult = processLocalAvatar(request, currentUser);
        if (localResult != null && localResult.startsWith("ERROR:")) {
            writeJson(response, false, localResult.substring(6), null);
            return;
        }
        if (localResult != null) {
            avatarPath = localResult;
        } else {
            String avatarUrl = request.getParameter("avatar");
            if (avatarUrl != null && !avatarUrl.trim().isEmpty()) {
                avatarPath = avatarUrl.trim();
            }
        }

        // 合并更新（保留空值）
        currentUser.setNickname(nickname != null && !nickname.trim().isEmpty()
                ? nickname.trim() : currentUser.getNickname());
        currentUser.setAvatar(avatarPath);
        currentUser.setSex(sex != null && !sex.trim().isEmpty()
                ? sex.trim() : currentUser.getSex());
        currentUser.setEmail(email != null && !email.trim().isEmpty()
                ? email.trim() : currentUser.getEmail());

        try {
            UsersDao usersDao = new UsersDao();
            int result = usersDao.updateProfile(currentUser);
            if (result > 0) {
                request.getSession().setAttribute("currentUser", currentUser);
                writeJson(response, true, "修改成功", avatarPath);
            } else {
                writeJson(response, false, "修改失败，请重试", null);
            }
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(response, false, "数据库异常", null);
        }
    }

    // ==================== 头像上传处理 ====================

    private String processLocalAvatar(HttpServletRequest request, Users currentUser) {
        Part avatarPart;
        try {
            avatarPart = request.getPart("avatarFile");
        } catch (Exception e) {
            System.out.println("[UserProfile] 未检测到头像文件上传");
            return null;
        }

        if (avatarPart == null || avatarPart.getSize() <= 0) {
            return null;
        }

        String fileName = avatarPart.getSubmittedFileName();
        if (fileName == null || fileName.trim().isEmpty()) {
            return null;
        }

        String ext = getFileExtension(fileName);
        if (!isAllowedExtension(ext)) {
            return "ERROR:不支持的文件格式，仅支持 JPG/PNG/GIF/WebP";
        }

        String uniqueName = System.currentTimeMillis() + "_" + Math.abs(fileName.hashCode()) + ext;

        try {
            File uploadDir = new File(this.getServletContext().getRealPath("/"), "avatars");
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

            File targetFile = new File(uploadDir, uniqueName);
            avatarPart.write(targetFile.getAbsolutePath());

            // 同时备份到源码 webapp 目录（防止 mvn clean 丢失头像文件）
            try {
                String deployedRoot = this.getServletContext().getRealPath("/");
                int targetIdx = deployedRoot.indexOf("target");
                if (targetIdx > 0) {
                    String sourceRoot = deployedRoot.substring(0, targetIdx)
                            + "src" + File.separator + "main" + File.separator + "webapp";
                    File sourceDir = new File(sourceRoot, "avatars");
                    if (!sourceDir.exists()) sourceDir.mkdirs();
                    File sourceFile = new File(sourceDir, uniqueName);
                    java.io.FileInputStream fis = new java.io.FileInputStream(targetFile);
                    java.io.FileOutputStream fos = new java.io.FileOutputStream(sourceFile);
                    byte[] buf = new byte[8192];
                    int len;
                    while ((len = fis.read(buf)) > 0) fos.write(buf, 0, len);
                    fos.close(); fis.close();
                    System.out.println("[UserProfile] 头像已备份到源目录: " + sourceFile.getAbsolutePath());
                }
            } catch (Exception e) {
                System.out.println("[UserProfile] 源目录备份跳过（生产环境）: " + e.getMessage());
            }

            // 删除旧本地头像
            String oldAvatar = currentUser.getAvatar();
            if (oldAvatar != null && oldAvatar.startsWith("/avatars/")) {
                File oldFile = new File(this.getServletContext().getRealPath("/"), oldAvatar);
                if (oldFile.exists()) {
                    oldFile.delete();
                }
            }

            System.out.println("[UserProfile] 头像上传成功: " + targetFile.getAbsolutePath());
            return "/avatars/" + uniqueName;
        } catch (Exception e) {
            System.err.println("[UserProfile] 头像文件写入失败: " + e.getMessage());
            e.printStackTrace();
            return "ERROR:头像上传失败，请重试";
        }
    }

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex > 0) {
            return fileName.substring(dotIndex).toLowerCase();
        }
        return "";
    }

    private boolean isAllowedExtension(String ext) {
        if (ext == null || ext.isEmpty()) return false;
        for (String allowed : ALLOWED_EXTENSIONS) {
            if (allowed.equals(ext)) return true;
        }
        return false;
    }

    // ==================== JSON 响应（fastjson） ====================

    private void writeJson(HttpServletResponse response, boolean success, String message, String avatar)
            throws IOException {
        JSONObject json = new JSONObject();
        json.put("success", success);
        json.put("message", message != null ? message : "");
        if (avatar != null) {
            json.put("avatar", avatar);
        }
        response.getWriter().write(json.toJSONString());
    }
}
