/*
 Navicat Premium Dump SQL

 Source Server         : 华为云组卷
 Source Server Type    : MySQL
 Source Server Version : 50743 (5.7.43-log)
 Source Host           : 110.41.174.110:3306
 Source Schema         : problem_system

 Target Server Type    : MySQL
 Target Server Version : 50743 (5.7.43-log)
 File Encoding         : 65001

 Date: 21/04/2025 01:02:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for persistent_logins
-- ----------------------------
DROP TABLE IF EXISTS `persistent_logins`;
CREATE TABLE `persistent_logins` (
  `username` varchar(64) NOT NULL,
  `series` varchar(64) NOT NULL,
  `token` varchar(64) NOT NULL,
  `last_used` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`series`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of persistent_logins
-- ----------------------------
BEGIN;
INSERT INTO `persistent_logins` (`username`, `series`, `token`, `last_used`) VALUES ('root', '3r5yw1MmeZRThMB4yPLTCg==', '1b9mSVoVw75zWupykT+FGQ==', '2024-04-16 04:15:47');
INSERT INTO `persistent_logins` (`username`, `series`, `token`, `last_used`) VALUES ('root', 'TkFMuDVrRiq4hIF1DNtItA==', 'rOs9RM8y9D4FRNOkupc4pA==', '2024-04-17 14:26:29');
COMMIT;

-- ----------------------------
-- Table structure for tb_course
-- ----------------------------
DROP TABLE IF EXISTS `tb_course`;
CREATE TABLE `tb_course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '课程名称',
  `description` varchar(255) DEFAULT NULL COMMENT '课程描述',
  `deleted` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑删除，0正常，1删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_course
-- ----------------------------
BEGIN;
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (1, '高等数学', '描述：该课程大一上', 0);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (2, '线性代数', '线性代数', 0);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (3, '数据结构', '数据结构', 0);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (4, '英语', '大二xia', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (5, '低等数学', '11', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (6, '撒旦', 's', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (7, '1', '1', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (8, '1', '1', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (9, '1', '1', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (10, '名字', '1', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (11, '2', '2', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (12, '政治', '社会主义好青年', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (13, '', '', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (14, 'VUE', '', 0);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (15, '1', '1', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (16, '123', '123', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (17, '英语', 'shu', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (18, '大学英语', '修改1', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (19, '英语', '测试', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (20, '英语', '大学英语', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (21, '英语', '大一英语', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (22, '大学英语下', '英语', 1);
INSERT INTO `tb_course` (`id`, `name`, `description`, `deleted`) VALUES (23, '大学英语下', '1', 0);
COMMIT;

-- ----------------------------
-- Table structure for tb_folder_ques_list
-- ----------------------------
DROP TABLE IF EXISTS `tb_folder_ques_list`;
CREATE TABLE `tb_folder_ques_list` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `folder_id` int(11) NOT NULL COMMENT '文件夹id',
  `ques_id` int(11) NOT NULL COMMENT '图片id',
  `deleted` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑删除，0正常，1删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `folder_id` (`folder_id`) USING BTREE,
  KEY `ques_id` (`ques_id`) USING BTREE,
  CONSTRAINT `folder_id` FOREIGN KEY (`folder_id`) REFERENCES `tb_ques_folder` (`id`),
  CONSTRAINT `ques_id` FOREIGN KEY (`ques_id`) REFERENCES `tb_questions` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_folder_ques_list
-- ----------------------------
BEGIN;
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (1, 1, 1, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (2, 2, 2, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (3, 2, 3, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (4, 1, 4, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (5, 1, 5, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (6, 3, 2, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (7, 4, 4, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (8, 4, 1, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (9, 4, 6, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (10, 4, 7, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (11, 6, 4, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (12, 6, 1, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (13, 6, 6, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (14, 6, 7, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (15, 6, 1, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (16, 6, 4, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (17, 6, 6, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (18, 2, 44, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (19, 2, 4, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (20, 9, 61, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (21, 9, 62, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (22, 9, 63, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (23, 9, 64, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (24, 9, 65, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (25, 9, 66, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (26, 9, 67, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (27, 9, 68, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (28, 9, 69, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (29, 9, 70, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (30, 9, 71, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (31, 9, 72, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (32, 9, 73, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (33, 9, 74, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (34, 9, 75, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (35, 9, 76, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (36, 9, 77, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (37, 10, 61, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (38, 10, 62, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (39, 10, 63, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (40, 10, 61, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (41, 10, 62, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (42, 10, 63, 1);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (43, 11, 62, 0);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (44, 12, 61, 0);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (45, 12, 62, 0);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (46, 13, 61, 0);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (47, 13, 62, 0);
INSERT INTO `tb_folder_ques_list` (`id`, `folder_id`, `ques_id`, `deleted`) VALUES (48, 13, 64, 0);
COMMIT;

-- ----------------------------
-- Table structure for tb_ques_folder
-- ----------------------------
DROP TABLE IF EXISTS `tb_ques_folder`;
CREATE TABLE `tb_ques_folder` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '文件夹名称',
  `description` varchar(255) DEFAULT NULL COMMENT '文件夹描述',
  `course_id` int(11) NOT NULL COMMENT '所属课程id',
  `user_id` int(11) NOT NULL COMMENT '创建用户id',
  `creat_time` datetime DEFAULT NULL COMMENT '创建时间',
  `deleted` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑删除，0正常，1删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `course_id` (`course_id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE,
  CONSTRAINT `course_id` FOREIGN KEY (`course_id`) REFERENCES `tb_course` (`id`),
  CONSTRAINT `user_id` FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_ques_folder
-- ----------------------------
BEGIN;
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (1, '文件夹1', '该文件夹存放高等数学题目', 1, 6, '2024-03-20 22:25:49', 0);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (2, '文件夹2', '描述test', 2, 5, '2024-04-09 21:53:37', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (3, 'test admin folder', 'admin folder', 1, 5, '2024-04-09 14:26:14', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (4, '文件夹创建测试', '噜啦啦', 1, 5, '2024-04-13 08:36:55', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (5, '大苏打实打实打算', '啊实打实', 2, 5, '2024-04-13 08:54:13', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (6, '啊实打实刷新', '刷新', 3, 5, '2024-04-13 08:59:33', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (7, '十大阿三打算', '啊实打实', 1, 5, '2024-04-13 09:01:13', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (8, '啊实打实大苏打', '啊实打实', 2, 5, '2024-04-13 09:12:52', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (9, '个人文件夹', '123', 1, 5, '2024-04-16 03:20:06', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (10, '个人文件夹', '11', 1, 5, '2024-04-16 04:27:41', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (11, '计算机21-4', '测试', 1, 5, '2024-04-21 12:14:53', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (12, '计算机21-4', '高等数学', 1, 5, '2024-04-22 00:24:13', 1);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (13, '计算机21-3', '高等数学', 1, 5, '2024-04-24 09:42:07', 0);
INSERT INTO `tb_ques_folder` (`id`, `name`, `description`, `course_id`, `user_id`, `creat_time`, `deleted`) VALUES (14, '计算机21-4', '', 1, 5, '2024-07-17 22:49:31', 0);
COMMIT;

-- ----------------------------
-- Table structure for tb_ques_type
-- ----------------------------
DROP TABLE IF EXISTS `tb_ques_type`;
CREATE TABLE `tb_ques_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT '类型名称',
  `deleted` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑删除，0正常，1删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_ques_type
-- ----------------------------
BEGIN;
INSERT INTO `tb_ques_type` (`id`, `name`, `deleted`) VALUES (1, '选择题', 0);
INSERT INTO `tb_ques_type` (`id`, `name`, `deleted`) VALUES (2, '填空题', 0);
INSERT INTO `tb_ques_type` (`id`, `name`, `deleted`) VALUES (3, '简答题', 0);
INSERT INTO `tb_ques_type` (`id`, `name`, `deleted`) VALUES (4, '证明题', 0);
COMMIT;

-- ----------------------------
-- Table structure for tb_questions
-- ----------------------------
DROP TABLE IF EXISTS `tb_questions`;
CREATE TABLE `tb_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` longtext NOT NULL COMMENT '题目内容描述',
  `answer` varchar(255) DEFAULT NULL COMMENT '题目答案',
  `ques_cour` int(11) NOT NULL COMMENT '所属课程id',
  `chapter` varchar(255) DEFAULT NULL COMMENT '所属章节',
  `type_name` varchar(255) NOT NULL COMMENT '类型名称',
  `type_id` int(11) NOT NULL COMMENT '类型所属id',
  `hard` varchar(255) DEFAULT NULL COMMENT '难度',
  `score` double DEFAULT NULL COMMENT '分数',
  `deleted` int(255) NOT NULL DEFAULT '0' COMMENT '逻辑删除字段，0-正常，1已删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `ques_cour` (`ques_cour`) USING BTREE,
  KEY `type_id` (`type_id`) USING BTREE,
  CONSTRAINT `ques_cour` FOREIGN KEY (`ques_cour`) REFERENCES `tb_course` (`id`),
  CONSTRAINT `type_id` FOREIGN KEY (`type_id`) REFERENCES `tb_ques_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_questions
-- ----------------------------
BEGIN;
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (1, '<html>\n <head></head>\n <body>\n  <p>题目描述1111111111111111111111111111test11111描述description<img src=\"41fe29ec-c9fe-495e-9500-6fc55f37fbbe.png\" alt=\"\"></p>\n </body>\n</html>', 'A', 1, '第一章（章节可任填）', '单选题', 1, '5', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (2, '题目222222test', 'test', 2, '第二章', '应用题', 3, '3', 10, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (3, '啊大苏打', 'dsa', 2, '打死都不', '单选题', 1, '2', 2, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (4, '<html>\n <head></head>\n <body>\n  <p>描述描述描述描述描述描述描述描述描述描述描述描<img src=\"3471793b-971e-4c00-be01-aabca16f6ea2.jpg\" alt=\"\">述描述描述描述描述描述描述描述题目描述1111111111111111111111111111test11111描述description</p>\n </body>\n</html>', 'A', 1, '第一章（章节可任填）', '单选题', 1, '5', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (5, '<p>愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟愚蠢的伟</p>\n<p>愚蠢的伟</p>\n<p>愚蠢的伟</p>', 'A', 1, '第一章', '单选题', 1, '5', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (6, '题目描述1111111111111111111111111111test11111描述description', 'A', 1, '第一章（章节可任填）', '单选题', 1, '2', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (7, '<p>这里是题目描述</p>', 'A', 1, '第一章', '单项选择题', 1, '简单', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (44, '<p>好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题</p>', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (45, '<p>好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题</p>', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (46, '<p>好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题</p>', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (47, '<p>好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题好多好多题</p>', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (48, '图片测试asdsa', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (49, '', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (50, '会帮你就hi i很好看不加奶客户不能就', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (51, '会帮你就hi i很好看不加奶客户不能就', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (52, '<html>\n <head></head>\n <body>\n  <p>第一次<img src=\"1f98df9b-266f-4df5-affa-d7527c11a324.png\" alt=\"\"></p>\n </body>\n</html>', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (53, '<html>\n <head></head>\n <body>\n  <p>这题有图片——tuuli</p>\n  <p><img src=\"f4c619ad-c919-44cc-88a6-f348048edac1.jpg\" alt=\"\" width=\"368\" height=\"368\"></p>\n </body>\n</html>', '1', 1, '第一章', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (54, '<html>\n <head></head>\n <body>\n  <p>计算题计算题计算题计算题计算题计算题计算题计算题计算题计算题计算题计算题计算题计算题计算题</p>\n </body>\n</html>', '2', 2, '第一章', '简答', 3, '2', 2, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (56, '<html>\n <head></head>\n <body>\n  <p>填空题</p>\n </body>\n</html>', '1', 1, '第一章', '填空', 2, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (57, '<html>\n <head></head>\n <body>\n  <p>计算题</p>\n </body>\n</html>', '1', 1, '第一章', '简答', 3, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (59, '<html>\n <head></head>\n <body>\n  <p>证明题</p>\n </body>\n</html>', '3', 1, '2', '证明', 4, '3', 2, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (60, '<html>\n <head></head>\n <body>\n  <p>真的是无语了真的是无语了真的是无语了真的是无语了真的是无语了真的是无语了真的是无语了真的是无语了真的是无语了</p>\n </body>\n</html>', '1', 1, '1', '1', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (61, '<html>\n <head></head>\n <body>\n  <p data-pid=\"4RbfA8br\">A、B是数轴上原点两旁的点，则它们表示的两个有理数是（&nbsp; ）</p>\n  <p data-pid=\"US1-ZuBz\">A、互为相反数 B、绝对值相等 C、是符号不同的数 D、都是负数</p>\n </body>\n</html>', 'C', 1, '1', '单选题', 1, '1', 5, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (62, '<html>\n <head></head>\n <body>\n  <p data-pid=\"EYd980x1\">若|x|=x，则-x一定是（ ）</p>\n  <p data-pid=\"bvXF3yZ-\">A、正数 B、非负数 C、负数 D、非正数</p>\n </body>\n</html>', 'B', 1, '1', '单选题', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (63, '<html>\n <head></head>\n <body>\n  <p data-pid=\"othUT1Ec\">两个有理数的和除以这两个有理数的积，其商为0，则这两个有理数为（&nbsp; ）</p>\n  <p data-pid=\"K7qZfk3m\">A、互为相反数 B、互为倒数 C、互为相反数且不为0 D、有一个为0</p>\n </body>\n</html>', 'C', 1, '1', '单选题', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (64, '<html>\n <head></head>\n <body>\n  <p data-pid=\"-YK_QWj_\">“比x的相反数大3的数”可表示为（&nbsp; ）</p>\n  <p data-pid=\"_olmLbtT\">A、-x-3 B、-(x+3) C、3-x D、x+3</p>\n </body>\n</html>', 'C', 1, '1', '单选题', 1, '1', 1, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (65, '<html>\n <head></head>\n <body>\n  <p data-pid=\"qAQX0_hk\">如果0&lt;a&lt;1，那么下列说法正确的是（&nbsp; ）</p>\n  <p data-pid=\"j1VNx8wi\">A、a2比a大 B、a2比a小</p>\n  <p data-pid=\"hf2QFeaL\">C、a2与a相等 D、a2与a的大小不能确定</p>\n </body>\n</html>', 'B', 1, '1', '单选题', 1, '1', 1, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (66, '<html>\n <head></head>\n <body>\n  <p>已知 A y y x 2 2x 1 ,B y y 2x 1 ，则 A B _________。</p>\n </body>\n</html>', '2', 1, '1', '填空题', 2, '1', 1, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (67, '<html>\n <head></head>\n <body>\n  <p>集合 A＝{1,2,3,5}，当 x∈A时，若 x－1 A，x＋1 A，则称 x为 A的一个“孤立元素”，则 A中孤立元素的个数为____．</p>\n </body>\n</html>', '3', 1, '1', '填空题', 2, '1', 1, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (68, '<html>\n <head></head>\n <body>\n  <p>已知全集 U＝{3,7，a2－2a－3}，A＝{7，|a－7|}， UA＝{5}，则 a＝________.</p>\n </body>\n</html>', '3', 1, '1', '填空题', 2, '1', 1, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (69, '<html>\n <head></head>\n <body>\n  <p>设 U＝R，M＝{x|x≥1}，N＝{x|0≤x&lt;5}，则( UM)∪( UN)＝________________.</p>\n </body>\n</html>', '3', 1, '1', '填空题', 2, '1', 1, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (70, '<html>\n <head></head>\n <body>\n  <p data-pid=\"u6_eki1j\">域名服务DNS的主要功能是____。</p>\n  <p data-pid=\"n_adGsw9\">A.解析主机的IP地址</p>\n  <p data-pid=\"slrXq89V\">B.查询主机的MAC地址</p>\n  <p data-pid=\"aAIowbD8\">C.为主机自动命名</p>\n  <p data-pid=\"_WZA1bha\">D.合理分配IP地址</p>\n </body>\n</html>', 'A', 1, '1', '单选题', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (71, '<html>\n <head></head>\n <body>\n  <p>下列正确的是（&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;）</p>\n  <p>A．由数字1，2，3，4能够组成24个没有重复数字的三位数</p>\n  <p>B．由数字1，2，3，4，能够组成16个没有重复数字的三位偶数</p>\n  <p>C．由数字1，2，3，4能够组成64个三位密码</p>\n  <p>D．由数字1，2，3，4能够组成28个比320大的三位数</p>\n </body>\n</html>', '', 1, '1', '1', 1, '1', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (72, '<html>\n <head></head>\n <body>\n  <p class=\"MsoNormal\"><span style=\"font-family: 宋体;\">计算行列式<img src=\"a24d5bdd-3a99-43fc-be1e-93af2354cb23.png\" alt=\"\"></span></p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n </body>\n</html>', '', 1, '', '计算题', 3, '', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (73, '<html>\n <head></head>\n <body>\n  <p class=\"MsoNormal\"><span style=\"font-family: 宋体;\">计算四阶行列式</span><span style=\"font-family: 宋体;\">的值。</span></p>\n  <p class=\"MsoNormal\"><img src=\"d02d8309-72f9-4d3d-8f92-1bc4b43887a3.png\" alt=\"\"></p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n  <p class=\"MsoNormal\">&nbsp;</p>\n </body>\n</html>', '', 1, '', '计算题', 3, '', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (74, '<html>\n <head></head>\n <body>\n  <p><img src=\"c093933c-713a-44e3-a857-8c19842e65cf.jpg\" alt=\"\">如图，在平面直角坐标系中，O为原点，四边形ABCO是矩形，点A，C的坐标分别是A（0，2）和C（2√3，0），点D是对角线AC上一动点（不与A，C重合），连结BD，作DE⊥DB，交x轴于点E，以线段DE，DB为邻边作矩形BDEF．</p>\n  <p>(1)填空：点B的坐标为( &nbsp; &nbsp; &nbsp;);</p>\n  <p>(2)是否存在这样的点D，使得△DEC是等腰三角形？若存在，请求出AD的长度；若不存在，请说明理由；</p>\n  <p>(3)①求证：DE/DB=√3/3；</p>\n  <p>②设AD=x，矩形BDEF的面积为y，求y关于x的函数关系式（可利用①的结论），并求出y的最小值．</p>\n </body>\n</html>', '', 1, '', '简答题', 3, '', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (75, '<html>\n <head></head>\n <body>\n  <p>如图，AB是⊙O的直径，AB=4√3，点E为线段OB上一点（不与O，B重合），作CE⊥OB，交⊙O于点C，垂足为点E，作直径CD，过点C的切线交DB的延长线于点P，AF⊥PC于点F，连接CB．</p>\n  <p>(1)求证：CB是∠ECP的平分线；</p>\n  <p>(2)求证：CF=CE；</p>\n  <p>(3)当CF/CP=3/4时，求劣弧(BC) ̂的长度（结果保留π）.</p>\n  <p><img src=\"b0ccd876-e962-43a2-aee8-af4a55ed729c.jpg\" alt=\"\"></p>\n </body>\n</html>', '', 1, '', '简答题', 3, '', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (76, '<html>\n <head></head>\n <body>\n  <p>求函数f（x，y）=x³-4x²+2xy-y²的极值</p>\n </body>\n</html>', '', 1, '', '', 3, '', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (77, '<html>\n <head></head>\n <body>\n  <p>证明：<img src=\"ec6b5206-b92a-48d4-b847-9be91b9891d0.png\" alt=\"\"></p>\n </body>\n</html>', '', 1, '', '', 4, '', NULL, 0);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (78, '<html>\n <head></head>\n <body>\n  <p>创建试题</p>\n </body>\n</html>', '啊', 1, '1', '选择题', 1, '1', 1, 1);
INSERT INTO `tb_questions` (`id`, `description`, `answer`, `ques_cour`, `chapter`, `type_name`, `type_id`, `hard`, `score`, `deleted`) VALUES (79, '<html>\n <head></head>\n <body>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p>就阿松大骄傲地接纳为送电脑念叨念叨了我</p>\n  <p><img src=\"46fc1916-f0b8-4abf-b2e1-46da02e83af6.jpg\" alt=\"\"></p>\n </body>\n</html>', '', 1, '', '1', 1, '', NULL, 0);
COMMIT;

-- ----------------------------
-- Table structure for tb_tea_cour
-- ----------------------------
DROP TABLE IF EXISTS `tb_tea_cour`;
CREATE TABLE `tb_tea_cour` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT '用户id',
  `course_id` int(11) NOT NULL COMMENT '课程id',
  `deleted` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑删除，0正常，1删除',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `_user_id` (`user_id`) USING BTREE,
  KEY `_course_id` (`course_id`) USING BTREE,
  CONSTRAINT `_course_id` FOREIGN KEY (`course_id`) REFERENCES `tb_course` (`id`),
  CONSTRAINT `_user_id` FOREIGN KEY (`user_id`) REFERENCES `tb_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_tea_cour
-- ----------------------------
BEGIN;
INSERT INTO `tb_tea_cour` (`id`, `user_id`, `course_id`, `deleted`) VALUES (1, 6, 1, 1);
INSERT INTO `tb_tea_cour` (`id`, `user_id`, `course_id`, `deleted`) VALUES (2, 6, 2, 0);
INSERT INTO `tb_tea_cour` (`id`, `user_id`, `course_id`, `deleted`) VALUES (3, 5, 1, 0);
INSERT INTO `tb_tea_cour` (`id`, `user_id`, `course_id`, `deleted`) VALUES (4, 5, 2, 0);
INSERT INTO `tb_tea_cour` (`id`, `user_id`, `course_id`, `deleted`) VALUES (5, 7, 14, 0);
COMMIT;

-- ----------------------------
-- Table structure for tb_user
-- ----------------------------
DROP TABLE IF EXISTS `tb_user`;
CREATE TABLE `tb_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nickname` varchar(255) DEFAULT NULL COMMENT '用户名称',
  `username` varchar(255) NOT NULL COMMENT '账号',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `role` enum('teacher','admin') NOT NULL COMMENT '角色（教师、管理员）',
  `gender` enum('male','female','other') DEFAULT 'other' COMMENT '性别（男、女、其他）',
  `college` varchar(255) DEFAULT NULL COMMENT '所属院系',
  `deleted` int(11) NOT NULL DEFAULT '0' COMMENT '逻辑删除，0正常，1删除',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `username` (`username`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- ----------------------------
-- Records of tb_user
-- ----------------------------
BEGIN;
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (3, '接口测试', '666', '$2a$10$f6PuV5rnCnQmTqzbifQR9OVJdbB3EynZ4OMKjkIpxoUljxuQJa2me', 'admin', 'other', NULL, 0);
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (5, 'admin', 'admin', '$2a$10$1WV17jp87TI1TKVft95OrunOk/LHcoSYLsXn9BUQQOF3A8XwsjO6i', 'admin', 'male', '马克思学院', 0);
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (6, 'teacher', 'teacher', '$2a$10$8W3dJ3BlxyaL5lfrrPU0IOsJEkOVMUR42pYQg8jQAJ33M6zabfvWK', 'teacher', 'female', '计算机学院', 0);
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (7, 'root', 'root', '$2a$10$8FVsQsTIP89nP2NDCfy7b.4ESQuIATkRyI4N37z9NoLY.DF4MlkHm', 'admin', 'other', NULL, 0);
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (8, '11', 'instser', '$2a$10$nLCrmWdz5QODiSrdoDX2Ie290FmWIeOWNfbbkg1/n2gbpsr9zvLui', 'admin', 'male', '计算机', 0);
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (11, '22', 'Instserr', '$2a$10$M7PLLPnBnqEqZSOjEM5UCesOfPPI./3zrf0O5Gdq7VDYZoVBKoKdm', 'admin', 'male', 'a', 0);
INSERT INTO `tb_user` (`id`, `nickname`, `username`, `password`, `role`, `gender`, `college`, `deleted`) VALUES (12, 'aa', 'aaaa', '$2a$10$ZQJcwJU5xE0.5dxzh05Y1.B5nPZ2LWYyWl4rboPscceHuCx04kFAO', 'teacher', 'male', 'ttt', 0);
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
