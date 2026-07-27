-- ============================================================
-- AgentHire AI - Seed Data
-- ============================================================

-- Default Roles
INSERT INTO `roles` (`name`, `description`) VALUES
    ('ADMIN', 'System administrator with full access'),
    ('RECRUITER', 'Company recruiter who manages job postings and interviews'),
    ('CANDIDATE', 'Job seeker who applies for positions');

-- Admin User (password: Admin@123 - BCrypt encoded)
INSERT INTO `users` (`email`, `password`, `first_name`, `last_name`, `role_id`, `provider`, `is_active`, `is_email_verified`) VALUES
    ('admin@agenthire.ai', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'System', 'Admin', 1, 'LOCAL', 1, 1);

-- Sample Company
INSERT INTO `companies` (`name`, `description`, `website`, `industry`, `size`, `location`) VALUES
    ('AgentHire Technologies', 'Leading AI-powered recruitment platform', 'https://agenthire.ai', 'Technology', '51-200', 'San Francisco, CA'),
    ('TechCorp Solutions', 'Enterprise software development company', 'https://techcorp.com', 'Technology', '201-500', 'New York, NY'),
    ('DataFlow Analytics', 'Big data and analytics consulting firm', 'https://dataflow.io', 'Data Analytics', '11-50', 'Austin, TX');
