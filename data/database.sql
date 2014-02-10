SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';


-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT COMMENT 'The Internal ID for the user',
  `uid` VARCHAR(255) NOT NULL COMMENT 'An user identifier unique to the given provider. ',
  `provider` VARCHAR(45) NOT NULL COMMENT 'The provider with which the user authenticated (e.g. \'Twitter\' or \'Facebook\')',
  `email` VARCHAR(255) NULL,
  `first_name` VARCHAR(45) NULL,
  `last_name` VARCHAR(45) NULL,
  `role` ENUM('ADMIN', 'USER') NULL DEFAULT 'USER' COMMENT 'The user\'s role for the system.  Either ADMIN or USER.',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `users_unique` (`provider` ASC, `uid` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `sites`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `sites` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `base_url` VARCHAR(255) NOT NULL COMMENT 'the base url of the site',
  `gpa` DECIMAL(3,2) NOT NULL DEFAULT 0,
  `title` VARCHAR(255) NULL COMMENT 'The title of the site',
  `support_email` VARCHAR(45) NULL COMMENT 'The support email for the site',
  `last_connection_error` DATETIME NULL,
  `http_code` INT(10) NULL,
  `curl_code` INT(10) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `baseurl_UNIQUE` (`base_url` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `site_members`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `site_members` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `users_id` INT NOT NULL,
  `sites_id` INT NOT NULL,
  `source` VARCHAR(64) NULL COMMENT 'The source of this entry.  NULL means that it was generated by this system',
  `date_added` DATETIME NOT NULL COMMENT 'The date that this record was created',
  `verification_code` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_site_members_users_idx` (`users_id` ASC),
  INDEX `fk_site_members_sites1_idx` (`sites_id` ASC),
  UNIQUE INDEX `unique_site_members` (`users_id` ASC, `sites_id` ASC, `source` ASC),
  CONSTRAINT `fk_site_members_users`
    FOREIGN KEY (`users_id`)
    REFERENCES `users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_site_members_sites1`
    FOREIGN KEY (`sites_id`)
    REFERENCES `sites` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `role_name` VARCHAR(45) NOT NULL,
  `description` LONGTEXT NULL,
  `protected` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO' COMMENT 'A protected role means that only a manager can assign/approve it',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `rolename_UNIQUE` (`role_name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `site_member_roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `site_member_roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `site_members_id` INT NOT NULL,
  `roles_id` INT NOT NULL,
  `approved` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO',
  `source` VARCHAR(64) NULL COMMENT 'The source of the member role.  If null, it means that the system generated it.',
  PRIMARY KEY (`id`, `site_members_id`),
  INDEX `fk_site_member_roles_site_members1_idx` (`site_members_id` ASC),
  INDEX `fk_site_member_roles_roles1_idx` (`roles_id` ASC),
  UNIQUE INDEX `unique_site_member_roles` (`site_members_id` ASC, `roles_id` ASC),
  CONSTRAINT `fk_site_member_roles_site_members1`
    FOREIGN KEY (`site_members_id`)
    REFERENCES `site_members` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_site_member_roles_roles1`
    FOREIGN KEY (`roles_id`)
    REFERENCES `roles` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `scans`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `scans` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `sites_id` INT NOT NULL,
  `gpa` DECIMAL(3,2) NOT NULL DEFAULT 0 COMMENT 'the GPA.  This is computed by averaging the numeric value of the scanned_page.grade',
  `status` ENUM('CREATED', 'QUEUED', 'RUNNING', 'COMPLETE', 'ERROR') NOT NULL DEFAULT 'CREATED',
  `scan_type` ENUM('USER', 'AUTO') NOT NULL DEFAULT 'AUTO',
  `date_created` DATETIME NOT NULL,
  `start_time` DATETIME NULL,
  `end_time` DATETIME NULL,
  `error` VARCHAR(256) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_scans_sites1_idx` (`sites_id` ASC),
  CONSTRAINT `fk_scans_sites1`
    FOREIGN KEY (`sites_id`)
    REFERENCES `sites` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `scanned_page`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `scanned_page` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `scans_id` INT NOT NULL,
  `sites_id` INT NOT NULL,
  `uri` VARCHAR(256) NOT NULL COMMENT 'The same URI can be found multiple times in a single scan.  A single page can be rescanned instead of the entire site.  Those cans should be able to be compared with each other and should not overwrite history.',
  `status` ENUM('CREATED', 'QUEUED', 'RUNNING', 'COMPLETE', 'ERROR') NOT NULL DEFAULT 'CREATED',
  `scan_type` ENUM('USER', 'AUTO') NOT NULL DEFAULT 'AUTO',
  `grade` DECIMAL(5,2) NOT NULL DEFAULT 0 COMMENT 'the grade for the page.  This is gathered by 100 - (marks.point_deduction) with the grading scale applied\nA=4\nB=3\nC=2\nD=1' /* comment truncated */ /*F=0*/,
  `priority` INT NOT NULL DEFAULT 300 COMMENT 'The priority for this job. 0 is the most urgent',
  `date_created` DATETIME NOT NULL,
  `start_time` DATETIME NULL,
  `end_time` DATETIME NULL,
  `title` VARCHAR(256) NULL,
  `letter_grade` VARCHAR(2) NULL,
  `error` VARCHAR(256) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_scanned_page_scans1_idx` (`scans_id` ASC),
  INDEX `fk_scanned_page_sites1_idx` (`sites_id` ASC),
  CONSTRAINT `fk_scanned_page_scans1`
    FOREIGN KEY (`scans_id`)
    REFERENCES `scans` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_scanned_page_sites1`
    FOREIGN KEY (`sites_id`)
    REFERENCES `sites` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `metrics`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `metrics` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `machine_name` VARCHAR(64) NOT NULL COMMENT 'the name of the module for the metic.  ie:  metric_wdn_version',
  `weight` DECIMAL(5,2) NOT NULL DEFAULT 0 COMMENT '0 to 100 % value of all enabled metrics. The total of all metrics can not be > 100',
  PRIMARY KEY (`id`))
ENGINE = InnoDB
COMMENT = 'These are metrics, such as links checks, html validity, acce' /* comment truncated */ /*ssibility, etc*/;


-- -----------------------------------------------------
-- Table `marks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `marks` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `metrics_id` INT NOT NULL,
  `machine_name` VARCHAR(64) NOT NULL COMMENT 'Machine readable name of the metric.  IE: 404_link\n\nThis must be unique to the metric.\n\nThe machine_name is how modules can easily retrieve marks.',
  `name` TEXT NOT NULL COMMENT 'The name of the mark.  i.e.  \"404 Link\"',
  `point_deduction` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `description` TEXT NULL COMMENT 'A longer description of the mark and why it was marked',
  `help_text` VARCHAR(45) NULL COMMENT 'General \'how to fix\' text',
  PRIMARY KEY (`id`),
  INDEX `fk_marks_metrics1_idx` (`metrics_id` ASC),
  UNIQUE INDEX `marks_unique` (`metrics_id` ASC, `machine_name` ASC),
  CONSTRAINT `fk_marks_metrics1`
    FOREIGN KEY (`metrics_id`)
    REFERENCES `metrics` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `page_marks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `page_marks` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `marks_id` INT NOT NULL,
  `scanned_page_id` INT NOT NULL,
  `points_deducted` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `context` TEXT NULL,
  `line` INT NULL,
  `col` INT NULL,
  `value_found` VARCHAR(256) NULL COMMENT 'The incorrect value that was found',
  PRIMARY KEY (`id`),
  INDEX `fk_page_marks_marks1_idx` (`marks_id` ASC),
  INDEX `fk_page_marks_scanned_page1_idx` (`scanned_page_id` ASC),
  CONSTRAINT `fk_page_marks_marks1`
    FOREIGN KEY (`marks_id`)
    REFERENCES `marks` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_page_marks_scanned_page1`
    FOREIGN KEY (`scanned_page_id`)
    REFERENCES `scanned_page` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `page_metric_grades`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `page_metric_grades` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `metrics_id` INT NOT NULL,
  `scanned_page_id` INT NOT NULL,
  `grade` DECIMAL(5,2) NOT NULL DEFAULT 0,
  `changes_since_last_scan` INT NOT NULL DEFAULT 0 COMMENT 'The number of changes since the last scan. \n',
  `pass_fail` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO' COMMENT 'Was the grade a pass/fail?',
  `incomplete` ENUM('YES', 'NO') NOT NULL DEFAULT 'NO' COMMENT 'YES if the metric was unable to complete for any reason.  For Example: the html check was unable to get a response from the validator service.',
  `letter_grade` VARCHAR(2) NULL,
  INDEX `fk_page_metric_grades_metrics1_idx` (`metrics_id` ASC),
  INDEX `fk_page_metric_grades_scanned_page1_idx` (`scanned_page_id` ASC),
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_page_metric_grades_metrics1`
    FOREIGN KEY (`metrics_id`)
    REFERENCES `metrics` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_page_metric_grades_scanned_page1`
    FOREIGN KEY (`scanned_page_id`)
    REFERENCES `scanned_page` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
