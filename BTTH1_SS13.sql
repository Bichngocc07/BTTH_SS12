-- BÀI TẬP THỰC HÀNH --
-- TẠO DATA --
create database SocialNetworkDB;
use SocialNetworkDB;

-- users --
-- Bảng users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    total_posts INT DEFAULT 0
);

-- Bảng posts
CREATE TABLE posts (
    post_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    content TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Bảng post_audits
CREATE TABLE post_audits (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
DELIMITER //
-- task 1 --
CREATE TRIGGER tg_CheckPostContent
BEFORE INSERT ON posts
FOR EACH ROW
BEGIN
    IF NEW.content IS NULL OR TRIM(NEW.content) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nội dung bài viết không được để trống!';
    END IF;
END //
-- task 2 --
CREATE TRIGGER tg_UpdatePostCountAfterInsert
AFTER INSERT ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts + 1
    WHERE id = NEW.user_id;
END;
//

DELIMITER ;
-- task 3 --
DELIMITER //
CREATE TRIGGER tg_LogPostChanges
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_audits (post_id, old_content, new_content, changed_at)
        VALUES (OLD.post_id, OLD.content, NEW.content, NOW());
    END IF;
END //
-- Task 4 --
CREATE TRIGGER tg_UpdatePostCountAfterDelete
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    UPDATE users
    SET total_posts = total_posts - 1
    WHERE user_id = OLD.user_id;
END //

DELIMITER ;
   -- 3. TEST TRIGGER--

-- 3.1 Tạo người dùng
INSERT INTO users (username) VALUES ('nguyenan');

-- Kiểm tra users
SELECT * FROM users;

-- 3.2 Insert bài viết hợp lệ
INSERT INTO posts (user_id, content)
VALUES (1, 'Hello MySQL Trigger');

-- Kiểm tra total_posts (phải = 1)
SELECT * FROM users;

-- 3.4 Update bài viết
UPDATE posts
SET content = 'Hello MySQL Trigger - Updated'
WHERE post_id = 1;

-- Kiểm tra log chỉnh sửa
SELECT * FROM post_audits;

-- 3.5 Delete bài viết
DELETE FROM posts WHERE post_id = 1;

-- Kiểm tra total_posts (phải = 0)
SELECT * FROM users;

DROP TRIGGER IF EXISTS tg_CheckPostContent;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterInsert;
DROP TRIGGER IF EXISTS tg_LogPostChanges;
DROP TRIGGER IF EXISTS tg_UpdatePostCountAfterDelete;