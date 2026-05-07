-- database_add_student.sql
-- Jika ingin menambahkan hanya record mahasiswa untuk UAS
INSERT INTO `students` (`student_id`,`name`,`program`) VALUES
('2023230006','muhammad arya fatthurahman','Teknologi Informasi')
ON DUPLICATE KEY UPDATE name=VALUES(name);