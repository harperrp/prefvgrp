SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS poll_votes, polls, content_versions, audit_logs, redirects, external_integrations, settings, manifestation_messages, manifestations, gallery_images, galleries, secretariats, services, faqs, works, documents, contracts, bids, laws, news, files, users;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('super_admin','editor','operator','viewer') NOT NULL DEFAULT 'editor',
  permissions_json JSON NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_users_active (is_active, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE files (
  id INT AUTO_INCREMENT PRIMARY KEY,
  original_name VARCHAR(255) NOT NULL,
  stored_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(120) NOT NULL,
  size INT NOT NULL,
  path VARCHAR(255) NOT NULL,
  public_url VARCHAR(500) NOT NULL,
  uploaded_by INT NULL,
  created_at DATETIME NOT NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_files_user FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_files_path (path)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE news (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  slug VARCHAR(240) NOT NULL UNIQUE,
  summary TEXT NULL,
  content LONGTEXT NULL,
  category VARCHAR(90) NULL,
  status ENUM('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  featured_image_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_news_image FOREIGN KEY (featured_image_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_news_public (status, published_at, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE laws (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(90) NOT NULL,
  number VARCHAR(60) NOT NULL,
  year INT NOT NULL,
  description TEXT NOT NULL,
  status ENUM('draft','published','archived','revoked') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_laws_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_laws_public (status, year, number, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE bids (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  modality VARCHAR(90) NOT NULL,
  number VARCHAR(80) NOT NULL,
  opening_date DATE NULL,
  amount DECIMAL(14,2) NULL,
  status ENUM('draft','published','open','judgment','homologated','closed','archived') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_bids_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_bids_public (status, opening_date, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE contracts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  bid_id INT NULL,
  title VARCHAR(220) NOT NULL,
  number VARCHAR(80) NOT NULL,
  supplier VARCHAR(190) NULL,
  amount DECIMAL(14,2) NULL,
  signed_at DATE NULL,
  status ENUM('draft','published','active','finished','archived') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_contract_bid FOREIGN KEY (bid_id) REFERENCES bids(id) ON DELETE SET NULL,
  CONSTRAINT fk_contract_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_contract_status (status, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE documents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  category VARCHAR(90) NOT NULL,
  description TEXT NULL,
  status ENUM('draft','review','published','archived') NOT NULL DEFAULT 'draft',
  file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_docs_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_documents_public (status, category, published_at, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE works (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  description TEXT NULL,
  location VARCHAR(220) NULL,
  budget DECIMAL(14,2) NULL,
  progress TINYINT UNSIGNED NOT NULL DEFAULT 0,
  status ENUM('draft','published','planned','in_progress','paused','completed','archived') NOT NULL DEFAULT 'draft',
  image_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_works_image FOREIGN KEY (image_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_works_public (status, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE faqs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question VARCHAR(255) NOT NULL,
  answer TEXT NOT NULL,
  category VARCHAR(90) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_faq_public (is_published, sort_order, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE services (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(160) NOT NULL,
  description TEXT NULL,
  external_url VARCHAR(500) NULL,
  icon VARCHAR(20) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_services_active (is_active, sort_order, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE secretariats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  responsible VARCHAR(160) NULL,
  phone VARCHAR(60) NULL,
  email VARCHAR(190) NULL,
  address VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_secretariats_active (is_active, name, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE galleries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  description TEXT NULL,
  status ENUM('draft','published','archived') NOT NULL DEFAULT 'draft',
  cover_file_id INT NULL,
  published_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_gallery_cover FOREIGN KEY (cover_file_id) REFERENCES files(id) ON DELETE SET NULL,
  INDEX idx_galleries_public (status, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE gallery_images (
  id INT AUTO_INCREMENT PRIMARY KEY,
  gallery_id INT NOT NULL,
  file_id INT NOT NULL,
  caption VARCHAR(255) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_gallery_images_gallery FOREIGN KEY (gallery_id) REFERENCES galleries(id) ON DELETE CASCADE,
  CONSTRAINT fk_gallery_images_file FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE,
  INDEX idx_gallery_images (gallery_id, sort_order, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE manifestations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  protocol VARCHAR(40) NOT NULL UNIQUE,
  type ENUM('SIC','Denuncia','Reclamacao','Sugestao','Elogio') NOT NULL DEFAULT 'SIC',
  subject VARCHAR(220) NOT NULL,
  description TEXT NOT NULL,
  citizen_name VARCHAR(160) NULL,
  citizen_email VARCHAR(190) NULL,
  citizen_phone VARCHAR(60) NULL,
  status ENUM('open','in_analysis','answered','closed') NOT NULL DEFAULT 'open',
  priority ENUM('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  assigned_to INT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  due_at DATETIME NULL,
  closed_at DATETIME NULL,
  CONSTRAINT fk_manifest_assigned FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_manifest_status (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE manifestation_messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  manifestation_id INT NOT NULL,
  user_id INT NULL,
  message TEXT NOT NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_msg_manifest FOREIGN KEY (manifestation_id) REFERENCES manifestations(id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_msg_manifest (manifestation_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(120) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  is_public TINYINT(1) NOT NULL DEFAULT 1,
  updated_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE external_integrations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  url VARCHAR(500) NULL,
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE redirects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  label VARCHAR(160) NOT NULL,
  slug VARCHAR(120) NOT NULL UNIQUE,
  url VARCHAR(500) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE audit_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id INT NULL,
  before_json JSON NULL,
  after_json JSON NULL,
  ip VARCHAR(60) NULL,
  user_agent VARCHAR(255) NULL,
  created_at DATETIME NOT NULL,
  INDEX idx_audit_entity (entity_type, entity_id),
  INDEX idx_audit_date (created_at),
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE content_versions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  entity_type VARCHAR(80) NOT NULL,
  entity_id INT NOT NULL,
  data_json JSON NOT NULL,
  user_id INT NULL,
  created_at DATETIME NOT NULL,
  INDEX idx_versions_entity (entity_type, entity_id),
  CONSTRAINT fk_versions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE polls (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question VARCHAR(255) NOT NULL,
  options_json JSON NOT NULL,
  status ENUM('draft','published','closed','archived') NOT NULL DEFAULT 'draft',
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  deleted_at DATETIME NULL,
  INDEX idx_polls_public (status, starts_at, ends_at, deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE poll_votes (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  poll_id INT NOT NULL,
  option_index INT NOT NULL,
  ip_hash VARCHAR(128) NOT NULL,
  created_at DATETIME NOT NULL,
  CONSTRAINT fk_poll_votes_poll FOREIGN KEY (poll_id) REFERENCES polls(id) ON DELETE CASCADE,
  UNIQUE KEY uq_poll_vote (poll_id, ip_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
