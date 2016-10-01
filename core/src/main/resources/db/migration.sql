##version: 1.0.0
CREATE TABLE info (DB_SCHEMA_VERSION VARCHAR(8));
INSERT INTO info VALUES ("1.0.0");

##version: 1.1.0
CREATE TABLE sample_list LIKE patient_list;
INSERT sample_list SELECT * FROM patient_list;
CREATE TABLE sample_list_list LIKE patient_list_list;
INSERT sample_list_list SELECT * FROM patient_list_list;
ALTER TABLE sample_list_list CHANGE PATIENT_ID SAMPLE_ID INT(11);
UPDATE info SET DB_SCHEMA_VERSION="1.1.0";

##version: 1.2.0
ALTER TABLE cna_event AUTO_INCREMENT=1;
ALTER TABLE mutation add UNIQUE KEY `UQ_MUTATION_EVENT_ID_GENETIC_PROFILE_ID_SAMPLE_ID` (`MUTATION_EVENT_ID`,`GENETIC_PROFILE_ID`,`SAMPLE_ID`);
ALTER TABLE sample_profile add UNIQUE KEY `UQ_SAMPLE_ID_GENETIC_PROFILE_ID` (`SAMPLE_ID`,`GENETIC_PROFILE_ID`);
UPDATE info SET DB_SCHEMA_VERSION="1.2.0";

##version: 1.2.1
SET @s = (SELECT IF(    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'cancer_study' AND table_schema = DATABASE() AND column_name = 'STATUS') > 0,  "SELECT 1", " ALTER TABLE cancer_study ADD STATUS int(1) DEFAULT NULL"));
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
UPDATE info SET DB_SCHEMA_VERSION="1.2.1";

##version: 1.2.2
CREATE TABLE gene_panel (
	INTERNAL_ID int(11) NOT NULL auto_increment,
	STABLE_ID varchar(255) NOT NULL,
	DESCRIPTION mediumtext,
	PRIMARY KEY (INTERNAL_ID),
	UNIQUE (STABLE_ID)
);

CREATE TABLE gene_panel_list (
	INTERNAL_ID int(11) NOT NULL,
	GENE_ID int(255) NOT NULL,
	PRIMARY KEY (INTERNAL_ID, GENE_ID),
	FOREIGN KEY (INTERNAL_ID) REFERENCES gene_panel (INTERNAL_ID) ON DELETE CASCADE,
	FOREIGN KEY (GENE_ID) REFERENCES gene (ENTREZ_GENE_ID) ON DELETE CASCADE
);

ALTER TABLE sample_profile ADD COLUMN PANEL_ID int(11) DEFAULT NULL, ADD FOREIGN KEY (PANEL_ID) REFERENCES gene_panel (PANEL_ID) ON DELETE RESTRICT;

UPDATE info SET DB_SCHEMA_VERSION="1.2.2";

##version: 1.2.3
CREATE TABLE `clinical_attribute_meta` (
  `ATTR_ID` varchar(255) NOT NULL,
  `DISPLAY_NAME` varchar(255) NOT NULL,
  `DESCRIPTION` varchar(2048) NOT NULL,
  `DATATYPE` varchar(255) NOT NULL,
  `PATIENT_ATTRIBUTE` BOOLEAN NOT NULL,
  `PRIORITY` varchar(255) NOT NULL,
  `CANCER_STUDY_ID` int(11) NOT NULL,
  PRIMARY KEY (`ATTR_ID`, `CANCER_STUDY_ID`),
  FOREIGN KEY (`CANCER_STUDY_ID`) REFERENCES `cancer_study` (`CANCER_STUDY_ID`) ON DELETE CASCADE
);

INSERT INTO clinical_attribute_meta 
    SELECT DISTINCT clinical_sample.attr_id, clinical_attribute.display_name, clinical_attribute.description, clinical_attribute.datatype, clinical_attribute.patient_attribute, clinical_attribute.priority, cancer_study.cancer_study_id 
    FROM clinical_attribute 
    INNER JOIN clinical_sample ON clinical_attribute.ATTR_ID = clinical_sample.ATTR_ID 
    INNER JOIN sample ON clinical_sample.internal_id = sample.internal_id 
    INNER JOIN patient ON sample.patient_id = patient.internal_id 
    INNER  JOIN cancer_study ON patient.cancer_study_id = cancer_study.cancer_study_id;

INSERT INTO clinical_attribute_meta 
    SELECT DISTINCT clinical_patient.attr_id, clinical_attribute.display_name, clinical_attribute.description, clinical_attribute.datatype, clinical_attribute.patient_attribute, clinical_attribute.priority, cancer_study.cancer_study_id 
    FROM clinical_attribute 
    INNER JOIN clinical_patient ON clinical_attribute.ATTR_ID = clinical_patient.ATTR_ID 
    INNER JOIN patient ON clinical_patient.internal_id = patient.internal_id 
    INNER JOIN cancer_study ON patient.cancer_study_id = cancer_study.cancer_study_id;

DROP TABLE clinical_attribute;

UPDATE info SET DB_SCHEMA_VERSION="1.2.3";
