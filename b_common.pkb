CREATE OR REPLACE PACKAGE b_common 
AS 
  TYPE yyyymm_type IS RECORD (
    yyyymm_str  VARCHAR2(7), -- 'YYYY/MM'
    yyyymmdd_dt DATE
  );
  TYPE rec_yyyymm IS TABLE OF yyyymm_type;
  FUNCTION ret_yyyymm (
    dt_in   IN DATE,
    cnt_in  IN NUMBER DEFAULT 12
  )RETURN rec_yyyymm PIPELINED;

  FUNCTION get_shop_name (
    user_id_in IN VARCHAR2    
  ) RETURN VARCHAR2;

  FUNCTION get_shop_id (
    user_id_in IN VARCHAR2    
  ) RETURN NUMBER;
END b_common;
/
CREATE OR REPLACE PACKAGE BODY b_common 
AS 
  FUNCTION ret_yyyymm (
    dt_in   IN DATE,
    cnt_in  IN NUMBER DEFAULT 12
  )RETURN rec_yyyymm PIPELINED
  AS
    rec yyyymm_type;
  BEGIN
    FOR i IN 1..cnt_in LOOP
      rec.yyyymmdd_dt := ADD_MONTHS(dt_in, i-1);
      rec.yyyymm_str := TO_CHAR(rec.yyyymmdd_dt,'YYYY/MM');
      PIPE ROW(rec);
    END LOOP;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END ret_yyyymm;

  FUNCTION get_shop_name (
    user_id_in IN VARCHAR2    
  ) RETURN VARCHAR2
  AS 
    shop_name_out b_shops.shop_name%TYPE;
  BEGIN 
    FOR i IN (
      SELECT s.shop_name
        FROM b_users u, b_shops s
       WHERE u.shop_id = s.shop_id
         AND LOWER(u.user_id) = LOWER(user_id_in)
         AND u.delete_flg = 'N'
         AND s.delete_flg = 'N'
    )LOOP 
      shop_name_out := i.shop_name;
    END LOOP;
    RETURN shop_name_out;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE;
  END get_shop_name;

  FUNCTION get_shop_id (
    user_id_in IN VARCHAR2    
  ) RETURN NUMBER
  AS 
    shop_id_out b_users.shop_id%TYPE;
  BEGIN 
    FOR i IN (
      SELECT shop_id
        FROM b_users 
       WHERE LOWER(user_id) = LOWER(user_id_in)
         AND delete_flg = 'N'
    )LOOP 
      shop_id_out := i.shop_id;
    END LOOP;
    RETURN shop_id_out;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE;
  END get_shop_id;

END b_common;
/