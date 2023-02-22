DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ProductToCategory`(IN `p_product_id` INT, IN `p_category` VARCHAR(255))
BEGIN
 INSERT INTO oc_product_to_category (product_id, category_id) VALUES (p_product_id, (SELECT category_id FROM oc_category_description WHERE name=p_category));
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `activateProduct`(IN p_product_id INT)
BEGIN
    UPDATE oc_product 
    SET status=1
    WHERE product_id = p_product_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `addCategory`(IN p_name VARCHAR(255), IN p_parent_id INT, IN p_sort_order INT, IN p_status INT)
BEGIN
    DECLARE p_date_added DATETIME;
    DECLARE p_date_modified DATETIME;
    SET p_date_added = NOW();
    SET p_date_modified = NOW();

    INSERT INTO oc_category (parent_id, sort_order, status, date_added, date_modified)
    VALUES (p_parent_id, p_sort_order, p_status, p_date_added, p_date_modified);
    SET @last_id = LAST_INSERT_ID();

    INSERT INTO oc_category_description (category_id, name, language_id)
    VALUES (@last_id, p_name, 1);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `clearCategories`()
BEGIN
    TRUNCATE oc_category;
    TRUNCATE oc_category_description;
    TRUNCATE oc_product_to_category;
    TRUNCATE oc_category_to_store;
	TRUNCATE oc_category_path;
    TRUNCATE oc_category_filter;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `clearProducts`()
BEGIN
		
		TRUNCATE oc_product;
		TRUNCATE oc_product_description;
		TRUNCATE oc_product_image;
		TRUNCATE oc_product_to_category;
		TRUNCATE oc_product_to_store;
		TRUNCATE oc_product_option;
		TRUNCATE oc_product_option_value;
		TRUNCATE oc_product_special;
		TRUNCATE oc_product_to_layout;
		TRUNCATE oc_product_filter;
		TRUNCATE oc_product_discount;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `deactivateProduct`(IN p_product_id INT)
BEGIN
    UPDATE oc_product 
    SET status=0
    WHERE product_id = p_product_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteCategory`(IN p_category_id INT)
BEGIN
    DELETE FROM oc_category
    WHERE category_id = p_category_id;

    DELETE FROM oc_category_description
    WHERE category_id = p_category_id;

    DELETE FROM oc_product_to_category
    WHERE category_id = p_category_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `deleteProduct`(IN p_product_id INT)
BEGIN
    DELETE FROM oc_product
    WHERE product_id = p_product_id;

    DELETE FROM oc_product_description
    WHERE product_id = p_product_id;

    DELETE FROM oc_product_image
    WHERE product_id = p_product_id;

    DELETE FROM oc_product_to_category
    WHERE product_id = p_product_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `editCategory`(IN p_category_id INT, IN p_name VARCHAR(255), IN p_parent_id INT, IN p_sort_order INT, IN p_status INT)
BEGIN
    DECLARE p_date_modified DATETIME;
    SET p_date_modified = NOW();

    UPDATE oc_category
    SET parent_id = p_parent_id, sort_order = p_sort_order, status = p_status, date_modified = p_date_modified
    WHERE category_id = p_category_id;

    UPDATE oc_category_description
    SET name = p_name
    WHERE category_id = p_category_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `editPrice`(`p_product_model` varchar(255),`p_price` decimal, `p_price2` decimal)
BEGIN
  DECLARE p_product_id int;
  UPDATE oc_product SET price = p_price WHERE model = p_product_model;
	IF p_price2 IS NOT NULL THEN
		SET p_product_id = (SELECT product_id FROM oc_product WHERE model = p_product_model);
		IF p_product_id IS NOT NULL THEN 
			DELETE FROM oc_product_discount WHERE product_id = p_product_id;
			INSERT INTO oc_product_discount (product_id,customer_group_id,quantity,priority,price) VALUES (p_product_id,1,1,0, p_price2);
		END IF;
	END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `editProduct`(
IN p_product_id INT,
IN p_name VARCHAR(255), 
IN p_model VARCHAR(64), 
IN p_price DECIMAL(15,4), 
IN p_status TINYINT(1),
IN p_image VARCHAR(255),
IN p_language_id INT,
IN p_description TEXT,
IN p_tag VARCHAR(255),
IN p_meta_title VARCHAR(255),
IN p_meta_description TEXT,
IN p_meta_keyword VARCHAR(255),
IN p_category INT)
BEGIN

    DECLARE p_date_modified DATETIME;
    SET p_date_modified = NOW();

    UPDATE oc_product 
    SET model=p_model,price=p_price,image=p_image,status=p_status,date_modified=p_date_modified 
    WHERE product_id = p_product_id;
    
    UPDATE oc_product_description 
    SET language_id=p_language_id,name=p_name,description=p_description,tag=p_tag,meta_title=p_meta_title,meta_description=p_meta_description,meta_keyword=p_meta_keyword
    WHERE product_id = p_product_id;
    UPDATE oc_product_image
    SET image=p_image
    WHERE product_id = p_product_id;

    UPDATE oc_product_to_category
    SET category_id=p_category
    WHERE product_id = p_product_id;

END$$
DELIMITER ;
