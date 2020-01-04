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

  FUNCTION get_user_name (
    user_id_in IN VARCHAR2,
    last_name_only IN VARCHAR2 DEFAULT 'N'
  )RETURN VARCHAR2;

  FUNCTION get_my_event_count(
    user_id_in IN VARCHAR2,
    date_in IN DATE,
    event_id_in IN VARCHAR2
  )RETURN NUMBER;

  FUNCTION ret_date_or_time(
    date_in IN DATE
  )RETURN VARCHAR2;
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

  FUNCTION get_user_name (
    user_id_in IN VARCHAR2,
    last_name_only IN VARCHAR2 DEFAULT 'N'
  )RETURN VARCHAR2
  AS
    user_name_out b_users.user_name%TYPE;
    cnt NUMBER;
  BEGIN
    FOR i IN (
      SELECT user_name FROM b_users
       WHERE user_id = user_id_in
    )LOOP
      user_name_out := i.user_name;
    END LOOP;

    IF last_name_only = 'Y' THEN
      cnt := REGEXP_INSTR(user_name_out,' |　');
      IF cnt > 0 THEN -- 1byte spaceとマルチバイトspace
        user_name_out := SUBSTR(user_name_out, 1, cnt-1);
      END IF;
    END IF;

    RETURN user_name_out;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE;
  END get_user_name;

  FUNCTION get_my_event_count(
    user_id_in IN VARCHAR2,
    date_in IN DATE,
    event_id_in IN VARCHAR2
  )RETURN NUMBER
  AS
    dt_first DATE;
    dt_last DATE;
    cnt NUMBER;
  BEGIN
    dt_first := TRUNC(date_in,'MONTH');
    dt_last := LAST_DAY(date_in);
    FOR i in (
      SELECT COUNT(*) cnt FROM b_stocks_log
      WHERE event_date BETWEEN dt_first AND dt_last
        AND user_id = user_id_in
        AND event_id = event_id_in
    )LOOP
      RETURN i.cnt;
    END LOOP;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE;
  END get_my_event_count;

  FUNCTION ret_date_or_time(
    date_in IN DATE
  )RETURN VARCHAR2
  AS
    cur_date DATE;
    in_date DATE;
  BEGIN
    cur_date := TRUNC(CURRENT_DATE);
    in_date := TRUNC(date_in);
    IF cur_date = in_date THEN
      RETURN TO_CHAR(date_in,'HH24:MI');
    ELSE
      RETURN TO_CHAR(date_in,'YYYY-MM-DD');
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN 
      RAISE;
  END ret_date_or_time;
END b_common;
/