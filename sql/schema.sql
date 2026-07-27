-- ============================================================
-- AgentHire AI - Complete MySQL Database Schema
-- Engine: InnoDB | Charset: utf8mb4
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. ROLES
-- ============================================================
CREATE TABLE IF NOT EXISTS `roles` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        ENUM('ADMIN', 'RECRUITER', 'CANDIDATE') NOT NULL,
    `description` VARCHAR(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_roles_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
    `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `email`             VARCHAR(255) NOT NULL,
    `password`          VARCHAR(255) DEFAULT NULL COMMENT 'BCrypt hash; NULL for OAuth-only users',
    `first_name`        VARCHAR(100) NOT NULL,
    `last_name`         VARCHAR(100) NOT NULL,
    `phone`             VARCHAR(20) DEFAULT NULL,
    `role_id`           BIGINT UNSIGNED NOT NULL,
    `provider`          ENUM('LOCAL', 'GOOGLE') NOT NULL DEFAULT 'LOCAL',
    `provider_id`       VARCHAR(255) DEFAULT NULL,
    `avatar_url`        VARCHAR(512) DEFAULT NULL,
    `is_active`         TINYINT(1) NOT NULL DEFAULT 1,
    `is_email_verified` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`        DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_users_email` (`email`),
    KEY `idx_users_role_id` (`role_id`),
    KEY `idx_users_provider` (`provider`, `provider_id`),
    KEY `idx_users_is_active` (`is_active`, `deleted_at`),
    KEY `idx_users_deleted_at` (`deleted_at`),
    KEY `idx_users_created_at` (`created_at`),
    CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. REFRESH TOKENS
-- ============================================================
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT UNSIGNED NOT NULL,
    `token`       VARCHAR(512) NOT NULL,
    `expiry_date` DATETIME NOT NULL,
    `is_revoked`  TINYINT(1) NOT NULL DEFAULT 0,
    `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_refresh_tokens_token` (`token`),
    KEY `idx_refresh_tokens_user_id` (`user_id`),
    KEY `idx_refresh_tokens_expiry` (`expiry_date`, `is_revoked`),
    CONSTRAINT `fk_refresh_tokens_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. LOGIN HISTORY
-- ============================================================
CREATE TABLE IF NOT EXISTS `login_history` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT UNSIGNED NOT NULL,
    `ip_address`  VARCHAR(45) NOT NULL,
    `user_agent`  VARCHAR(512) DEFAULT NULL,
    `login_time`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `logout_time` DATETIME DEFAULT NULL,
    `status`      ENUM('SUCCESS', 'FAILED') NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_login_history_user_id` (`user_id`),
    KEY `idx_login_history_user_time` (`user_id`, `login_time`),
    KEY `idx_login_history_status` (`status`, `login_time`),
    CONSTRAINT `fk_login_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. COMPANIES
-- ============================================================
CREATE TABLE IF NOT EXISTS `companies` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(255) NOT NULL,
    `description` TEXT DEFAULT NULL,
    `website`     VARCHAR(512) DEFAULT NULL,
    `logo_url`    VARCHAR(512) DEFAULT NULL,
    `industry`    VARCHAR(100) DEFAULT NULL,
    `size`        VARCHAR(50) DEFAULT NULL,
    `location`    VARCHAR(255) DEFAULT NULL,
    `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`  DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_companies_name` (`name`),
    KEY `idx_companies_industry` (`industry`),
    KEY `idx_companies_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. RECRUITERS
-- ============================================================
CREATE TABLE IF NOT EXISTS `recruiters` (
    `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`     BIGINT UNSIGNED NOT NULL,
    `company_id`  BIGINT UNSIGNED NOT NULL,
    `designation` VARCHAR(150) DEFAULT NULL,
    `department`  VARCHAR(150) DEFAULT NULL,
    `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
    `created_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_recruiters_user_company` (`user_id`, `company_id`),
    KEY `idx_recruiters_company_id` (`company_id`),
    KEY `idx_recruiters_is_active` (`is_active`),
    CONSTRAINT `fk_recruiters_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_recruiters_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. CANDIDATES
-- ============================================================
CREATE TABLE IF NOT EXISTS `candidates` (
    `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`          BIGINT UNSIGNED NOT NULL,
    `headline`         VARCHAR(255) DEFAULT NULL,
    `summary`          TEXT DEFAULT NULL,
    `experience_years` DECIMAL(4,1) UNSIGNED DEFAULT NULL,
    `current_company`  VARCHAR(255) DEFAULT NULL,
    `current_role`     VARCHAR(255) DEFAULT NULL,
    `expected_salary`  DECIMAL(15,2) UNSIGNED DEFAULT NULL,
    `location`         VARCHAR(255) DEFAULT NULL,
    `linkedin_url`     VARCHAR(512) DEFAULT NULL,
    `github_url`       VARCHAR(512) DEFAULT NULL,
    `portfolio_url`    VARCHAR(512) DEFAULT NULL,
    `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_candidates_user_id` (`user_id`),
    KEY `idx_candidates_location` (`location`),
    KEY `idx_candidates_experience` (`experience_years`),
    CONSTRAINT `fk_candidates_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. CANDIDATE SKILLS
-- ============================================================
CREATE TABLE IF NOT EXISTS `candidate_skills` (
    `id`                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `candidate_id`        BIGINT UNSIGNED NOT NULL,
    `skill_name`          VARCHAR(100) NOT NULL,
    `proficiency_level`   ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT NULL,
    `years_of_experience` DECIMAL(4,1) UNSIGNED DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_candidate_skill` (`candidate_id`, `skill_name`),
    KEY `idx_candidate_skills_name` (`skill_name`),
    CONSTRAINT `fk_candidate_skills_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. CANDIDATE CERTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `candidate_certifications` (
    `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `candidate_id`   BIGINT UNSIGNED NOT NULL,
    `name`           VARCHAR(255) NOT NULL,
    `issuing_org`    VARCHAR(255) NOT NULL,
    `issue_date`     DATE DEFAULT NULL,
    `expiry_date`    DATE DEFAULT NULL,
    `credential_url` VARCHAR(512) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_certifications_candidate` (`candidate_id`),
    KEY `idx_certifications_name` (`name`),
    CONSTRAINT `fk_certifications_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. RESUMES
-- ============================================================
CREATE TABLE IF NOT EXISTS `resumes` (
    `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `candidate_id`    BIGINT UNSIGNED NOT NULL,
    `file_name`       VARCHAR(255) NOT NULL,
    `file_path`       VARCHAR(512) NOT NULL,
    `file_type`       VARCHAR(50) NOT NULL,
    `file_size`       INT UNSIGNED NOT NULL,
    `is_primary`      TINYINT(1) NOT NULL DEFAULT 0,
    `parsed_content`  TEXT DEFAULT NULL,
    `upload_date`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_resumes_candidate` (`candidate_id`),
    KEY `idx_resumes_primary` (`candidate_id`, `is_primary`),
    FULLTEXT KEY `ft_resumes_parsed` (`parsed_content`),
    CONSTRAINT `fk_resumes_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. JOBS
-- ============================================================
CREATE TABLE IF NOT EXISTS `jobs` (
    `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `recruiter_id`     BIGINT UNSIGNED NOT NULL,
    `company_id`       BIGINT UNSIGNED NOT NULL,
    `title`            VARCHAR(255) NOT NULL,
    `description`      TEXT NOT NULL,
    `requirements`     TEXT DEFAULT NULL,
    `responsibilities` TEXT DEFAULT NULL,
    `job_type`         ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERNSHIP') NOT NULL DEFAULT 'FULL_TIME',
    `experience_level` ENUM('ENTRY', 'MID', 'SENIOR', 'LEAD') NOT NULL DEFAULT 'MID',
    `min_salary`       DECIMAL(15,2) UNSIGNED DEFAULT NULL,
    `max_salary`       DECIMAL(15,2) UNSIGNED DEFAULT NULL,
    `location`         VARCHAR(255) DEFAULT NULL,
    `is_remote`        TINYINT(1) NOT NULL DEFAULT 0,
    `status`           ENUM('DRAFT', 'ACTIVE', 'CLOSED', 'FILLED') NOT NULL DEFAULT 'DRAFT',
    `deadline`         DATE DEFAULT NULL,
    `created_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at`       DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_jobs_recruiter` (`recruiter_id`),
    KEY `idx_jobs_company` (`company_id`),
    KEY `idx_jobs_status` (`status`, `deleted_at`),
    KEY `idx_jobs_type_level` (`job_type`, `experience_level`),
    KEY `idx_jobs_location` (`location`),
    KEY `idx_jobs_deadline` (`deadline`),
    KEY `idx_jobs_created_at` (`created_at`),
    KEY `idx_jobs_deleted_at` (`deleted_at`),
    FULLTEXT KEY `ft_jobs_search` (`title`, `description`, `requirements`),
    CONSTRAINT `fk_jobs_recruiter` FOREIGN KEY (`recruiter_id`) REFERENCES `recruiters` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_jobs_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. JOB SKILLS
-- ============================================================
CREATE TABLE IF NOT EXISTS `job_skills` (
    `id`              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `job_id`          BIGINT UNSIGNED NOT NULL,
    `skill_name`      VARCHAR(100) NOT NULL,
    `is_required`     TINYINT(1) NOT NULL DEFAULT 1,
    `min_proficiency` ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_job_skill` (`job_id`, `skill_name`),
    KEY `idx_job_skills_name` (`skill_name`),
    CONSTRAINT `fk_job_skills_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. JOB APPLICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `job_applications` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `candidate_id` BIGINT UNSIGNED NOT NULL,
    `job_id`       BIGINT UNSIGNED NOT NULL,
    `resume_id`    BIGINT UNSIGNED DEFAULT NULL,
    `status`       ENUM('APPLIED', 'SCREENING', 'SHORTLISTED', 'INTERVIEW', 'OFFERED', 'HIRED', 'REJECTED') NOT NULL DEFAULT 'APPLIED',
    `cover_letter` TEXT DEFAULT NULL,
    `applied_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_application_candidate_job` (`candidate_id`, `job_id`),
    KEY `idx_applications_job` (`job_id`),
    KEY `idx_applications_status` (`status`),
    KEY `idx_applications_resume` (`resume_id`),
    KEY `idx_applications_applied_at` (`applied_at`),
    KEY `idx_applications_job_status` (`job_id`, `status`),
    CONSTRAINT `fk_applications_candidate` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_applications_job` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_applications_resume` FOREIGN KEY (`resume_id`) REFERENCES `resumes` (`id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. INTERVIEWS
-- ============================================================
CREATE TABLE IF NOT EXISTS `interviews` (
    `id`                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `job_application_id` BIGINT UNSIGNED NOT NULL,
    `interviewer_id`     BIGINT UNSIGNED NOT NULL,
    `scheduled_at`       DATETIME NOT NULL,
    `duration_minutes`   SMALLINT UNSIGNED NOT NULL DEFAULT 60,
    `type`               ENUM('TECHNICAL', 'HR', 'SYSTEM_DESIGN', 'CODING') NOT NULL,
    `status`             ENUM('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
    `meeting_link`       VARCHAR(512) DEFAULT NULL,
    `notes`              TEXT DEFAULT NULL,
    `created_at`         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_interviews_application` (`job_application_id`),
    KEY `idx_interviews_interviewer` (`interviewer_id`),
    KEY `idx_interviews_scheduled` (`scheduled_at`),
    KEY `idx_interviews_status` (`status`),
    KEY `idx_interviews_interviewer_schedule` (`interviewer_id`, `scheduled_at`),
    CONSTRAINT `fk_interviews_application` FOREIGN KEY (`job_application_id`) REFERENCES `job_applications` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_interviews_interviewer` FOREIGN KEY (`interviewer_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 15. INTERVIEW ROUNDS
-- ============================================================
CREATE TABLE IF NOT EXISTS `interview_rounds` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `interview_id` BIGINT UNSIGNED NOT NULL,
    `round_number` TINYINT UNSIGNED NOT NULL,
    `round_type`   VARCHAR(100) NOT NULL,
    `status`       ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED') NOT NULL DEFAULT 'PENDING',
    `score`        DECIMAL(5,2) DEFAULT NULL,
    `feedback`     TEXT DEFAULT NULL,
    `started_at`   DATETIME DEFAULT NULL,
    `ended_at`     DATETIME DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_interview_round` (`interview_id`, `round_number`),
    KEY `idx_interview_rounds_status` (`status`),
    CONSTRAINT `fk_interview_rounds_interview` FOREIGN KEY (`interview_id`) REFERENCES `interviews` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 16. CODING SESSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `coding_sessions` (
    `id`           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `interview_id` BIGINT UNSIGNED NOT NULL,
    `language`     VARCHAR(50) NOT NULL,
    `initial_code` MEDIUMTEXT DEFAULT NULL,
    `current_code` MEDIUMTEXT DEFAULT NULL,
    `status`       ENUM('INITIALIZED', 'ACTIVE', 'PAUSED', 'COMPLETED') NOT NULL DEFAULT 'INITIALIZED',
    `started_at`   DATETIME DEFAULT NULL,
    `ended_at`     DATETIME DEFAULT NULL,
    `created_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_coding_sessions_interview` (`interview_id`),
    KEY `idx_coding_sessions_status` (`status`),
    CONSTRAINT `fk_coding_sessions_interview` FOREIGN KEY (`interview_id`) REFERENCES `interviews` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 17. CODING SUBMISSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `coding_submissions` (
    `id`                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `coding_session_id` BIGINT UNSIGNED NOT NULL,
    `code`              MEDIUMTEXT NOT NULL,
    `language`          VARCHAR(50) NOT NULL,
    `output`            TEXT DEFAULT NULL,
    `is_correct`        TINYINT(1) DEFAULT NULL,
    `execution_time_ms` INT UNSIGNED DEFAULT NULL,
    `submitted_at`      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_coding_submissions_session` (`coding_session_id`),
    KEY `idx_coding_submissions_submitted` (`submitted_at`),
    CONSTRAINT `fk_coding_submissions_session` FOREIGN KEY (`coding_session_id`) REFERENCES `coding_sessions` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 18. NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `notifications` (
    `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`       BIGINT UNSIGNED NOT NULL,
    `type`          VARCHAR(50) NOT NULL,
    `title`         VARCHAR(255) NOT NULL,
    `message`       TEXT NOT NULL,
    `is_read`       TINYINT(1) NOT NULL DEFAULT 0,
    `metadata_json` JSON DEFAULT NULL,
    `created_at`    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_notifications_user_read` (`user_id`, `is_read`, `created_at`),
    KEY `idx_notifications_user_created` (`user_id`, `created_at`),
    KEY `idx_notifications_type` (`type`),
    CONSTRAINT `fk_notifications_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 19. AGENT REPORTS
-- ============================================================
CREATE TABLE IF NOT EXISTS `agent_reports` (
    `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `agent_type`     VARCHAR(100) NOT NULL,
    `reference_type` VARCHAR(100) NOT NULL,
    `reference_id`   BIGINT UNSIGNED NOT NULL,
    `report_json`    JSON NOT NULL,
    `score`          DECIMAL(5,2) DEFAULT NULL,
    `recommendation` VARCHAR(255) DEFAULT NULL,
    `created_at`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_agent_reports_ref` (`reference_type`, `reference_id`),
    KEY `idx_agent_reports_agent_type` (`agent_type`),
    KEY `idx_agent_reports_score` (`score`),
    KEY `idx_agent_reports_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 20. AUDIT LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id`             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `user_id`        BIGINT UNSIGNED DEFAULT NULL,
    `action`         VARCHAR(50) NOT NULL,
    `entity_type`    VARCHAR(100) NOT NULL,
    `entity_id`      BIGINT UNSIGNED NOT NULL,
    `old_value_json` JSON DEFAULT NULL,
    `new_value_json` JSON DEFAULT NULL,
    `ip_address`     VARCHAR(45) DEFAULT NULL,
    `created_at`     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_audit_user` (`user_id`),
    KEY `idx_audit_entity` (`entity_type`, `entity_id`),
    KEY `idx_audit_action` (`action`),
    KEY `idx_audit_created` (`created_at`),
    CONSTRAINT `fk_audit_logs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- VIEWS (filter soft-deleted records)
-- ============================================================
CREATE OR REPLACE VIEW `active_users` AS
    SELECT * FROM `users` WHERE `deleted_at` IS NULL;

CREATE OR REPLACE VIEW `active_companies` AS
    SELECT * FROM `companies` WHERE `deleted_at` IS NULL;

CREATE OR REPLACE VIEW `active_jobs` AS
    SELECT * FROM `jobs` WHERE `deleted_at` IS NULL;
