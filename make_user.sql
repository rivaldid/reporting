CALL administration.drop_user('reporting',@res);
SELECT @res;
CREATE USER 'reporting'@'%' IDENTIFIED BY 'R3port666.';
GRANT ALL PRIVILEGES ON reporting.* TO 'reporting'@'%';
FLUSH PRIVILEGES;